# item_template

Master definition for every item in the game — stats, requirements, vendor price, sockets, on-use/on-equip spells, and more. ~150 columns; this doc groups them by purpose rather than listing every one (full reference: [AzerothCore wiki](https://www.azerothcore.org/wiki/item_template) or `src/server/game/Entities/Item/ItemTemplate.h`).

**Database:** `acore_world`

Live snapshot on this server: 46,096 rows.

## Column groups

### Identity & display
`entry` (PK), `class`/`subclass` (item class/subclass, e.g. weapon/armor/consumable — `ItemClass`/`Item*SubClass` enums), `name`, `displayid` (model), `Quality` (0=poor…6=artifact, drives name color), `InventoryType` (equip slot), `Flags`/`FlagsExtra` (bitmask, see below), `ScriptName` (registered `ItemScript` hook), `description`.

### Requirements
`RequiredLevel`, `RequiredSkill`/`RequiredSkillRank`, `requiredspell`, `AllowableClass`/`AllowableRace` (bitmasks, `-1` = all), `RequiredReputationFaction`/`RequiredReputationRank`, `RequiredCityRank`, `requiredhonorrank`.

### Economy & stacking
`BuyPrice`/`SellPrice` (copper), `BuyCount` (vendor stack size sold), `maxcount` (max a player can own, `0` = unlimited), `stackable` (max per inventory stack), `ContainerSlots` (bag size if this is a bag).

### Combat stats
`stat_type1..10` / `stat_value1..10` (paired arrays — `ItemModType` enum selects stat, e.g. STR/AGI/crit rating), `dmg_min1/2`/`dmg_max1/2`/`dmg_type1/2` (weapon damage), `armor`, `holy_res`/`fire_res`/`nature_res`/`frost_res`/`shadow_res`/`arcane_res`, `delay` (weapon speed, ms), `ammo_type`, `RangedModRange`, `block`, `ScalingStatDistribution`/`ScalingStatValue` (heirloom-style level-scaling stats).

### Item spells (on-use / on-equip / proc)
Five parallel slots, `_1` through `_5`, each an independent spell trigger:

| Column | Meaning |
|---|---|
| `spellid_N` | Spell cast by this slot. `0` = unused slot. |
| `spelltrigger_N` | When it fires — see `ItemSpelltriggerType` below. |
| `spellcharges_N` | Charges before the effect is consumed; negative values recharge over time (used by some trinkets). |
| `spellppmRate_N` | Procs-per-minute rate, only relevant when `spelltrigger_N = ITEM_SPELLTRIGGER_CHANCE_ON_HIT`. |
| `spellcooldown_N` | Cooldown in **milliseconds** for this slot specifically, or `-1` to fall back to the spell's own cooldown / category cooldown from spell data. |
| `spellcategory_N` | Spell category ID (shared-cooldown group), or `0`. |
| `spellcategorycooldown_N` | Category cooldown in ms, or `-1` for spell-data default. |

`ItemSpelltriggerType` values (`ItemTemplate.h`):

| Value | Name | Meaning |
|---|---|---|
| 0 | `ITEM_SPELLTRIGGER_ON_USE` | Right-click/use, subject to the normal post-equip cooldown. |
| 1 | `ITEM_SPELLTRIGGER_ON_EQUIP` | Fires once when equipped (passive aura apply). |
| 2 | `ITEM_SPELLTRIGGER_CHANCE_ON_HIT` | Proc on hit, rate from `spellppmRate_N`. |
| 4 | `ITEM_SPELLTRIGGER_SOULSTONE` | Special-cased soulstone resurrection trigger. |
| 5 | `ITEM_SPELLTRIGGER_ON_NO_DELAY_USE` | Use, but skips the default post-equip cooldown. |
| 6 | `ITEM_SPELLTRIGGER_LEARN_SPELL_ID` | Used with `SPELL_GENERIC_LEARN` to make the item teach a spell/recipe. |

**Important distinction (confirmed by this server's own migration 0005):** `spellcooldown_N`/`spellcategorycooldown_N` only affect the **client-side visual cooldown sweep** on the item icon — they do not by themselves enforce a server-side cooldown. The client's `SMSG_COOLDOWN_EVENT` packet carries no duration, so without an explicit value here the client falls back to `Spell.dbc`'s cooldown for the visual display, which can be wrong if the actual enforcement comes from [`spell_cooldown_overrides`](spell_cooldown_overrides.md). When overriding a spell's real cooldown via that table, also set the matching item's `spellcooldown_1`/`spellcategorycooldown_1` here (in milliseconds) so the client UI matches reality.

### Sockets & misc
`socketColor_1..3`/`socketContent_1..3`/`socketBonus`/`GemProperties`, `bonding` (BoE/BoP/BoU), `itemset`, `MaxDurability`, `duration`, `startquest`, `lockid`, `PageText`/`LanguageID`/`PageMaterial` (readable items), `HolidayId`, `DisenchantID`/`RequiredDisenchantSkill`, `FoodType`, `minMoneyLoot`/`maxMoneyLoot` (for `ITEM_FLAG_HAS_LOOT` lockboxes etc.), `flagsCustom` (AzerothCore-specific extra flags, not retail).

### `Flags` bitmask highlights (`ItemFlags` enum, `ItemTemplate.h`)

| Value | Name | Relevant to |
|---|---|---|
| `0x00000004` | `ITEM_FLAG_HAS_LOOT` | Lockboxes/junk items openable for loot (uses `minMoneyLoot`/`maxMoneyLoot` and/or a loot template). |
| `0x00040000` | `ITEM_FLAG_IS_PROSPECTABLE` | Required for an ore to work with [`prospecting_loot_template`](prospecting_loot_template.md) — table rows alone do nothing without this flag. |
| `0x20000000` | `ITEM_FLAG_IS_MILLABLE` | Herb equivalent of prospecting (Inscription). |
| `0x08000000` | `ITEM_FLAG_IS_BOUND_TO_ACCOUNT` | BoA items. |

Full enum (32 flags) in `src/server/game/Entities/Item/ItemTemplate.h`.

## Relationships

- `entry` ← referenced by loot tables (`creature_loot_template.Item`, `gameobject_loot_template.Item`, `reference_loot_template.Item`, `prospecting_loot_template.Item`), `npc_trainer.SpellID` (indirectly, via the spell taught), `skill_extra_item_template` (the spell that creates the item, not a direct FK).
- `itemset` → `item_set` (not documented here).
- `lockid` → Lock.dbc (client data, not a world DB table).

## Used by

- `src/server/game/Entities/Item/ItemTemplate.h` — all enums above (`ItemFlags`, `ItemFlags2`, `ItemSpelltriggerType`, `ItemModType`, etc.) and the `ItemTemplate` struct itself.
- Item spell casting/proc logic: `src/server/game/Entities/Player/Player.cpp` and `src/server/game/Entities/Item/Item.cpp` (equip/use handling reads the `spellid_N`/`spelltrigger_N` arrays).
- GM command `.reload item_template` hot-reloads this table.

## Modified by

- `0005` — set `spellcooldown_1`/`spellcategorycooldown_1` on Hearthstone (`entry = 6948`) to 600000ms (10 min) so the client's visual cooldown sweep matches the actual server-enforced cooldown from `spell_cooldown_overrides` (migration `0004`).

## Notes

- When adjusting a spell's real cooldown via `spell_cooldown_overrides`, check whether any item casts that spell (`spellid_N` match) and update the matching `spellcooldown_N`/`spellcategorycooldown_N` on this table too — otherwise the item's tooltip/icon cooldown sweep will visually disagree with the actual enforced cooldown (exactly the bug `0005` fixed for Hearthstone).
- `-1` is a meaningful default for `spellcooldown_N`/`spellcategorycooldown_N` (falls back to spell data) — don't "clean up" to `0`, which instead means "no cooldown" and can break intended shared cooldowns.
