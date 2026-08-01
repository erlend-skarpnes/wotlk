# trainer_spell

The actual spell list, cost, and requirements for each trainer. This is the table that matters at runtime — unlike the apparently-dead [`npc_trainer`](npc_trainer.md), `trainer_spell` is loaded by `ObjectMgr::LoadTrainers()` and directly drives what a trainer NPC offers and charges.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `trainer_spell` (
  `TrainerId` int unsigned NOT NULL,
  `SpellId` int unsigned NOT NULL DEFAULT '0',
  `MoneyCost` int unsigned NOT NULL DEFAULT '0',
  `ReqSkillLine` int unsigned NOT NULL DEFAULT '0',
  `ReqSkillRank` int unsigned NOT NULL DEFAULT '0',
  `ReqAbility1`/`ReqAbility2`/`ReqAbility3` int unsigned NOT NULL DEFAULT '0',
  `ReqLevel` tinyint unsigned NOT NULL DEFAULT '0',
  `VerifiedBuild` int DEFAULT '0',
  PRIMARY KEY (`TrainerId`,`SpellId`)
) ENGINE=InnoDB
```

Live snapshot on this server: 6,417 rows.

## Columns

| Column | Meaning |
|---|---|
| `TrainerId` | Shared trainer ID — same value as [`creature_default_trainer.TrainerId`](creature_default_trainer.md) and `trainer.Id` (the `trainer` table, not documented here, holds `Type`/`Requirement`/`Greeting` per trainer). |
| `SpellId` | The spell taught. **Must not be a talent** — the loader explicitly rejects any `SpellId` that has a talent cost (`GetTalentSpellCost`), logging an error and skipping the row. |
| `MoneyCost` | Cost in copper (100 copper = 1 silver, 10000 = 1 gold). E.g. `16000000` = 1600g. |
| `ReqSkillLine` | Skill line ID (`SkillLine.dbc`) the player must have, or `0` for none. Validated against `sSkillLineStore` at load. |
| `ReqSkillRank` | Minimum rank in that skill line. |
| `ReqAbility1`/`2`/`3` | Up to 3 prerequisite spells the player must already know. Each must resolve to a real spell or the whole row is rejected (all three are validated; any invalid one drops the row). |
| `ReqLevel` | Minimum character level, or `0` for none. |

## Relationships

- `TrainerId` → `trainer.Id` (trainer metadata: `Type` — e.g. Class/Mount/Pet/Tradeskill — and `Requirement`, e.g. class ID for class trainers) and → `creature_default_trainer.TrainerId` (which creature NPCs offer this trainer).
- `SpellId`/`ReqAbility1..3` → spells in `spell_template`/DBC.
- `ReqSkillLine` → `SkillLine.dbc`.

## Used by

- `src/server/game/Globals/ObjectMgr.cpp` — `ObjectMgr::LoadTrainers()`: reads this table first into a `trainerId → spells` map, then joins against the `trainer` table (`Id, Type, Requirement, Greeting`) to build the final `Trainer::Trainer` objects (`_trainers`), and populates `_classTrainers[classId]` for `Trainer::Type::Class` trainers. A `trainer_spell` row whose `TrainerId` doesn't match any `trainer` row logs `references non-existing trainer (TrainerId: ...), ignoring`.
- GM command `.reload trainer` (or similar reload covering the trainer subsystem) hot-reloads this table alongside `trainer` and `trainer_locale`.

## Modified by

- `0014` — set `MoneyCost = 16000000` (1600g) for Artisan Riding (`SpellId = 34091`) across the riding trainers using `TrainerId IN (35, 36)` (Ilsa Blusterbrew and the Northrend riding trainers) — this is the migration that actually takes effect in-game (compare to `0012`'s no-op change on `npc_trainer`).

## Notes

- **This is the table to edit for any trainer cost/requirement change** — not `npc_trainer`. If in doubt which trainer(s) to target, first find the `TrainerId` via `creature_default_trainer` for the specific NPC, or check which `TrainerId`s already teach the `SpellId` in question (`SELECT DISTINCT TrainerId FROM trainer_spell WHERE SpellId = ?`) to catch every trainer offering that spell, not just one.
- A row here silently disappears from the loaded trainer (with a logged error) if `SpellId` is a talent, or if any `ReqAbility*`/`ReqSkillLine` doesn't resolve — worth checking server logs after a migration that adds new rows.
