# skinning_loot_template

Loot table rolled when a player skins a creature corpse. Same schema/column semantics as [`creature_loot_template`](creature_loot_template.md) — see that page for `Chance`/`QuestRequired`/`LootMode`/`GroupId`/`MinCount`/`MaxCount`/`Comment` and the `LootMode` bitmask table.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `skinning_loot_template` (
  `Entry` int unsigned NOT NULL DEFAULT '0',
  `Item` int unsigned NOT NULL DEFAULT '0',
  `Reference` int NOT NULL DEFAULT '0',
  `Chance` float NOT NULL DEFAULT '100',
  `QuestRequired` tinyint NOT NULL DEFAULT '0',
  `LootMode` smallint unsigned NOT NULL DEFAULT '1',
  `GroupId` tinyint unsigned NOT NULL DEFAULT '0',
  `MinCount` tinyint unsigned NOT NULL DEFAULT '1',
  `MaxCount` tinyint unsigned NOT NULL DEFAULT '1',
  `Comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Entry`,`Item`)
) ENGINE=InnoDB COMMENT='Loot System'
```

Live snapshot on this server: 1,940 rows across 539 distinct `Entry` values.

## Columns

| Column | Meaning |
|---|---|
| `Entry` | `creature_template.skinloot` — **not** `creature_template.entry` directly (usually set equal by convention, but not required). |

Example — `Entry = 193` (Blue Dragonspawn skinning):

| Entry | Item | Chance | GroupId | MinCount | MaxCount | Comment |
|---|---|---|---|---|---|---|
| 193 | 4304 | 27.09 | 1 | 1 | 2 | Thick Leather |
| 193 | 8165 | 9.31 | 1 | 1 | 1 | Worn Dragonscale |

## Relationships

- `Entry` → `creature_template.skinloot`.
- `Item` → `item_template.entry`.
- `Reference` → `reference_loot_template.Entry`.

## Used by

- `src/server/game/Loot/LootMgr.cpp` — `LootTemplates_Skinning` in-memory store (`LootStore("skinning_loot_template", "creature skinning id", true)`).
- GM command `.reload skinning_loot_template` hot-reloads this table.

## Modified by

Not yet touched by a migration on this server.

## Notes

- Requires the creature to actually support skinning (a Skinning-flagged creature type/rank and dead state) — a row here for a non-skinnable creature template does nothing until that's true.
- Same "resolve the real key column first" caution as the rest of the loot-template family: check `creature_template.skinloot`, don't assume it equals `entry`.
