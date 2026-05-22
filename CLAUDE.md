# WotLK Private Server — Claude Guide

## Project Overview

Private AzerothCore (WotLK 3.3.5a) server for a small friend group, focused on solo/small-group play. This repo contains:

- **Config files** — `worldserver.conf`, `authserver.conf`, and per-module configs
- **SQL migrations** — versioned, rollback-capable patches for world and characters DBs
- **Scripts** — deploy, rollback, and status tooling that operates over SSH

## Server Setup

| Setting | Value |
|---|---|
| Server path | `~/azerothcore-wotlk` |
| SSH target | defined in `.env` (see `.env.example`) |
| MySQL access | TBD — fill in `.env` when confirmed |

> Never commit `.env`. It contains real credentials and host info.

## Active Modules

| Module | Purpose |
|---|---|
| `mod-autobalance` | Scales creature difficulty to group size |
| `mod-aoe-loot` | Area-of-effect looting on nearby corpses |
| `mod-arac` | Allows all races to play all classes |

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

Examples:
```
sql/migrations/world/0001_up_add_custom_vendor.sql
sql/migrations/world/0001_down_add_custom_vendor.sql
sql/migrations/characters/0001_up_add_player_titles.sql
sql/migrations/characters/0001_down_add_player_titles.sql
```

Rules:
- Numbers are zero-padded to 4 digits and sequential within each DB folder
- Every `_up_` file **must** have a matching `_down_` file
- `_up_` files should be idempotent where possible (use `INSERT IGNORE`, `UPDATE ... WHERE NOT EXISTS`, etc.)
- `_down_` files must cleanly undo exactly what the `_up_` did

### Migration tracking

Applied migrations are recorded in a `schema_migrations` table created automatically on first run in each DB:

```sql
CREATE TABLE IF NOT EXISTS `schema_migrations` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `migration` VARCHAR(255) NOT NULL UNIQUE,
  `applied_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);
```

### Workflow

```bash
# See what's pending
./scripts/status.sh world

# Apply all pending migrations
./scripts/deploy.sh world

# Roll back the last applied migration
./scripts/rollback.sh world

# Apply + sync configs in one go
./scripts/deploy.sh --all
```

## Working with Claude

### What I can do

- Write SQL migration pairs (up + down) for any game content changes
- Review and suggest edits to config files
- Run `scripts/` over SSH — I'll always show you the command before executing
- Help debug issues by reading server logs over SSH

### Conventions I follow

- **Always write the `_down_` file before suggesting you run the `_up_`** — rollback first
- **I won't run destructive commands without explicit confirmation** — even if you've said "go ahead" earlier
- **Config changes go in the repo first**, then get synced — no editing files directly on the server
- **One migration = one logical change** — I'll split unrelated changes into separate numbered files

### SSH access

SSH is configured via `.env`. When I need to run something on the server I'll prefix it with the command I'm about to run so you can review it. You control execution.
