# pickpocketing_loot_template

Loot table rolled when a Rogue pickpockets a humanoid creature. Same schema/column semantics as [`creature_loot_template`](creature_loot_template.md) — see that page for `Chance`/`QuestRequired`/`LootMode`/`GroupId`/`MinCount`/`MaxCount`/`Comment` and the `LootMode` bitmask table. The only difference is what `Entry` keys into.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `pickpocketing_loot_template` (
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

Live snapshot on this server: 13,525 rows across 3,135 distinct `Entry` values.

## Columns

| Column | Meaning |
|---|---|
| `Entry` | `creature_template.pickpocketloot` — **not** `creature_template.entry` directly, though by convention it's usually set equal to the creature's own entry. Multiple creature templates can share a pickpocket table by pointing `pickpocketloot` at the same value. |

## Relationships

- `Entry` → `creature_template.pickpocketloot`.
- `Item` → `item_template.entry`.
- `Reference` → `reference_loot_template.Entry` (same reference mechanism as `creature_loot_template`).

## Used by

- `src/server/game/Loot/LootMgr.cpp` — `LootTemplates_Pickpocketing` in-memory store (`LootStore("pickpocketing_loot_template", "creature pickpocket lootid", true)`); cross-checked against every `creature_template.pickpocketLootId` at load, same validation pattern as `creature_loot_template` vs `lootid`.
- `src/server/game/Entities/Player/Player.cpp` — `if (uint32 lootid = creature->GetCreatureTemplate()->pickpocketLootId) loot->FillLoot(lootid, LootTemplates_Pickpocketing, this, true);` — triggered by the Rogue Pick Pocket ability.
- GM command `.reload pickpocketing_loot_template` hot-reloads this table.

## Modified by

Not yet touched by a migration on this server.

## Notes

- Pickpocketing is typically a **one-shot per spawn instance** (can't repeat on the same creature until it respawns), unlike normal death loot — factor that in if tuning drop rates here versus `creature_loot_template`.
- Same "resolve the real key column first" caution as `creature_loot_template`/`gameobject_loot_template`: check `creature_template.pickpocketloot`, don't assume it equals `entry`.
