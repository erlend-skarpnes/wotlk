# reference_loot_template

Shared/reusable loot sub-tables. A row in `creature_loot_template` or `gameobject_loot_template` with `Reference != 0` points here instead of listing an item directly — this lets many creatures/objects share one loot pool (e.g. "gem pool" reused by every mining vein, "cloth pool" reused by every humanoid of a given level).

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `reference_loot_template` (
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

Live snapshot on this server: 24,094 rows across 1,507 distinct `Entry` (reference table ID) values.

## Columns

Same semantics as [`creature_loot_template`](creature_loot_template.md#columns) — `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`/`MaxCount`, `Comment` all behave identically. `Entry` here is the reference table's own ID (an arbitrary ID chosen by AzerothCore's dataset, not a creature/GO entry). `Reference` can itself point to another `reference_loot_template.Entry` — references can nest.

Example — `Entry = 12900` ("gem pool" used by Rich Thorium Vein):

| Entry | Item | Chance | GroupId | Comment |
|---|---|---|---|---|
| 12900 | 7910 | 12 | 1 | Star Ruby |
| 12900 | 12361 | 12 | 1 | Blue Sapphire |
| 12900 | 12363 | 80 | 1 | Arcane Crystal |
| 12900 | 12364 | 12 | 1 | Huge Emerald |

All share `GroupId = 1`, so exactly one of these rolls when the referencing row (e.g. `gameobject_loot_template.Entry = 12883, Reference = 12900`) wins its own roll.

## Relationships

- Referenced *from* `creature_loot_template.Reference`, `gameobject_loot_template.Reference`, and other `reference_loot_template.Reference` rows (nested references) — never referenced by a fixed foreign key, only by matching ID.
- `Item` → `item_template.entry`.
- **Self-reference is forbidden** — a `reference_loot_template` row must never set `Reference` equal to its own `Entry`; the core does not guard against this and it will crash.

## Used by

- `src/server/game/Loot/LootMgr.cpp` — `LootTemplates_Reference` is the in-memory store (`LootStore("reference_loot_template", "reference id", false)` — note `false` means it's not "entry required to exist independently", since these are only ever reached via another table's `Reference` column). `LoadLootTemplates_Reference()` calls `CheckLootRefs()` to validate every reference actually resolves, and `ReportUnusedIds()` to flag orphaned reference tables not pointed to by anything.
- Resolution happens throughout `LootTemplate::Process()`/`FillLoot()` wherever `item->reference` is non-zero — `LootTemplates_Reference.GetLootFor(std::abs(item->reference))`.
- GM command `.reload reference_loot_template` hot-reloads this table.

## Modified by

- `0003` — baseline reference loot template setup.
- `0020` — classic dungeon last-boss epic drop chance boosted to 20% (touches a reference table shared by several boss loot entries).
- `0021` — Arcane Crystal weight boosted 40→80 within reference `Entry = 12900` (gem pool for Rich Thorium Vein), paired with the `Chance` bump on the referencing `gameobject_loot_template` row.
- `0023` — interacts with `prospecting_loot_template` changes (ore prospecting shares reference tables with regular mining loot).

## Notes

- Because reference tables are shared across many creatures/objects, changing one `Entry` here can silently affect every loot table that references it — always check what points at a given reference ID before editing:
  ```sql
  SELECT * FROM creature_loot_template WHERE Reference = <id>;
  SELECT * FROM gameobject_loot_template WHERE Reference = <id>;
  ```
- `Chance` here still obeys the "sum ≤ 100 per `GroupId`" rule — when boosting one item's weight within a shared `GroupId` (like Arcane Crystal above), the other members' effective drop rate drops proportionally even though their own `Chance` value is unchanged, since they're competing for the same 100%.
