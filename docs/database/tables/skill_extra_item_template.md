# skill_extra_item_template

Defines "bonus item" procs for crafting spells: when a player with the required specialization (e.g. Gnomish Engineering, Transmutation Master) crafts an item, there's a chance to create extra copies. One row = one craft-spell's proc definition. **Absence of a row means the proc cannot happen at all**, regardless of what specialization the player has.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `skill_extra_item_template` (
  `spellId` int unsigned NOT NULL DEFAULT '0' COMMENT 'SpellId of the item creation spell',
  `requiredSpecialization` int unsigned NOT NULL DEFAULT '0' COMMENT 'Specialization spell id',
  `additionalCreateChance` float NOT NULL DEFAULT '0' COMMENT 'chance to create add',
  `additionalMaxNum` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`spellId`)
) ENGINE=InnoDB COMMENT='Skill Specialization System'
```

Live snapshot on this server: 215 rows.

## Columns

| Column | Type | Meaning |
|---|---|---|
| `spellId` | int unsigned | The crafting spell (item-creation spell) this proc applies to. Primary key — one row per craft spell. |
| `requiredSpecialization` | int unsigned | Spell ID of the specialization the player must know (`player->HasSpell(...)`) for the proc to be possible at all — e.g. Gnomish Engineering, Transmutation Master (28672), Master/Artisan-tier recipes. |
| `additionalCreateChance` | float | Percent chance (checked against a roll, same scale as loot `Chance`) to create the bonus item(s) on a successful craft. |
| `additionalMaxNum` | tinyint | How many extra items can be produced when the proc hits. |

## Relationships

- `spellId` → a spell in `spell_template`/DBC (the crafting recipe itself).
- `requiredSpecialization` → a spell in `spell_template`/DBC (the specialization/mastery spell).
- No direct link to `item_template` in this table — the extra item created is the same item the base spell already produces (this table only decides *whether an extra copy happens*, not what item).
- Related sibling table (not yet documented here, not touched by any migration on this server): `skill_perfect_item_template` — same idea but for "perfect" quality procs (different item, e.g. Inscription's perfect scrolls), implemented by the neighboring `CanCreatePerfectItem()` in the same source file.

## Used by

- `src/server/game/Skills/SkillExtraItems.cpp`:
  - `LoadSkillExtraItemTable()` loads this table into the in-memory `SkillExtraItemStore` map keyed by `spellId`. Rows with `additionalCreateChance <= 0` are rejected at load time (logged as invalid) and rows referencing a nonexistent `requiredSpecialization` spell are skipped with an error.
  - `canCreateExtraItems(Player*, spellId, ...)` is the runtime check: **returns `false` immediately if `spellId` has no row in this table** — "no row = no proc, regardless of spec" (see `0024`'s migration comment, which relies on exactly this behavior to blacklist a proc). If a row exists, it also requires `player->HasSpell(requiredSpecialization)`.
- GM command `.reload skill_extra_item_template` hot-reloads this table.

## Modified by

- `0024` — `DELETE`d the 12 cyclic Eternal-element transmute spells (53771–53784) from this table to blacklist Transmutation Master's bonus-item proc on them specifically, while leaving their cooldowns removable via `spell_cooldown_overrides` without risking an infinite-doubling loop (those transmutes are reversible pairs, e.g. Fire↔Water).

## Notes

- **Deleting a row is a valid and complete way to disable a proc for one spell** — no need to zero `additionalCreateChance` or add a "disabled" flag; a missing row is the disabled state, checked directly in `canCreateExtraItems()`.
- When re-enabling a proc that was deleted, you need all three values (`requiredSpecialization`, `additionalCreateChance`, `additionalMaxNum`) — check a sibling spell in the same recipe family for reasonable defaults rather than guessing.
