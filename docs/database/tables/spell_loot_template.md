# spell_loot_template

Loot table for spells with a "create random item" effect (`SPELL_EFFECT_CREATE_RANDOM_ITEM`) — e.g. some fishing bonus effects, treasure-generating trinkets/spells. Same schema/column semantics as [`creature_loot_template`](creature_loot_template.md).

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `spell_loot_template` (
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

Live snapshot on this server: 163 rows across 22 distinct `Entry` values.

## Columns

| Column | Meaning |
|---|---|
| `Entry` | Spell ID that has a `SPELL_EFFECT_CREATE_RANDOM_ITEM` effect — not a creature/item/GO entry. |

Example — `Entry = 57844`: 89% chance of "Succulent Clam Meat" (×1-3), 10% "Northsea Pearl" — a fishing bonus-catch spell.

## Relationships

- `Entry` → a spell in `spell_template`/DBC with a random-item-creation effect.
- `Item` → `item_template.entry`.
- `Reference` → `reference_loot_template.Entry`.

## Used by

- `src/server/game/Loot/LootMgr.cpp` — `LootTemplates_Spell` in-memory store, registered with `false` for standalone-entry validation (`LootStore("spell_loot_template", "spell id (random item creating)", false)`) — same "only reached by reference" pattern as `mail_loot_template`, since it's only ever looked up by a spell's own ID at cast time, not required to independently validate against another table.
- `src/server/game/Spells/SpellEffects.cpp` — the `SPELL_EFFECT_CREATE_RANDOM_ITEM` handler calls `player->AutoStoreLoot(m_spellInfo->Id, LootTemplates_Spell)`, directly granting the rolled item(s) to the player's inventory (no loot window).
- GM command `.reload spell_loot_template` hot-reloads this table.

## Modified by

Not yet touched by a migration on this server.

## Notes

- Unlike most loot-family tables, `AutoStoreLoot` puts the item straight into inventory rather than opening a loot window — relevant if a future migration wants to add a "chance of bonus item" spell effect.
