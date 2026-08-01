# prospecting_loot_template

Loot table rolled when a player prospects a stack of ore with Jewelcrafting (yields gems). Same schema family as `creature_loot_template`, but `Entry` is an **ore item entry**, not a creature/GO ID.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `prospecting_loot_template` (
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

Live snapshot on this server: only 48 rows across 10 distinct `Entry` values — one row per (ore type × possible gem), so this is a small, easy-to-review table.

## Columns

Same semantics as [`creature_loot_template`](creature_loot_template.md#columns). The one different column:

| Column | Meaning |
|---|---|
| `Entry` | The **ore item's** `item_template.entry` (e.g. Tin Ore, Thorium Ore) — the item being prospected, not a creature or gameobject. |

Sample — `Entry = 2770` (an ore type):

| Entry | Item | Chance | GroupId | Comment |
|---|---|---|---|---|
| 2770 | 774 | 0 | 1 | Malachite |
| 2770 | 818 | 0 | 1 | Tigerseye |
| 2770 | 1210 | 10 | 0 | Shadowgem |

## Relationships

- `Entry` → `item_template.entry` (the ore being prospected — must have `ITEM_FLAG_IS_PROSPECTABLE` set, see below).
- `Item` → `item_template.entry` (the gem yielded).
- `Reference` → `reference_loot_template.Entry`, same as other loot tables.

## Used by

- `src/server/game/Loot/LootMgr.cpp` — `LootTemplates_Prospecting` in-memory store (`LootStore("prospecting_loot_template", "item entry (ore)", true)`).
- `src/server/game/Spells/SpellEffects.cpp` (`Spell::EffectProspecting`) — the actual trigger: requires the target item to have `ITEM_FLAG_IS_PROSPECTABLE` and a stack of **at least 5**; consumes skill via `UpdateGatherSkill(SKILL_JEWELCRAFTING, ...)` gated by `CONFIG_SKILL_PROSPECTING`; then calls `SendLoot(itemTarget->GetGUID(), LOOT_PROSPECTING)`, which pulls from this table.
- GM command `.reload prospecting_loot_template` hot-reloads this table.

## Modified by

- `0023` — prospecting loot rate/weight changes (paired with `reference_loot_template` changes in the same migration).

## Notes

- Whether an ore is prospectable at all is controlled by `item_template.Flags` (needs `ITEM_FLAG_IS_PROSPECTABLE`, `0x00040000`), not by this table — adding rows here for a non-prospectable ore does nothing until that flag is also set.
- The 5-ore minimum stack size is hardcoded in `EffectProspecting`, not configurable via SQL.
