# WotLK Private Server — Claude Guide

## Project Overview

Private AzerothCore (WotLK 3.3.5a) server for a small friend group, focused on solo/small-group play. This repo contains:

- **Config files** — `worldserver.conf`, `authserver.conf`, and per-module configs
- **SQL migrations** — versioned, rollback-capable patches for world and characters DBs
- **Scripts** — deploy, rollback, and status tooling that operates over SSH
- **Core patches** — `patches/*.patch` — unified diffs applied to AzerothCore source before building

## Server Setup

| Setting | Value |
|---|---|
| Server path | `/root/azerothcore-wotlk` |
| SSH target | `root@azerothcore` (Tailscale) |
| MySQL | `acore`/`acore` on `127.0.0.1:3306` |
| DBs | `acore_world`, `acore_characters`, `acore_auth` |

> Credentials are in `.env` (gitignored). Never commit `.env`.

## Active Modules

### Third-party (installed on server, not in this repo's `modules/`)

| Module | Purpose |
|---|---|
| `mod-autobalance` | Scales creature difficulty to group size |
| `mod-aoe-loot` | Installed but **disabled** via `AOELoot.Enable = 0` |
| `mod-arac` | Allows all races to play all classes (SQL + DBC + client Patch-A.MPQ) |

### Custom (source lives in `modules/` in this repo)

| Module | Purpose |
|---|---|
| `mod-alt-level-boost` | Innkeeper gossip: alts can boost to highest-char level in 5-level steps |
| `mod-gnome-druid-forms` | Custom shapeshift models + per-form scale overrides for Gnome Druids |

Module config files live in `config/modules/`.

## Repo Structure

```
wotlk/
├── CLAUDE.md
├── .env.example
├── config/
│   ├── worldserver.conf
│   ├── authserver.conf
│   └── modules/
│       ├── AutoBalance.conf
│       ├── mod_aoe_loot.conf
│       └── mod_arac.conf
├── modules/
│   ├── skeleton-module/    # canonical template — copy to create a new module
│   └── mod-alt-level-boost/
├── sql/
│   └── migrations/
│       ├── world/          # patches against acore_world
│       └── characters/     # patches against acore_characters
└── scripts/
    ├── deploy.sh           # apply pending migrations + sync configs
    ├── rollback.sh         # undo last applied migration
    └── status.sh           # show applied vs pending migrations
```

## Core Patches

Sometimes a feature can't be done purely in a module and requires a small edit to AzerothCore's
own source. These are stored as unified diffs in `patches/` and **must be applied to the server
source before building**.

### Applying a patch

```bash
# On the server:
cd ~/azerothcore-wotlk
git apply < /path/to/patches/0001-my-patch.patch
# then build as normal
```

Or via SSH from the repo root:

```bash
ssh root@azerothcore 'cd ~/azerothcore-wotlk && patch -p1' < patches/0001-my-patch.patch
```

### Current patches

| File | What it changes |
|---|---|
| `patches/0001-configurable-taxi-flight-speed.patch` | Adds `TaxiFlightSpeed` config key to control taxi path velocity (default 32.0, server uses 64.0 for 2×) |

### Naming convention

```
patches/<NNNN>-<kebab-description>.patch
```

Numbers are sequential. Always include a comment at the top of the patch describing the reason.

---

## Custom Modules

Custom C++ modules live in `modules/<mod-name>/` locally and are built on the server under
`~/azerothcore-wotlk/modules/<mod-name>/`.

### Directory layout

```
modules/mod-my-feature/
├── src/
│   ├── mod_my_feature_loader.cpp   # entry point — required
│   └── mod_my_feature.cpp          # script implementation(s)
├── conf/
│   └── mod_my_feature.conf.dist    # config template (omit if no config needed)
└── data/
    └── sql/
        └── db-world/               # SQL applied by AzerothCore on startup (strings, etc.)
```

Use `modules/skeleton-module/` as a starting point — copy it and rename.

### Naming conventions

| Thing | Pattern | Example |
|---|---|---|
| Module folder | `mod-<kebab-name>` | `mod-hearthstone-fix` |
| Loader function | `Add<mod_snake_name>Scripts()` | `Addmod_hearthstone_fixScripts()` |
| Script classes | `PascalCase`, descriptive | `spell_hearthstone_cooldown_fix` |
| Conf key prefix | `MyModule.` (or a clear prefix) | `HearthstoneFix.Enable` |

