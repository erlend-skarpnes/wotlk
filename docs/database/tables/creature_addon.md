# creature_addon

Per-**spawn** extra visual/behavioral data for a creature: mount, stand state, sheath state, emote, auto-cast auras, waypoint path, and visibility override. Same schema and field meaning as [`creature_template_addon`](creature_template_addon.md) — this one overrides for a single spawn instance (`guid`) instead of every spawn of a template.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `creature_addon` (
  `guid` int unsigned NOT NULL DEFAULT '0',
  `path_id` int unsigned NOT NULL DEFAULT '0',
  `mount` int unsigned NOT NULL DEFAULT '0',
  `bytes1` int unsigned NOT NULL DEFAULT '0',
  `bytes2` int unsigned NOT NULL DEFAULT '0',
  `emote` int unsigned NOT NULL DEFAULT '0',
  `visibilityDistanceType` tinyint unsigned NOT NULL DEFAULT '0',
  `auras` text,
  PRIMARY KEY (`guid`)
) ENGINE=InnoDB
```

Live snapshot on this server: 35,306 rows.

## Columns

| Column | Meaning |
|---|---|
| `guid` | `creature.guid` — this row applies to exactly one spawn instance. |
| `path_id` | Waypoint path ID (`waypoint_data.id`, not documented here) for `MovementType = 2` (waypoint) spawns. |
| `mount` | `CreatureDisplayInfo.dbc` ID the creature appears mounted on. Validated at load — an invalid display ID is rejected with a logged error. |
| `bytes1` | Packed byte field written into `UNIT_FIELD_BYTES_1`: byte 0 = stand state (`UnitStandStateType` — `0` stand, `1` sit, `3` sleep, `7` dead, `8` kneel, etc.), byte 1 = pet talent points (currently forced to `0`, unused), byte 2 = visibility flag, byte 3 = animation tier. |
| `bytes2` | Packed byte field written into `UNIT_FIELD_BYTES_2`: byte 0 = sheath state; bytes 2/3 currently forced to `0` (unused). |
| `emote` | Default idle emote ID played continuously. Validated at load. |
| `visibilityDistanceType` | `VisibilityDistanceType` enum (`ObjectDefines.h`): `0` Normal, `1` Tiny, `2` Small, `3` Large, `4` Gigantic, `5` Infinite (always visible server-wide) — overrides the default visibility/culling distance for this spawn. |
| `auras` | Space-separated list of spell IDs to permanently self-cast on spawn (buffs/passive auras). Validated at load: unknown spell IDs are rejected, duplicates are rejected, and temporary (non-permanent) auras are flagged (allowed but logged). |

## Relationships

- `guid` → `creature.guid` (one-to-one).
- `path_id` → `waypoint_data.id`.
- `mount` → `CreatureDisplayInfo.dbc`.
- `auras` → spells in `spell_template`/DBC.

## Used by

- `src/server/game/Globals/ObjectMgr.cpp` — `SELECT guid, path_id, mount, bytes1, bytes2, emote, visibilityDistanceType, auras FROM creature_addon`; validates `guid` exists in `creature`, validates `mount`/`emote`/`visibilityDistanceType`/each aura spell ID, logging and skipping invalid parts rather than failing the whole row.
- `src/server/game/Entities/Creature/Creature.cpp` — applies `bytes1`/`bytes2` via `SetByteValue(UNIT_FIELD_BYTES_1/2, offset, value)` at creature load; applies `mount`, `emote`, `visibilityDistanceType`, and casts each `auras` spell.
- GM command `.reload creature_addon` hot-reloads this table (existing spawned creatures typically need a respawn to visibly pick up changes).

## Modified by

Not yet touched by a migration on this server.

## Notes

- **Per-spawn override, not per-template** — use this (keyed by `guid`) when only one specific spawn needs a mount/aura/emote/visibility change; use [`creature_template_addon`](creature_template_addon.md) (keyed by `entry`) when every spawn of that creature type should have it. Same distinction as `creature` vs `creature_template` themselves.
- `auras` format is a plain space-separated string of spell IDs (e.g. `"12345 67890"`), not a CSV or JSON array — malformed entries are silently rejected per-spell at load with a logged error, not a hard failure.
