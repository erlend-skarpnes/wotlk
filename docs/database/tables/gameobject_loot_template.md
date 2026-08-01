# gameobject_loot_template

Defines what items a gameobject (chest, mining/herb node, fishing pool, junkbox, etc.) can yield when looted. Same schema family as `creature_loot_template` — same column semantics — but keyed by **loot ID**, not the gameobject's own entry.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `gameobject_loot_template` (
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

Live snapshot on this server: 17,967 rows across 1,156 distinct `Entry` (loot ID) values. Note the primary key here is only `(Entry, Item)` — unlike `creature_loot_template`'s `(Entry, Item, Reference, GroupId)` — so this table cannot have two rows for the same `Entry`+`Item` even with different `GroupId`/`Reference`.

## Columns

Column meanings are identical to [`creature_loot_template`](creature_loot_template.md#columns) (`Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`/`MaxCount`, `Comment`, `Reference` all work the same way — see that page for the full `LootMode` bitmask table). The one column that behaves differently:

| Column | Meaning |
|---|---|
| `Entry` | **Not** the gameobject's own entry. This is the loot table ID returned by `GameObjectTemplate::GetLootId()`, which only has a non-zero value for two GO types: `GAMEOBJECT_TYPE_CHEST` (type 3, reads `Data1`) and `GAMEOBJECT_TYPE_FISHINGHOLE` (type 25, also reads `Data1` — index 1 of its own data struct). Every other GO type returns `0` and never has rows here. **Many different `gameobject_template` rows can share one `Entry`/loot ID** — e.g. `Abercrombie's Crate` (167, `Data1=167`), `Crate of Foodstuffs` (249) and `Research Equipment` (251) both share `Data1=3881`. |

## Relationships

- `Entry` → `gameobject_template.Data1`, but **only** for `type = 3` (Chest) or `type = 25` (FishingHole) rows — not `gameobject_template.entry`, and meaningless for any other type. Always resolve the loot ID first before writing a migration — confirm via `SELECT entry, type, Data1 FROM gameobject_template WHERE entry = <go_entry>`.
- `Item` → `item_template.entry`.
- `Reference` → `reference_loot_template.Entry`.

## Used by

- `src/server/game/Loot/LootMgr.cpp` — `LootTemplates_Gameobject` is the in-memory store (`LootStore("gameobject_loot_template", "gameobject entry", true)`); `LoadLootTemplates_Gameobject()` cross-checks every `gameobject_template.GetLootId()` against this table and logs `ReportNonExistingId`/`ReportUnusedIds` for mismatches — a good way to catch a migration that targeted the wrong `Entry`.
- `src/server/game/Entities/GameObject/GameObject.cpp` — looting/quest-status checks call `LootTemplates_Gameobject.HaveQuestLootForPlayer(GetGOInfo()->GetLootId(), target)`, confirming the loot ID (not the GO entry) is always the lookup key at runtime.
- GM command `.reload gameobject_loot_template` (via `cs_reload.cpp`) hot-reloads this table.

## Modified by

- `0015` — baseline gameobject loot template changes (alongside `creature_loot_template`).
- `0021` — Arcane Crystal drop rate boost on Rich Thorium Vein (`Entry = 12883`), via both this table and `reference_loot_template`.
- `0022` — Dark Iron Ore drops doubled per node (`Entry = 11213`, resolved from `gameobject_template.Data1` for GO entry 165658 — see that migration's comment for the derivation).

## Notes

- **Always resolve the loot ID before writing a migration.** Never assume `Entry` in this table equals a gameobject's own `entry` — check `gameobject_template.Data1` first (see `0022_up_dark_iron_ore_drop_count.sql` for a worked example), or you will silently edit the wrong loot table (or one shared by unrelated objects).
- Because loot IDs are frequently shared across many `gameobject_template` rows, a single `UPDATE` here can affect every object using that loot ID — check `SELECT entry, name FROM gameobject_template WHERE Data1 = <lootId>` before changing shared IDs like mining-node loot (many ore-vein variants often share one loot ID).
