# website_achievement_points

Custom, website-only lookup table: achievement ID → point value. Not read by the worldserver at all — it exists purely because the game server reads achievement point data from `Achievement.dbc` at runtime and never persists it to MySQL, so the website (which has no DBC parser) needs its own copy to render a highscores/points page.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `website_achievement_points` (
  `achievement_id` INT UNSIGNED NOT NULL,
  `points`         TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (`achievement_id`)
) ENGINE=InnoDB COMMENT='WotLK achievement points lookup, sourced from Achievement.dbc'
```

Live snapshot on this server: 1,293 rows (matches "1293 achievements with points > 0" from `Achievement.dbc` for WotLK 3.3.5a, per the migration comment).

## Columns

| Column | Meaning |
|---|---|
| `achievement_id` | Achievement ID, matching the client's `Achievement.dbc` and the `character_achievement` table (characters DB, not documented here). |
| `points` | Point value for that achievement, as defined in `Achievement.dbc`. Achievements worth `0` points are excluded entirely — this table only has the 1,293 with `points > 0`. |

## Relationships

- `achievement_id` → `Achievement.dbc` (client data — this table is a MySQL-queryable mirror of one column from it) and, indirectly, → `acore_characters.character_achievement.achievement` (a player's earned achievements — join happens on the website side, in `acore_characters`, a separate database from this table).

## Used by

- **Nothing in the AzerothCore server source** — confirmed via `grep -rl website_achievement_points ~/azerothcore-wotlk/src` on the live server, zero matches. This table has no gameplay effect whatsoever.
- The website (a separate codebase/server, see root `CLAUDE.md` "Web Server" section) queries this table directly via the read-only `web` MySQL user, which has `GRANT SELECT ON acore_world.website_achievement_points` (confirmed live via `SHOW GRANTS FOR 'web'@'%'`).

## Modified by

- `0011` — created the table and seeded all 1,293 rows from `Achievement.dbc` (WotLK 3.3.5a). No other migration has touched it since.

## Notes

- **If `Achievement.dbc` content ever changes** (e.g. a core/DBC update changes point values or adds achievements), this table goes stale silently — nothing re-syncs it automatically. Re-derive and re-seed it from the updated DBC if that ever happens.
- Per root `CLAUDE.md`'s "Website DB user (`web`)" convention: any new table the website needs to query must get an explicit `GRANT SELECT` for the `web` user — this table already has it, but keep that convention in mind if a future website feature needs another world-DB table.
- Because this table is entirely disconnected from core gameplay logic, it's safe to modify/re-seed without any server restart or `.reload` — the website picks up changes on its own next query.
