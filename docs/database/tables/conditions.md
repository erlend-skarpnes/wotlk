# conditions

Generic, reusable condition system — attaches a boolean check to almost any other system (loot rows, gossip menus, spell targeting, vendor items, SmartAI events, quest availability, etc.) without needing bespoke columns on each of those tables. Column meaning is **entirely dependent on `SourceTypeOrReferenceId`** — the same numeric column means different things for different source types, similar to `gameobject_template`'s `Data0`-`Data23`.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `conditions` (
  `SourceTypeOrReferenceId` int NOT NULL DEFAULT '0',
  `SourceGroup` int unsigned NOT NULL DEFAULT '0',
  `SourceEntry` int NOT NULL DEFAULT '0',
  `SourceId` int NOT NULL DEFAULT '0',
  `ElseGroup` int unsigned NOT NULL DEFAULT '0',
  `ConditionTypeOrReference` int NOT NULL DEFAULT '0',
  `ConditionTarget` tinyint unsigned NOT NULL DEFAULT '0',
  `ConditionValue1` int unsigned NOT NULL DEFAULT '0',
  `ConditionValue2` int unsigned NOT NULL DEFAULT '0',
  `ConditionValue3` int unsigned NOT NULL DEFAULT '0',
  `NegativeCondition` tinyint unsigned NOT NULL DEFAULT '0',
  `ErrorType` int unsigned NOT NULL DEFAULT '0',
  `ErrorTextId` int unsigned NOT NULL DEFAULT '0',
  `ScriptName` char(64) NOT NULL DEFAULT '',
  `Comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`)
) ENGINE=InnoDB COMMENT='Condition System'
```

Live snapshot on this server: 14,614 rows. Top `SourceTypeOrReferenceId` values by count: `15` Gossip Menu Option (3,818), `13` Spell Implicit Target (3,789), `1` Creature Loot Template (1,625), `22` Smart Event (1,368), `14` Gossip Menu (1,271), `17` Spell (870), `19` Quest Available (705), `23` NPC Vendor (432), `10` Reference Loot Template (356).

## Columns

| Column | Meaning |
|---|---|
| `SourceTypeOrReferenceId` | Which system this condition attaches to — see `ConditionSourceType` below. A **negative** value means this row is a reusable reference group instead (see Notes). |
| `SourceGroup` | Meaning depends on `SourceTypeOrReferenceId` — for every `*_LOOT_TEMPLATE` source type, this is the loot table's `Entry` (e.g. for `CREATURE_LOOT_TEMPLATE`, the `creature_loot_template.Entry`/`lootid`). For gossip/menu types, a menu ID. |
| `SourceEntry` | Also source-type-dependent — for loot template types, the `Item` ID within that loot entry. |
| `SourceId` | Rarely used; per the core's own comment, "so far, only used in `CONDITION_SOURCE_TYPE_SMART_EVENT`". |
| `ElseGroup` | Group ID for "else" branching — lets you define OR-groups of conditions where any group passing satisfies the check. |
| `ConditionTypeOrReference` | The actual check to perform — see `ConditionTypes` below. A value pointing at another row's `SourceTypeOrReferenceId` (when negative there) reuses that row's condition set instead of defining a new one. |
| `ConditionTarget` | Which object the condition evaluates against when multiple are in play (e.g. player vs. the loot source) — `0` is usually "the player". |
| `ConditionValue1`/`2`/`3` | Parameters for the chosen `ConditionType` — meaning fully depends on which type (see table below). |
| `NegativeCondition` | If `1`, inverts the result (true becomes false). |
| `ErrorType`/`ErrorTextId` | Optional player-facing failure message when the condition blocks an action (e.g. gossip option hidden vs. shown-but-fails-with-message). |
| `ScriptName` | Optional registered `ConditionScript` for fully custom C++ logic instead of/alongside the built-in `ConditionType` check. |
| `Comment` | Free text, not read by the server. |

### Common `ConditionSourceType` values (`ConditionMgr.h`)

| Value | Name | `SourceGroup` / `SourceEntry` meaning |
|---|---|---|
| 1 | `CREATURE_LOOT_TEMPLATE` | `creature_loot_template.Entry` / `.Item` |
| 2 | `DISENCHANT_LOOT_TEMPLATE` | `disenchant_loot_template.Entry` / `.Item` |
| 3 | `FISHING_LOOT_TEMPLATE` | `fishing_loot_template.Entry` (area) / `.Item` |
| 4 | `GAMEOBJECT_LOOT_TEMPLATE` | `gameobject_loot_template.Entry` / `.Item` |
| 5 | `ITEM_LOOT_TEMPLATE` | `item_loot_template.Entry` / `.Item` |
| 6 | `MAIL_LOOT_TEMPLATE` | `mail_loot_template.Entry` / `.Item` |
| 7 | `MILLING_LOOT_TEMPLATE` | `milling_loot_template.Entry` / `.Item` |
| 8 | `PICKPOCKETING_LOOT_TEMPLATE` | `pickpocketing_loot_template.Entry` / `.Item` |
| 9 | `PROSPECTING_LOOT_TEMPLATE` | `prospecting_loot_template.Entry` / `.Item` |
| 10 | `REFERENCE_LOOT_TEMPLATE` | `reference_loot_template.Entry` / `.Item` |
| 11 | `SKINNING_LOOT_TEMPLATE` | `skinning_loot_template.Entry` / `.Item` |
| 12 | `SPELL_LOOT_TEMPLATE` | `spell_loot_template.Entry` / `.Item` |
| 13 | `SPELL_IMPLICIT_TARGET` | Spell ID / effect index — gates who a spell effect can target |
| 14 / 15 | `GOSSIP_MENU` / `GOSSIP_MENU_OPTION` | `gossip_menu`/`gossip_menu_option` IDs — most common source type on this server |
| 17 | `SPELL` | Spell ID — gates whether a spell can be cast at all |
| 19 | `QUEST_AVAILABLE` | Quest ID — gates quest-giver availability beyond the quest's own requirements |
| 22 | `SMART_EVENT` | SmartAI event row — the only source type that uses `SourceId` |
| 23 | `NPC_VENDOR` | `npc_vendor` row — gates a vendor item's visibility per-player |
| 28 | `PLAYER_LOOT_TEMPLATE` | `player_loot_template.Entry` (TeamId) / `.Item` |

Full list (~30 source types) and the ~65-entry `ConditionTypes` enum (value1/value2/value3 meaning documented inline per type, e.g. `CONDITION_AURA`, `CONDITION_ITEM`, `CONDITION_QUESTREWARDED`, `CONDITION_ACHIEVEMENT`, `CONDITION_REPUTATION_RANK`): `src/server/game/Conditions/ConditionMgr.h`.

## Relationships

- For every `*_LOOT_TEMPLATE` source type: `SourceGroup`/`SourceEntry` → that loot table's `Entry`/`Item` columns (see each loot table's own doc in this directory).
- `23` (`NPC_VENDOR`): `SourceGroup` → `npc_vendor`'s creature entry, `SourceEntry` → the item ID being sold.
- `19` (`QUEST_AVAILABLE`): `SourceEntry` → `quest_template.ID`.

## Used by

- `src/server/game/Conditions/ConditionMgr.cpp` — `isSourceTypeValid()` validates `SourceTypeOrReferenceId` at load (rejects unsupported types like `TERRAIN_SWAP`/`PHASE`/`GRAVEYARD`, explicitly noted as "not supported on 3.3.5a"); for loot-template source types, cross-checks `SourceGroup` against the matching `LootStore` (e.g. `LootTemplates_Creature.HaveLootFor(cond->SourceGroup)`) and logs `SourceGroup {} in 'condition' table, does not exist in '<table>', ignoring` if it doesn't resolve — same validation pattern seen from `creature_loot_template`'s doc.
- Every subsystem listed under `ConditionSourceType` calls into `ConditionMgr` at the relevant decision point (loot roll, gossip menu build, vendor list build, spell cast, SmartAI event check, etc.) to evaluate conditions attached to it.
- GM command `.reload conditions` hot-reloads this table.

## Modified by

Not yet touched by a migration on this server (but referenced conceptually — `creature_loot_template`'s doc notes `SourceGroup` validation against it).

## Notes

- **Always resolve `SourceGroup`/`SourceEntry` meaning from `SourceTypeOrReferenceId` first** — this table has no fixed column semantics; misreading which loot table (or non-loot system) a row targets is easy given the generic column names.
- A negative `SourceTypeOrReferenceId` (or `ConditionTypeOrReference`) means "this row is/reuses a reference group," not a literal source type — check the sign before interpreting either column.
- Given the current row count (14,614) is entirely stock AzerothCore data (no migration has touched this table yet), a first custom addition here should double-check `.reload conditions` behavior and test the specific gate (e.g. quest-conditional loot) in-game before assuming it's live.