The loader function name is derived by replacing every `-` in the folder name with `_` and
prepending `Add` + appending `Scripts`. AzerothCore's `ModulesLoader.cpp.in.cmake` generates
a call to that exact symbol at build time — the name must match exactly.

### `src/<mod>_loader.cpp`

```cpp
// Forward-declare one function per script file
void AddMyFeatureScripts();

// Entry point — name must match folder name with '-' → '_'
void Addmod_my_featureScripts()
{
    AddMyFeatureScripts();
}
```

### `src/<mod>.cpp` — SpellScript example

```cpp
#include "Player.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"

class spell_my_fix : public SpellScript
{
    PrepareSpellScript(spell_my_fix);

    void HandleAfterCast()
    {
        // ...
    }

    void Register() override
    {
        AfterCast += SpellCastFn(spell_my_fix::HandleAfterCast);
    }
};

void AddMyFeatureScripts()
{
    RegisterSpellScript(spell_my_fix);   // script name = "spell_my_fix"
}
```

SpellScripts also need a row in `spell_script_names` (see SQL Migrations below).
AllCreatureScripts / PlayerScripts / WorldScripts use `new MyClass()` instead of `RegisterSpellScript`.

### `conf/mod_my_feature.conf.dist`

```ini
[worldserver]

########################################
# My feature configuration
########################################
#
#    MyFeature.Enable
#        Default: 1 - Enabled / 0 - Disabled
#

MyFeature.Enable = 1
```

Copy `conf/*.conf.dist` → `config/modules/` (without the `.dist`) for repo-tracked overrides
that get synced to the server by `deploy.sh --all`.

### Build & deploy workflow

```bash
# 1. Copy module to server
scp -r modules/mod-my-feature root@azerothcore:~/azerothcore-wotlk/modules/

# 2. If this is a NEW module (first time), re-run cmake so it gets discovered.
#    Existing modules don't need this step.
ssh root@azerothcore 'cd ~/azerothcore-wotlk/var/build/obj && cmake ~/azerothcore-wotlk'

# 3. Build (use the alias on the server — handles modules + worldserver)
#    Run this on the server: build

# 4. Stop server, install binary, restart
ssh root@azerothcore 'tmux send-keys -t world-session "server shutdown 5" Enter'
# wait ~10s, then:
ssh root@azerothcore 'cp ~/azerothcore-wotlk/var/build/obj/src/server/apps/worldserver ~/azerothcore-wotlk/env/dist/bin/worldserver'
ssh root@azerothcore 'tmux send-keys -t world-session "cd ~/azerothcore-wotlk && ./acore.sh run-worldserver" Enter'

# 5. Apply any SQL migrations
./scripts/deploy.sh world
```

> **Note:** The `build` alias on the server expands to `cd ~/azerothcore-wotlk; ./acore.sh compiler build`.
> Do **not** run cmake build commands autonomously over SSH — only tell the user to run `build`.

> **Note:** The simple-restarter relaunches worldserver almost instantly after a clean shutdown
> (`server restart 5` → exit 0). Use `server shutdown` + manual restart when installing a new binary,
> or the binary will be busy when you try to copy it.

### Disabling a module from the build

`mod-playerbots` is disabled because it has thousands of files and makes builds very slow.
To disable a module without removing it:

```bash
cd ~/azerothcore-wotlk/var/build/obj
cmake ~/azerothcore-wotlk -DMODULE_MOD-PLAYERBOTS=disabled
```

Re-enable with `-DMODULE_MOD-PLAYERBOTS=static`. The cmake variable name is always
`MODULE_<UPPERCASE-MODULE-NAME>` (hyphens preserved).

### SQL for SpellScripts

If a script file registers SpellScripts via `RegisterSpellScript(my_class)`, the DB needs to
know which spell ID maps to which script name. Add a migration pair:

