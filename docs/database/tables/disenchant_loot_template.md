# disenchant_loot_template

Loot table rolled when an Enchanter disenchants an item. Same schema/column semantics as [`creature_loot_template`](creature_loot_template.md) — see that page for `Chance`/`QuestRequired`/`LootMode`/`GroupId`/`MinCount`/`MaxCount`/`Comment` and the `LootMode` bitmask table.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `disenchant_loot_template` (
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

Live snapshot on this server: 123 rows across 56 distinct `Entry` values.

## Columns

| Column | Meaning |
|---|---|
| `Entry` | `item_template.DisenchantID` — a disenchant-result-table ID, **not** the disenchanted item's own `entry`. Many items with different `entry`s (e.g. all epic 2H weapons in a given item-level bracket) typically share one `DisenchantID`, so one row set here covers many items at once. |

## Relationships

- `Entry` → `item_template.DisenchantID` (see [`item_template`](item_template.md) — `DisenchantID`/`RequiredDisenchantSkill` gate whether/how an item can be disenchanted at all).
- `Item` → `item_template.entry` (the dust/essence/shard yielded).
- `Reference` → `reference_loot_template.Entry`.

## Used by

- `src/server/game/Loot/LootMgr.cpp` — `LootTemplates_Disenchant` in-memory store (`LootStore("disenchant_loot_template", "item disenchant id", true)`); loader cross-checks every `item_template.DisenchantID` against this table, reporting non-existing/unused IDs the same way `creature_loot_template` checks `lootid`.
- GM command `.reload disenchant_loot_template` hot-reloads this table.

## Modified by

Not yet touched by a migration on this server.

## Notes

- Whether an item can be disenchanted at all is gated by `item_template.DisenchantID` being nonzero and `RequiredDisenchantSkill` — adding rows here for an item whose `DisenchantID` is `0` (or unset) does nothing.
- Since many items share one `DisenchantID`, a rate change here can silently affect a whole item-level/quality bracket at once — check `SELECT entry, name FROM item_template WHERE DisenchantID = <id>` before tuning to see the full blast radius.
