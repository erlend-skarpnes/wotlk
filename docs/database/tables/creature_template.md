# creature_template

Master definition for a creature "kind" (an NPC or monster type) — name, level range, faction, combat stats, AI, and flags. The `creature` table (per-map spawns) references this by `id1`/`id2`/`id3` to place instances in the world; a single template can be spawned many times across the map.

**Database:** `acore_world`

Live snapshot on this server: 29,948 rows.

## Schema (key columns)

```sql
CREATE TABLE `creature_template` (
  `entry` int unsigned NOT NULL,
  `difficulty_entry_1/2/3` int unsigned NOT NULL DEFAULT '0',  -- alternate template for 10/25-man or heroic
  `KillCredit1/2` int unsigned NOT NULL DEFAULT '0',
  `name` char(100) NOT NULL,
  `subname` char(100),                                          -- title shown under the name (e.g. "Trainer")
  `gossip_menu_id` int unsigned NOT NULL DEFAULT '0',
  `minlevel`/`maxlevel` tinyint unsigned NOT NULL DEFAULT '1',
  `exp` smallint NOT NULL DEFAULT '0',                           -- XP tier (0=normal,1=elite... see CreatureEliteType)
  `faction` smallint unsigned NOT NULL DEFAULT '0',              -- FactionTemplate.dbc id
  `npcflag` int unsigned NOT NULL DEFAULT '0',                   -- bitmask, see NPCFlags below
  `speed_walk`/`speed_run`/`speed_swim`/`speed_flight` float,
  `detection_range` float NOT NULL DEFAULT '20',
  `rank` tinyint unsigned NOT NULL DEFAULT '0',                  -- 0 normal,1 elite,2 rare elite,3 boss,4 rare
  `unit_class` tinyint unsigned NOT NULL DEFAULT '0',            -- stat template (1 Warrior,2 Paladin,4 Rogue,8 Mage)
  `unit_flags`/`unit_flags2` int unsigned,                       -- UnitFlags/UnitFlags2 bitmasks
  `family` tinyint NOT NULL DEFAULT '0',                         -- CreatureFamily.dbc (pet families)
  `type` tinyint unsigned NOT NULL DEFAULT '0',                  -- CreatureType enum, see below
  `lootid` int unsigned NOT NULL DEFAULT '0',                    -- key into creature_loot_template
  `pickpocketloot` int unsigned NOT NULL DEFAULT '0',            -- key into pickpocketing_loot_template
  `skinloot` int unsigned NOT NULL DEFAULT '0',                  -- key into skinning_loot_template
  `mingold`/`maxgold` int unsigned NOT NULL DEFAULT '0',
  `AIName` char(64) NOT NULL,                                    -- built-in C++ AI (empty = use ScriptName/default)
  `MovementType` tinyint unsigned NOT NULL DEFAULT '0',          -- 0 idle,1 random,2 waypoint
  `HealthModifier`/`ManaModifier`/`ArmorModifier`/`ExperienceModifier`/`DamageModifier` float NOT NULL DEFAULT '1',
  `RegenHealth` tinyint unsigned NOT NULL DEFAULT '1',
  `flags_extra` int unsigned NOT NULL DEFAULT '0',               -- CreatureFlagsExtra bitmask
  `ScriptName` char(64) NOT NULL,                                -- registered CreatureScript hook
  PRIMARY KEY (`entry`)
) ENGINE=InnoDB
```

## Key enums

**`npcflag` (`NPCFlags`, `UnitDefines.h`)** — bitmask, combine with `+`/`|`:

| Value | Flag | Meaning |
|---|---|---|
| `0x00000001` | `UNIT_NPC_FLAG_GOSSIP` | Has a gossip menu. |
| `0x00000002` | `UNIT_NPC_FLAG_QUESTGIVER` | Offers quests. |
| `0x00000010` | `UNIT_NPC_FLAG_TRAINER` | Is a trainer (any kind). |
| `0x00000020` | `UNIT_NPC_FLAG_TRAINER_CLASS` | Class trainer (teaches class spells via `creature_default_trainer`/`trainer_spell`). |
| `0x00000040` | `UNIT_NPC_FLAG_TRAINER_PROFESSION` | Profession trainer. |
| `0x00000080` | `UNIT_NPC_FLAG_VENDOR` | Generic vendor. |
| `0x00010000` | `UNIT_NPC_FLAG_INNKEEPER` | Innkeeper (hearthstone binding). |

Example: `npcflag = 48` = `0x30` = `TRAINER (0x10) + TRAINER_CLASS (0x20)` — a class trainer with the standard trainer gossip.

**`type` (`CreatureType`, `SharedDefines.h`)**: `1` Beast, `2` Dragonkin, `3` Demon, `4` Elemental, `5` Giant, `6` Undead, `7` Humanoid, `8` Critter, `9` Mechanical, `10` Not Specified, `11` Totem, `12` Non-combat Pet, `13` Gas Cloud.

## Relationships

- `entry` ← `creature.id1`/`id2`/`id3` (spawn instances — `id1` is the base template, `id2`/`id3` are alternates for other difficulty modes, rarely used on 3.3.5a solo/small-group content).
- `entry` → `creature_template_model.CreatureID` (one-to-many: a template can list several possible display models, rolled by `Probability`).
- `entry` → `creature_default_trainer.CreatureId` (if `npcflag` includes `TRAINER`).
- `lootid` → `creature_loot_template.Entry` (see that doc — not always equal to `entry`, though it usually is for one-off creatures).
- `pickpocketloot` → `pickpocketing_loot_template.Entry` (not documented here — out of current doc scope).
- `skinloot` → `skinning_loot_template.Entry` (not documented here).
- `AIName`/`ScriptName` → C++ `CreatureAI`/`CreatureScript` registrations (core or module code, not DB).

## Used by

- `src/server/game/Entities/Creature/CreatureData.h` — the `CreatureTemplate` struct itself (`lootid`, `pickpocketLootId`, `SkinLootId` field names shown above).
- `src/server/game/Entities/Unit/Unit.cpp` — `creature->GetCreatureTemplate()->lootid` resolves the loot table on death.
- `src/server/game/Handlers/NPCHandler.cpp` / `SkillHandler.cpp` — `GetNPCIfCanInteractWith(guid, UNIT_NPC_FLAG_TRAINER)` gates trainer interaction on `npcflag`.
- GM command `.reload creature_template` hot-reloads this table (existing spawned creatures need a `.reload` or respawn to pick up template changes fully in some cases — model/scale changes may need `.reload creature_template_model` too).

## Modified by

- `0007` — added a one-off `creature_template` row (`entry = 900001`) to give a single Coldridge Valley Druid Trainer spawn (`creature.guid = 95999`) a unique squirrel model, without affecting the other ~24 spawns of the original Druid Trainer template (`entry = 26324`). Worked example used throughout this doc.

## Notes

- **Cloning a template for a single unique spawn** (rather than editing the shared template) is the established pattern on this server when you want one specific spawn to differ — see `0007`'s approach: copy the original row's stats/flags into a new `entry`, then repoint just that one `creature.id1` at the new entry. This avoids affecting every other spawn of the original creature.
- When cloning, remember to also copy/create rows in `creature_template_model` (display) and, if the original was a trainer, `creature_default_trainer` (spell list) — a bare `creature_template` row alone won't have a model or (if flagged as trainer) a spell list.
