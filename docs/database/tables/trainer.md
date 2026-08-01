# trainer

Metadata for a trainer identity: what kind of trainer it is, what class/skill it's restricted to, and its greeting text. Joined with [`trainer_spell`](trainer_spell.md) (the actual spell list) and referenced by [`creature_default_trainer`](creature_default_trainer.md) (which NPCs use it) to fully define a trainer.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `trainer` (
  `Id` int unsigned NOT NULL DEFAULT '0',
  `Type` tinyint unsigned NOT NULL DEFAULT '2',
  `Requirement` mediumint unsigned NOT NULL DEFAULT '0',
  `Greeting` mediumtext,
  `VerifiedBuild` int DEFAULT '0',
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB
```

Live snapshot on this server: 126 rows.

## Columns

| Column | Meaning |
|---|---|
| `Id` | Trainer ID — same value as `trainer_spell.TrainerId` and `creature_default_trainer.TrainerId`. |
| `Type` | `Trainer::Type` enum (`Trainer.h`): `0` Class, `1` Mount, `2` Tradeskill (default), `3` Pet. |
| `Requirement` | Meaning depends on `Type`. For `Type = 0` (Class): the class ID the trainer is restricted to (`MAX_CLASSES` validated at load — invalid/out-of-range values are rejected with a logged error). For other types, may be unused or mean something else per trainer UI logic. |
| `Greeting` | The trainer's spoken greeting text shown when the trainer window opens. |

Example — `Id = 33` (Druid class trainer): `Type = 0` (Class), `Requirement = 11` (Druid class ID), `Greeting = "Hello, druid!  Ready for some training?"`. This is the `TrainerId` linked to the custom squirrel-model Druid Trainer from `creature_default_trainer`'s worked example.

## Relationships

- `Id` → `trainer_spell.TrainerId` (one-to-many: the actual taught spells).
- `Id` ← `creature_default_trainer.TrainerId` (which creature templates use this trainer).
- `Id` → `trainer_locale.Id` (translated `Greeting` text, not documented here).

## Used by

- `src/server/game/Globals/ObjectMgr.cpp` — `LoadTrainers()` reads `SELECT Id, Type, Requirement, Greeting FROM trainer`, builds the final `Trainer::Trainer` objects by merging in the spell list already collected from `trainer_spell`; for `Type::Class` trainers, also validates `Requirement` is a real class ID and populates `_classTrainers[classId]` (used to find "the" trainer for a given class, e.g. for dual-spec or class-trainer NPCs added generically).
- `src/server/game/Entities/Creature/Trainer.h` — defines `Trainer::Type` (`Class = 0, Mount = 1, Tradeskill = 2, Pet = 3`).

## Modified by

Not yet touched by a migration on this server (only `trainer_spell` and `npc_trainer` have been).

## Notes

- **This is the table to check first** when cloning or adding a trainer NPC (as `0007` did for the squirrel Druid Trainer) — find or create the right `Id` here, then point `creature_default_trainer.TrainerId` at it and ensure `trainer_spell` rows exist for that `Id`. All three tables need to agree for a trainer NPC to work correctly.
- Don't confuse `trainer.Id` (this table, and `trainer_spell.TrainerId`) with `npc_trainer.ID` — the latter is a different, apparently-unused legacy table (see [`npc_trainer`](npc_trainer.md)).
