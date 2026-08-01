# item_loot_template

Loot table for openable items — lockboxes, quest containers, anything with `item_template.Flags & ITEM_FLAG_HAS_LOOT` (`0x00000004`) that a player right-clicks to open. Same schema/column semantics as [`creature_loot_template`](creature_loot_template.md).

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `item_loot_template` (
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

Live snapshot on this server: 3,268 rows across 291 distinct `Entry` values.

## Columns

| Column | Meaning |
|---|---|
| `Entry` | The **container item's own** `item_template.entry` directly (e.g. `4632` Ornate Bronze Lockbox) — unlike most loot-family tables, this one *is* keyed by the object's own entry, not a separate loot ID. |

Example — `Entry = 4632` (Ornate Bronze Lockbox): one guaranteed row (`Chance = 100`) plus lower-chance bonus rows, each with a descriptive `Comment`.

## Relationships

- `Entry` → `item_template.entry` (the lockbox/container itself — must have `ITEM_FLAG_HAS_LOOT` set).
- `Item` → `item_template.entry` (contents).
- `Reference` → `reference_loot_template.Entry`.

## Used by

- `src/server/game/Loot/LootMgr.cpp` — `LootTemplates_Item` in-memory store (`LootStore("item_loot_template", "item entry", true)`).
- `src/server/game/Loot/LootItemStorage.cpp` — `LootTemplates_Item.GetLootFor(item->GetEntry())` resolves a container item's contents when opened.
- `src/server/game/Conditions/ConditionMgr.cpp` — supports `condition` rows scoped to this loot store (`GetLootForConditionFill`), same mechanism noted in `creature_loot_template`'s doc.
- GM command `.reload item_loot_template` hot-reloads this table.

## Modified by

Not yet touched by a migration on this server.

## Notes

- Because `Entry` is the container's own entry here (unlike `creature_loot_template.Entry`/`lootid` or `gameobject_loot_template.Entry`/`Data1`), no extra lookup step is needed before writing a migration — just use the item's `entry` directly.
- A container item also needs `ITEM_FLAG_HAS_LOOT` set on its `item_template` row to actually be openable — a row here alone doesn't make an item lootable.
