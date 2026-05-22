# WotLK Private Server — Claude Guide

## Project Overview

Private AzerothCore (WotLK 3.3.5a) server for a small friend group, focused on solo/small-group play. This repo contains:

- **Config files** — `worldserver.conf`, `authserver.conf`, and per-module configs
- **SQL migrations** — versioned, rollback-capable patches for world and characters DBs
- **Scripts** — deploy, rollback, and status tooling that operates over SSH

## Server Setup

| Setting | Value |
|---|---|
| Server path | `/root/azerothcore-wotlk` |
| SSH target | `root@azerothcore` (Tailscale) |
| MySQL | `acore`/`acore` on `127.0.0.1:3306` |
| DBs | `acore_world`, `acore_characters`, `acore_auth` |

> Credentials are in `.env` (gitignored). Never commit `.env`.

## Active Modules

| Module | Purpose |
|---|---|
| `mod-autobalance` | Scales creature difficulty to group size |
| `mod-aoe-loot` | Area-of-effect looting on nearby corpses |
| `mod-arac` | Allows all races to play all classes (SQL + DBC + client Patch-A.MPQ) |

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
├── sql/
│   └── migrations/
│       ├── world/          # patches against acore_world
│       └── characters/     # patches against acore_characters
└── scripts/
    ├── deploy.sh           # apply pending migrations + sync configs
    ├── rollback.sh         # undo last applied migration
    └── status.sh           # show applied vs pending migrations
```

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
- Review and suggest edits to config files
- Run scripts and SSH commands — I'll always show you the command before executing
- Debug server crashes using GDB stack traces and logs

### Conventions I follow

- **Always write the `_down_` file before suggesting you run the `_up_`** — rollback first
- **I won't run destructive commands without explicit confirmation**
- **Config changes go in the repo first**, then get synced — no editing files directly on the server
- **One migration = one logical change** — I'll split unrelated changes into separate numbered files
- **Module SQL goes through the migration system** — never apply directly to the server
