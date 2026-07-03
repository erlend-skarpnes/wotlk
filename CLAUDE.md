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

### Website DB user (`web`)

The website connects as a read-only `web` user with SELECT grants on specific tables — **when adding a table the website queries, also grant SELECT on it:**

```sql
GRANT SELECT ON acore_world.<table> TO 'web'@'%';
FLUSH PRIVILEGES;
```

Current non-default grants: `acore_world.website_achievement_points`, `acore_auth.uptime`, `acore_world.item_template`, `acore_world.creature_loot_template`, `acore_world.creature_template`, `acore_world.gameobject_loot_template`, `acore_world.gameobject_template`.

## Active Modules

### Third-party (on server, not in `modules/`)

| Module | Purpose |
|---|---|
| `mod-autobalance` | Scales creature difficulty to group size |
| `mod-aoe-loot` | Installed but **disabled** via `AOELoot.Enable = 0` |
| `mod-arac` | Allows all races to play all classes (SQL + DBC + client Patch-A.MPQ) |

### Custom (source in `modules/`)

| Module | Purpose |
|---|---|
| `mod-alt-level-boost` | Innkeeper gossip: alts can boost to highest-char level in 5-level steps |
| `mod-gnome-druid-forms` | Custom shapeshift models + per-form scale overrides for Gnome Druids |

Module config files live in `config/modules/`.

## Repo Structure

```
wotlk/
├── config/          # worldserver.conf, authserver.conf, modules/
├── modules/         # skeleton-module/ (template) + custom modules
├── sql/migrations/
│   ├── world/       # patches against acore_world
│   └── characters/  # patches against acore_characters
└── scripts/
    ├── deploy.sh    # apply pending migrations + sync configs
    ├── rollback.sh  # undo last applied migration
    └── status.sh    # show applied vs pending migrations
```

## Core Patches

Source edits that can't live in a module are stored as unified diffs in `patches/` and must be applied before building. Naming: `patches/<NNNN>-<kebab-description>.patch` (sequential, include a reason comment at top).

Apply via SSH: `ssh root@azerothcore 'cd ~/azerothcore-wotlk && patch -p1' < patches/0001-my-patch.patch`

| File | What it changes |
|---|---|
| `patches/0001-configurable-taxi-flight-speed.patch` | Adds `TaxiFlightSpeed` config key (default 32.0, server uses 64.0 for 2×) |

## Custom Modules

Custom C++ modules live in `modules/<mod-name>/` locally and on the server under `~/azerothcore-wotlk/modules/<mod-name>/`. Use `modules/skeleton-module/` as a starting point.

### Directory layout

```
modules/mod-my-feature/
├── src/
│   ├── mod_my_feature_loader.cpp   # entry point — required
│   └── mod_my_feature.cpp
├── conf/
│   └── mod_my_feature.conf.dist    # omit if no config needed
└── data/sql/db-world/              # SQL applied by AC on startup
```

### Naming conventions

| Thing | Pattern | Example |
|---|---|---|
| Module folder | `mod-<kebab-name>` | `mod-hearthstone-fix` |
| Loader function | `Add<mod_snake_name>Scripts()` | `Addmod_hearthstone_fixScripts()` |
| Script classes | `PascalCase` | `spell_hearthstone_cooldown_fix` |
| Conf key prefix | `MyModule.` | `HearthstoneFix.Enable` |

The loader function name replaces every `-` in the folder name with `_`, prepends `Add`, appends `Scripts`. This must match exactly — AzerothCore generates the call at build time.

### Build & deploy workflow

```bash
# 1. Copy module to server
scp -r modules/mod-my-feature root@azerothcore:~/azerothcore-wotlk/modules/

# 2. NEW module only — re-run cmake so it gets discovered
ssh root@azerothcore 'cd ~/azerothcore-wotlk/var/build/obj && cmake ~/azerothcore-wotlk'

# 3. Build — tell the user to run this on the server:
#    build

# 4. Stop server, install binary, restart
ssh root@azerothcore 'tmux send-keys -t world-session "server shutdown 5" Enter'
# wait ~10s, then:
ssh root@azerothcore 'cp ~/azerothcore-wotlk/var/build/obj/src/server/apps/worldserver ~/azerothcore-wotlk/env/dist/bin/worldserver'
ssh root@azerothcore 'tmux send-keys -t world-session "cd ~/azerothcore-wotlk && ./acore.sh run-worldserver" Enter'

# 5. Apply SQL migrations
./scripts/deploy.sh world
```

> **Do not run cmake/build commands autonomously over SSH** — tell the user to run `build` on the server.
> Use `server shutdown` + manual restart when installing a new binary (the simple-restarter relaunches instantly on clean exit, so the binary will be busy if you use `server restart`).

### Disabling a module from the build

```bash
cd ~/azerothcore-wotlk/var/build/obj
cmake ~/azerothcore-wotlk -DMODULE_MOD-PLAYERBOTS=disabled  # re-enable: =static
```

(`mod-playerbots` is disabled — thousands of files make builds very slow.)

### SQL for SpellScripts

SpellScripts need a `spell_script_names` row mapping spell ID → script name:

```sql
-- up: INSERT IGNORE INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES (12345, 'spell_my_fix');
-- down: DELETE FROM `spell_script_names` WHERE `spell_id` = 12345 AND `ScriptName` = 'spell_my_fix';
```

`ScriptName` must exactly match the class name passed to `RegisterSpellScript`.

## SQL Migration System

### File naming

```
sql/migrations/<db>/<NNNN>_<up|down>_<short_description>.sql
```

- Numbers zero-padded to 4 digits, sequential within each DB folder
- Every `_up_` must have a matching `_down_`
- `_up_` files should be idempotent (`INSERT IGNORE`, `UPDATE ... WHERE NOT EXISTS`, etc.)
- `_down_` must cleanly undo exactly what `_up_` did

### Workflow

```bash
./scripts/status.sh world          # see what's pending
./scripts/deploy.sh world          # apply pending migrations
./scripts/rollback.sh world --yes  # undo last migration (--yes skips prompt)
./scripts/deploy.sh --all          # migrations + rsync configs to server
```

### Module SQL dependencies

When installing a module, always check for required SQL:

```bash
find ~/azerothcore-wotlk/modules/<mod-name>/data/sql -name "*.sql"
```

Missing module SQL is a common crash source — always apply via a migration, never directly.

## Server Management

### Tmux sessions

| Session | Process |
|---|---|
| `world-session` | worldserver |
| `auth-session` | authserver |

```bash
ssh root@azerothcore 'tmux attach -t world-session'
ssh root@azerothcore 'tmux send-keys -t world-session "server restart 5" Enter'
```

The server runs under `acore.sh run-worldserver` → `simple-restarter` → worldserver. `server restart` exits 0, triggering a clean relaunch.

Nightly cron restarts at **3am**. Systemd units auto-start both servers on boot. See `docs/ops.md` for setup details if the VM is ever rebuilt.

## Conventions

- **Always write `_down_` before suggesting `_up_`** — rollback first
- **Check for online players before deploying or restarting** — query `characters WHERE online = 1`; never disrupt active players
- **Never run destructive commands without explicit confirmation**
- **Config changes go in the repo first**, then sync — never edit files directly on the server
- **One migration = one logical change** — split unrelated changes into separate numbered files
- **Module SQL goes through the migration system** — never apply directly
- **Each concern gets its own module** — don't add unrelated scripts to an existing module
- **Keep the website in sync** — update `website/src/routes/+page.svelte` "Server Features" section when server behaviour changes
