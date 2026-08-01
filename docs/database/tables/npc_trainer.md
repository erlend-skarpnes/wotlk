# npc_trainer

> **⚠ Appears to be dead/unused on this server.** Exhaustively grepping `~/azerothcore-wotlk/src` (all `.cpp`/`.h`) and `~/azerothcore-wotlk/modules` on the live server for `npc_trainer` returns **zero matches**. The table exists in the base DB schema (`data/sql/base/db_world/npc_trainer.sql`) and gets populated by the standard AzerothCore world DB, but nothing in this fork's worldserver binary queries it. The trainer system actually used at runtime is [`trainer_spell`](trainer_spell.md) + [`creature_default_trainer`](creature_default_trainer.md), loaded via `ObjectMgr::LoadTrainers()`.
>
> **Practical impact:** migration `0012_up_artisan_riding_trainer_cost` set `npc_trainer.MoneyCost` for spell 34090, but since this table isn't read, that change most likely has **no effect in-game**. Migration `0014` made the equivalent change to `trainer_spell.MoneyCost` (spell 34091, `TrainerId IN (35, 36)`), which *is* the effective one. Treat `0012` as very likely a no-op — verify Artisan Riding's actual in-game cost against `0014`'s change, not `0012`'s, before assuming either did nothing.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `npc_trainer` (
  `ID` int unsigned NOT NULL,
  `SpellID` int NOT NULL,
  `MoneyCost` int unsigned NOT NULL DEFAULT '0',
  `ReqSkillLine` smallint unsigned NOT NULL DEFAULT '0',
  `ReqSkillRank` smallint unsigned NOT NULL DEFAULT '0',
  `ReqLevel` tinyint unsigned NOT NULL DEFAULT '0',
  `ReqSpell` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`SpellID`)
) ENGINE=InnoDB
```

Live snapshot on this server: 4,934 rows.

## Columns

Structurally near-identical to `trainer_spell` (`ID` here plays the role `TrainerId` plays there), but see the warning above — this appears to be a legacy/parallel table not wired into this fork's trainer-loading code.

| Column | Meaning (as designed, per schema/column names — not confirmed to matter at runtime) |
|---|---|
| `ID` | Presumed trainer ID. |
| `SpellID` | Spell taught. |
| `MoneyCost` | Copper cost. |
| `ReqSkillLine`/`ReqSkillRank` | Skill prerequisite. |
| `ReqLevel` | Level prerequisite. |
| `ReqSpell` | Spell prerequisite. |

## Relationships

None confirmed at runtime — no code path joins this to `creature_default_trainer` or anything else. Column names suggest it was intended to parallel `trainer_spell`.

## Used by

Nothing found — `grep -rli npc_trainer ~/azerothcore-wotlk/src ~/azerothcore-wotlk/modules` (all `.cpp`/`.h`) returns no results on the live server as of this writing. If a future AzerothCore core update starts reading this table, re-verify before relying on this doc's warning.

## Modified by

- `0012` — set `MoneyCost = 16000000` (1600g) for Artisan Riding (`SpellID = 34090`). Given the table appears unread, this migration is likely a no-op; the effective change is `0014` on `trainer_spell`.

## Notes

- **Before writing any migration against this table, first check whether it's actually read** by the current server binary (`grep -rn npc_trainer ~/azerothcore-wotlk/src` over SSH) — this doc was written after finding it wasn't. If you need to change a trainer's cost/requirements, target [`trainer_spell`](trainer_spell.md) instead.
- Worth a cleanup pass at some point: either confirm `0012` truly does nothing and consider removing/annotating it, or find the code path that does read this table if one turns up.
