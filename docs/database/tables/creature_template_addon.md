# creature_template_addon

Per-**template** extra visual/behavioral data for a creature: mount, stand state, sheath state, emote, auto-cast auras, waypoint path, and visibility override. Applies to every spawn of the template unless a [`creature_addon`](creature_addon.md) row overrides it for a specific `guid`.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `creature_template_addon` (
  `entry` int unsigned NOT NULL DEFAULT '0',
  `path_id` int unsigned NOT NULL DEFAULT '0',
  `mount` int unsigned NOT NULL DEFAULT '0',
  `bytes1` int unsigned NOT NULL DEFAULT '0',
  `bytes2` int unsigned NOT NULL DEFAULT '0',
  `emote` int unsigned NOT NULL DEFAULT '0',
  `visibilityDistanceType` tinyint unsigned NOT NULL DEFAULT '0',
  `auras` text,
  PRIMARY KEY (`entry`)
) ENGINE=InnoDB
```

Live snapshot on this server: 11,989 rows.

## Columns

Same field meanings as [`creature_addon`](creature_addon.md) — `path_id`, `mount`, `bytes1` (stand state / pet talents / vis flag / anim tier packed byte field), `bytes2` (sheath state), `emote`, `visibilityDistanceType` (`VisibilityDistanceType` enum), `auras` (space-separated auto-cast spell IDs). The only difference is the key:

| Column | Meaning |
|---|---|
| `entry` | `creature_template.entry` — applies to **every** spawn of this template, unless overridden per-spawn by a `creature_addon` row for that specific `guid`. |

## Relationships

- `entry` → `creature_template.entry` (one-to-one).
- `path_id` → `waypoint_data.id`.
- `mount` → `CreatureDisplayInfo.dbc`.
- `auras` → spells in `spell_template`/DBC.
- Overridden per-instance by [`creature_addon`](creature_addon.md) (keyed by `guid`) when a specific spawn needs to differ.

## Used by

- `src/server/game/Globals/ObjectMgr.cpp` — `SELECT entry, path_id, mount, bytes1, bytes2, emote, visibilityDistanceType, auras FROM creature_template_addon`; same validation as `creature_addon` (mount/emote/visibility/aura spell ID checks), plus confirms `entry` exists in `creature_template` (`does not exist but has a record in 'creature_template_addon'`).
- `src/server/game/Entities/Creature/Creature.cpp` — applied the same way as `creature_addon`, but as the base value before any per-spawn override is layered on top.
- GM command `.reload creature_template_addon` hot-reloads this table.

## Modified by

Not yet touched by a migration on this server.

## Notes

- This is the table to use for template-wide flavor (e.g. "all Dire Bear Form-tagged creatures start seated" or "this creature type always has a passive aura") — for one-off spawn tweaks, use `creature_addon` instead so you don't affect every other instance of the template.
- If cloning a creature template for a one-off custom spawn (the pattern from `0007`'s squirrel Druid Trainer), remember this table too if the original template had a `creature_template_addon` row (e.g. an aura or stand state) you want the clone to keep — cloning `creature_template` alone doesn't copy this.
