# creature_default_trainer

Links a creature template to a trainer's spell list (`TrainerId`, shared across `trainer_spell`). This is what makes `npcflag & UNIT_NPC_FLAG_TRAINER` NPCs actually offer a specific set of trainable spells — one `TrainerId` can be reused by many creature templates (e.g. every generic "Class Trainer" NPC of a given class points at the same `TrainerId`).

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `creature_default_trainer` (
  `CreatureId` int unsigned NOT NULL,
  `TrainerId` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`CreatureId`)
) ENGINE=InnoDB
```

Live snapshot on this server: 807 rows.

## Columns

| Column | Meaning |
|---|---|
| `CreatureId` | `creature_template.entry` of the trainer NPC. Primary key — one trainer assignment per template (a creature template can only be linked to one `TrainerId`). |
| `TrainerId` | The shared trainer ID — joins to [`trainer_spell.TrainerId`](trainer_spell.md) to get the actual spell list, costs, and requirements. |

## Relationships

- `CreatureId` → `creature_template.entry`.
- `TrainerId` → `trainer_spell.TrainerId` (one-to-many: one trainer ID has many taught spells).

## Used by

- `src/server/game/Globals/ObjectMgr.cpp` — `LoadCreatureDefaultTrainers()` loads this into `_creatureDefaultTrainers` (map of `CreatureId → TrainerId`); logs an error and skips the row if `CreatureId` doesn't match an existing `creature_template`. `GetTrainer(creatureId)` is the runtime lookup used when a player opens a trainer window.
- GM command `.reload creature_default_trainer` hot-reloads this table.

## Modified by

- `0007` — linked the new custom squirrel-model Druid Trainer (`CreatureId = 900001`) to `TrainerId = 33` (the standard full Druid spell list), so the cloned template behaves as a complete trainer identical to the original entry 26324.

## Notes

- This table only decides **which** trainer spell list a creature template uses — the actual spells, costs, and requirements live in `trainer_spell`, keyed by `TrainerId`. When cloning a trainer creature template (as `0007` did), always add a `creature_default_trainer` row pointing at the *same* `TrainerId` as the original, rather than trying to duplicate the spell list into a new `TrainerId` — there's no need to copy `trainer_spell` rows for a reused spell list.
- Do not confuse this system with the unrelated, apparently-dead `npc_trainer` table — see [`npc_trainer`](npc_trainer.md) for why that table doesn't actually affect trainers on this server.
