# creature_template_model

Display models for a creature template. A template can list **multiple** models, each with a probability weight — the server rolls one at spawn/load time. This lets one creature type spawn with visual variety (e.g. different guard skin tones) while sharing all other stats.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `creature_template_model` (
  `CreatureID` int unsigned NOT NULL,
  `Idx` smallint unsigned NOT NULL DEFAULT '0',
  `CreatureDisplayID` int unsigned NOT NULL,
  `DisplayScale` float NOT NULL DEFAULT '1',
  `Probability` float NOT NULL DEFAULT '0',
  `VerifiedBuild` smallint unsigned DEFAULT NULL,
  PRIMARY KEY (`CreatureID`,`Idx`)
) ENGINE=InnoDB
```

Live snapshot on this server: 40,214 rows.

## Columns

| Column | Meaning |
|---|---|
| `CreatureID` | The creature template this model belongs to. |
| `Idx` | 0-based index — a template with multiple models lists them as `Idx = 0, 1, 2, ...`. Order matters for `ORDER BY Idx ASC` on load, but the actual model chosen at runtime is a weighted roll on `Probability`, not simply the first row. |
| `CreatureDisplayID` | Model ID — `CreatureDisplayInfo.dbc` entry. Must resolve to a valid model or the creature fails to load (see Notes). |
| `DisplayScale` | Per-model scale multiplier (in addition to `creature_template`/DBC base scale). |
| `Probability` | Relative weight for random selection when a template has more than one model row. If a template has exactly one model, `Probability` is ignored even if `0`. If all rows for a template sum to `0` total probability, the server logs a warning and treats all rows as equal weight (`1.0`); a negative total is an error, also normalized to equal weight. |

## Relationships

- `CreatureID` → `creature_template.entry` (one-to-many).
- `CreatureDisplayID` → `CreatureDisplayInfo.dbc` → `CreatureModelData.dbc` (client data, not a world DB table).

## Used by

- `src/server/game/Globals/ObjectMgr.cpp` — loads this table into `CreatureTemplate::Models` (`SELECT CreatureID, CreatureDisplayID, DisplayScale, Probability FROM creature_template_model ORDER BY Idx ASC`); logs `Creature (Entry: {}) does not have any existing display id in creature_template_model` if a template has zero rows; computes/normalizes `totalProbability` across a template's rows.
- `src/server/game/Entities/Creature/Creature.cpp` — `Creature::InitEntry()`/model selection rolls against `Probability`; logs `has no model defined in table 'creature_template_model', can't load` if the template has no rows at all (the creature will not spawn correctly), or `has no model {id} defined` if a specific referenced display ID is invalid.
- GM command `.reload creature_template_model` hot-reloads this table (existing world creatures typically need to be respawned/`.reload creature_template` alongside to visibly update).

## Modified by

- `0007` — added the `Idx = 0` row for the custom squirrel-model Druid Trainer (`CreatureID = 900001`, `CreatureDisplayID = 134`).
- `0008` — fixed 8 broken generic class-trainer models (`CreatureID` 26325–26332) whose original `CreatureDisplayID`s didn't resolve to valid models (making those NPCs invisible/fail-to-load in-game), replacing them with confirmed-working display IDs borrowed from real Coldridge Valley trainer NPCs.

## Notes

- **A missing row here is a hard failure, not a fallback to some default model** — every `creature_template` that's meant to spawn needs at least one row in this table, or the creature errors out on load (see the "no model defined" log line above). If you add a new `creature_template` row, always add a matching `creature_template_model` row in the same migration (as `0007` did).
- When a `CreatureDisplayID` turns out to be invalid/broken (creature invisible or fails to spawn), the fix is here, not in `creature_template` — swap in a display ID known to resolve, ideally borrowed from another creature confirmed working in-game (as `0008` did).
