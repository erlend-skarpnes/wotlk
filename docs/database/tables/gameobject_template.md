# gameobject_template

Master definition for every gameobject "kind" in the world — chests, mining/herb nodes, doors, levers, quest objects, transports, etc. The `gameobject` table (per-map spawns, not documented here) references this by `entry` to place instances in the world. The `type` column selects which of ~36 behavior structs the 24 generic `Data0`–`Data23` columns are interpreted as — the same numeric column means something completely different depending on `type`.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `gameobject_template` (
  `entry` int unsigned NOT NULL DEFAULT '0',
  `type` tinyint unsigned NOT NULL DEFAULT '0',
  `displayId` int unsigned NOT NULL DEFAULT '0',
  `name` varchar(100) NOT NULL DEFAULT '',
  `IconName` varchar(100) NOT NULL DEFAULT '',
  `castBarCaption` varchar(100) NOT NULL DEFAULT '',
  `unk1` varchar(100) NOT NULL DEFAULT '',
  `size` float NOT NULL DEFAULT '1',
  `Data0` int unsigned NOT NULL DEFAULT '0',
  `Data1` int NOT NULL DEFAULT '0',
  `Data2` int unsigned NOT NULL DEFAULT '0',
  ... `Data3` through `Data23` (same int/int-unsigned pattern) ...
  `AIName` char(64) NOT NULL DEFAULT '',
  `ScriptName` varchar(64) NOT NULL DEFAULT '',
  `VerifiedBuild` int DEFAULT NULL,
  PRIMARY KEY (`entry`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB COMMENT='Gameobject System'
```

Live snapshot on this server: 21,581 rows. Type distribution (top 5): type 5 "Generic" (5,298), type 7 "Chair" (4,879), type 8 "Spell Focus" (4,603), type 10 "Goober" (1,111), type 3 "Chest" (1,347).

## Columns

| Column | Type | Meaning |
|---|---|---|
| `entry` | int unsigned | Primary key — referenced by `gameobject.id` (spawns) and by this server's `gameobject_loot_template.Entry` indirectly (see below). |
| `type` | tinyint unsigned | Selects the behavior/data layout — see `GameobjectTypes` enum below. Drives which core code path (`GameObject.cpp`) handles interaction. |
| `displayId` | int unsigned | Model ID (GameObjectDisplayInfo.dbc), controls visual appearance only. |
| `name` | varchar(100) | Display name shown on mouseover/tooltip. |
| `size` | float | Model scale multiplier. |
| `Data0`–`Data23` | int / int unsigned | Generic slots, meaning fully determined by `type` — see per-type structs in `GameObjectData.h`. Never assume a `Data*` index means the same thing across two different `type` values. |
| `AIName` | char(64) | Name of a registered GameObjectAI class to attach (C++ custom behavior), usually empty. |
| `ScriptName` | varchar(64) | Name of a registered `GameObjectScript` (core/module script hook), analogous to `creature_template.ScriptName`. |

### `type` — common values (`GameobjectTypes` enum, `GameObjectData.h`)

| Value | Name | Notes |
|---|---|---|
| 0 | `GAMEOBJECT_TYPE_DOOR` | |
| 1 | `GAMEOBJECT_TYPE_BUTTON` | |
| 2 | `GAMEOBJECT_TYPE_QUESTGIVER` | |
| **3** | **`GAMEOBJECT_TYPE_CHEST`** | Lootable via `gameobject_loot_template` — see that table's doc. `Data1` = lootId, `Data8` = required quest, `Data0` = lockId (Lock.dbc). |
| 5 | `GAMEOBJECT_TYPE_GENERIC` | Most common type on this server — decorative/no-interaction objects; `Data5` = questID. |
| 7 | `GAMEOBJECT_TYPE_CHAIR` | Sittable objects. |
| 8 | `GAMEOBJECT_TYPE_SPELL_FOCUS` | Invisible objects some spells require targeting near. |
| 10 | `GAMEOBJECT_TYPE_GOOBER` | Generic "interact to trigger stuff" objects (quest objects, levers) — `Data1` = questId, `Data10` = spellId cast on use. **Not** lootable via `gameobject_loot_template` (its `GetLootId()` always returns 0 for this type). |
| 25 | `GAMEOBJECT_TYPE_FISHINGHOLE` | Lootable via `gameobject_loot_template`, same as Chest — `Data1` = lootId. |

Full list of all ~36 types and their per-type `Data*` struct layouts: `src/server/game/Entities/GameObject/GameObjectData.h` (search `GameobjectTypes` and the anonymous union below it).

## Relationships

- `entry` ← referenced by `gameobject.id` (per-map spawn instances, not documented here).
- `entry` → `gameobject_loot_template.Entry` **only indirectly**, and only for `type = 3` (Chest) or `type = 25` (FishingHole): the actual join key is `Data1` (the loot ID), not `entry` itself — see [`gameobject_loot_template`](gameobject_loot_template.md) for the full explanation and a worked example.
- `displayId` → `gameobject_display_info` (client DBC, not a world DB table).

## Used by

- `src/server/game/Entities/GameObject/GameObjectData.h` — defines the `GameobjectTypes` enum and the per-type anonymous union (`chest`, `goober`, `_generic`, `fishinghole`, etc.) that `Data0`–`Data23` map onto; `GetLootId()`, `GetGossipMenuId()`, `GetEventScriptId()` and similar accessors switch on `type` to pick the right field.
- `src/server/game/Entities/GameObject/GameObject.cpp` — runtime behavior per type (chest opening, door toggling, goober `Use()` handling, etc.).

## Modified by

Not yet touched by a migration directly on this server — included here because `gameobject_loot_template` migrations (`0022`) require resolving values from this table first.

## Notes

- **Before writing a `gameobject_loot_template` migration**, always check this table first: `SELECT entry, type, Data0, Data1 FROM gameobject_template WHERE entry = <go_entry>` — confirm `type` is 3 or 25, then use `Data1` as the loot-table `Entry`.
- Because `Data*` meaning depends entirely on `type`, don't reuse column knowledge across types — always check the matching struct in `GameObjectData.h` before interpreting a `Data*` value for a type not covered above.
