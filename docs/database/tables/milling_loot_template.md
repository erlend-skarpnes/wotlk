# milling_loot_template

Loot table rolled when a player mills a stack of herbs with Inscription — the herb equivalent of [`prospecting_loot_template`](prospecting_loot_template.md) (Jewelcrafting). Same schema/column semantics as [`creature_loot_template`](creature_loot_template.md).

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `milling_loot_template` (
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

Live snapshot on this server: 45 rows, one per distinct `Entry` (45 herb types) — smallest table in the loot-template family.

## Columns

| Column | Meaning |
|---|---|
| `Entry` | The **herb item's** `item_template.entry` (e.g. Goldclover, Adder's Tongue) — the item being milled, not a creature/GO. |

## Relationships

- `Entry` → `item_template.entry` (the herb — must have `ITEM_FLAG_IS_MILLABLE`, `0x20000000`, set; see [`item_template`](item_template.md)).
- `Item` → `item_template.entry` (the pigment yielded).

## Used by

- `src/server/game/Loot/LootMgr.cpp` — `LootTemplates_Milling` in-memory store (`LootStore("milling_loot_template", "item entry (herb)", true)`).
- `src/server/game/Spells/SpellEffects.cpp` — `Spell::EffectMilling` (the Inscription-milling counterpart to `EffectProspecting`): requires `ITEM_FLAG_IS_MILLABLE` and a stack of at least 5, gates skill-up via `CONFIG_SKILL_MILLING`, then calls `SendLoot(..., LOOT_MILLING)`.
- GM command `.reload milling_loot_template` hot-reloads this table.

## Modified by

Not yet touched by a migration on this server.

## Notes

- Whether a herb is millable at all is controlled by `item_template.Flags` (`ITEM_FLAG_IS_MILLABLE`), not by this table — same pattern as prospecting.
- The 5-item minimum stack is hardcoded in `EffectMilling`, not configurable via SQL.