```sql
-- 0007_up_my_spell_script.sql
INSERT IGNORE INTO `spell_script_names` (`spell_id`, `ScriptName`)
VALUES (12345, 'spell_my_fix');

-- 0007_down_my_spell_script.sql
DELETE FROM `spell_script_names` WHERE `spell_id` = 12345 AND `ScriptName` = 'spell_my_fix';
```

The `ScriptName` must be the exact string `RegisterSpellScript` registers — by default that is
the class name (`#spell_my_fix`).

## SQL Migration System

### File naming

```
sql/migrations/<db>/<NNNN>_<up|down>_<short_description>.sql
```

Rules:
- Numbers are zero-padded to 4 digits and sequential within each DB folder
- Every `_up_` file **must** have a matching `_down_` file
- `_up_` files should be idempotent where possible (use `INSERT IGNORE`, `UPDATE ... WHERE NOT EXISTS`, etc.)
- `_down_` files must cleanly undo exactly what the `_up_` did

### Workflow

```bash
./scripts/status.sh world          # see what's pending
./scripts/deploy.sh world          # apply pending migrations
./scripts/rollback.sh world        # undo last migration (interactive prompt)
./scripts/rollback.sh world --yes  # skip prompt (used by Claude for testing)
./scripts/deploy.sh --all          # migrations + rsync configs to server
```

### Module SQL dependencies

When a module is installed, always check for SQL files it needs:

```bash
find ~/azerothcore-wotlk/modules/<mod-name>/data/sql -name "*.sql"
```

Missing module SQL is a common source of crashes. For example, `mod-aoe-loot` required
`module_string` entries that were absent — causing a null pointer crash on every login.
Always apply module SQL via a migration in this repo, not directly.

## Server Management

### Normal restart

```bash
# In the worldserver console (via tmux):
server restart 5
```

The server runs under `acore.sh run-worldserver` → `simple-restarter` → `starter` → `worldserver`.
The restarter loop catches non-zero exits and relaunches automatically. `server restart` exits
with code 0, which triggers a clean relaunch.

### Tmux sessions

| Session | Process |
|---|---|
| `world-session` | worldserver |
| `auth-session` | authserver |

```bash
# Attach to worldserver console
ssh root@azerothcore 'tmux attach -t world-session'

# Send a command without attaching
ssh root@azerothcore 'tmux send-keys -t world-session "server restart 5" Enter'
```

### Debugging crashes (GDB mode)

To capture a stack trace on crash, restart with GDB enabled:

```bash
ssh root@azerothcore 'tmux send-keys -t world-session "server shutdown 5" Enter'
# wait for shutdown, then:
ssh root@azerothcore 'tmux send-keys -t world-session "bash ~/azerothcore-wotlk/apps/startup-scripts/src/simple-restarter ~/azerothcore-wotlk/env/dist/bin worldserver ~/azerothcore-wotlk/apps/startup-scripts/src/gdb.conf \"\" \"\" \"\" 1 ~/azerothcore-wotlk/env/dist/bin/crashes" Enter'
```

Stack trace is written to `~/azerothcore-wotlk/env/dist/bin/crashes/gdb-crash.txt`.

> **Note:** In GDB mode, `server restart` causes a clean shutdown (exit 0) and the restarter
> will **not** relaunch. Use `server shutdown` instead, then start manually.

After debugging, switch back to the normal restarter:

```bash
ssh root@azerothcore 'tmux send-keys -t world-session "cd ~/azerothcore-wotlk && ./acore.sh run-worldserver" Enter'
```

## Working with Claude

### What I can do

- Write SQL migration pairs (up + down) for any game content changes
- Create new custom modules using `modules/skeleton-module/` as the template
- Review and suggest edits to config files
- Run scripts and SSH commands — I'll always show you the command before executing
- Debug server crashes using GDB stack traces and logs

### Conventions I follow

- **Always write the `_down_` file before suggesting you run the `_up_`** — rollback first
- **I won't run destructive commands without explicit confirmation**
- **Always ask before restarting the worldserver** — players may be online
- **Config changes go in the repo first**, then get synced — no editing files directly on the server
- **One migration = one logical change** — I'll split unrelated changes into separate numbered files
- **Module SQL goes through the migration system** — never apply directly to the server
- **Each concern gets its own module** — don't add unrelated scripts to an existing module
