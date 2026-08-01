# creature

Per-map spawn instances of a `creature_template`. This is what actually populates the world — one row per physical NPC/monster placed somewhere, each pointing back at a template for its stats/behavior/loot.

**Database:** `acore_world`

Live snapshot on this server: 149,878 rows.

## Schema

```sql
CREATE TABLE `creature` (
  `guid` int unsigned NOT NULL AUTO_INCREMENT,
  `id1`/`id2`/`id3` int unsigned NOT NULL DEFAULT '0',   -- creature_template.entry (id1 = primary; id2/id3 for alt difficulty)
  `map` smallint unsigned NOT NULL DEFAULT '0',
  `zoneId`/`areaId` smallint unsigned NOT NULL DEFAULT '0',
  `spawnMask` tinyint unsigned NOT NULL DEFAULT '1',
  `phaseMask` int unsigned NOT NULL DEFAULT '1',
  `equipment_id` tinyint NOT NULL DEFAULT '0',
  `position_x`/`position_y`/`position_z`/`orientation` float NOT NULL DEFAULT '0',
  `spawntimesecs` int unsigned NOT NULL DEFAULT '120',
  `wander_distance` float NOT NULL DEFAULT '0',
  `currentwaypoint` int unsigned NOT NULL DEFAULT '0',
  `curhealth`/`curmana` int unsigned NOT NULL,
  `MovementType` tinyint unsigned NOT NULL DEFAULT '0',
  `npcflag`/`unit_flags`/`dynamicflags` int unsigned NOT NULL DEFAULT '0',  -- per-spawn overrides, 0 = use template value
  `ScriptName` char(64),
  `CreateObject` tinyint unsigned NOT NULL DEFAULT '0',
  `Comment` text,
  PRIMARY KEY (`guid`)
) ENGINE=InnoDB
```

## Columns

| Column | Meaning |
|---|---|
| `guid` | Unique spawn ID (not the same as `creature_template.entry` — many `guid`s can share one `entry`). Auto-increment; this is what GM commands like `.npc` and `.tele` reference for a specific spawn. |
| `id1` | The `creature_template.entry` this spawn uses. `id2`/`id3` are alternate templates used by some instances for different difficulty modes — rarely populated on this server. |
| `map` | Map ID (0 = Eastern Kingdoms, 1 = Kalimdor, etc. — `Map.dbc`). |
| `zoneId`/`areaId` | Cached area info, informational — recomputed from position at runtime, not authoritative. |
| `spawnMask` | Bitmask of which raid/dungeon difficulty this spawn exists in (mostly relevant inside instances; `1` = default/normal for open-world spawns). |
| `phaseMask` | Bitmask for the phasing system — a player only sees this spawn if their active phase overlaps this mask (`1` = default phase, always visible). |
| `position_x`/`position_y`/`position_z`/`orientation` | World coordinates and facing. |
| `spawntimesecs` | Respawn delay in seconds after death. |
| `wander_distance` | Radius (yards) the creature randomly roams from its spawn point when `MovementType = 1`. `0` keeps it stationary except when scripted/waypoint-driven. |
| `MovementType` | `0` idle (stationary), `1` random (wanders within `wander_distance`), `2` waypoint (follows `creature_addon`/waypoint data, not covered here). |
| `npcflag`/`unit_flags`/`dynamicflags` | Per-spawn overrides — `0` means "inherit from `creature_template`"; a non-zero value here replaces the template's value for this spawn only. Used to make one spawn of a shared template behave differently (e.g. one guard non-attackable). |
| `ScriptName` | Per-spawn script override — takes priority over `creature_template.ScriptName` if set. |
| `CreateObject` | AzerothCore-specific visibility/creation control flag (not a retail column). |
| `Comment` | Free text, not read by the server — human/AI-readable note about what this spawn is (used in `0007`'s migration comment style: `"Druid Trainer at -6188, 392, 397 (Coldridge Valley)"`). |

## Relationships

- `id1`/`id2`/`id3` → `creature_template.entry`.
- `guid` — referenced by `creature_addon` (waypoints/equipment/auras, not documented here) and by other systems keyed on a specific spawn rather than a template.

## Used by

- `src/server/game/Entities/Creature/CreatureData.h` — the `CreatureData` struct.
- Loaded at world start and used to populate each map's active spawn list; per-spawn `npcflag`/`unit_flags`/`dynamicflags` overrides are applied on top of the template in `Creature::InitEntry()`/`LoadFromDB()`.
- GM command `.reload creature` (or `.tele`/`.npc` family commands) — hot-reload requires the specific creature to be respawned to pick up position/template changes; flag overrides usually apply on next load.

## Modified by

- `0007` — repointed one specific spawn (`guid = 95999`, the Coldridge Valley Druid Trainer) from the shared `id1 = 26324` template to the new one-off `id1 = 900001` template, without touching any of the ~24 other spawns using entry 26324 elsewhere in the world.

## Notes

- **`guid` identifies the spawn, `id1` identifies the template** — always double-check which one a migration should target. Editing `creature_template` affects every spawn of that entry; editing a `creature` row by `guid` affects only that one physical spawn. `0007` deliberately used the latter to avoid a global change.
- Per-spawn `npcflag`/`unit_flags`/`dynamicflags` being `0` does **not** mean "no flags" — it means "inherit the template's flags." To force a spawn to have *no* flags when the template has some, you'd need a non-zero override that explicitly clears them, not `0`.
