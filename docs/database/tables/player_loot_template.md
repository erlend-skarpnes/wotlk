# player_loot_template

Loot table for "removing an insignia" from an enemy player's corpse (bones) in PvP — battleground faction tokens (Alterac Valley, Wintergrasp, etc.). Same schema/column semantics as [`creature_loot_template`](creature_loot_template.md). Smallest and most narrowly-scoped table in the loot-template family — only 2 `Entry` values exist, ever.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `player_loot_template` (
  `Entry` int unsigned NOT NULL DEFAULT '0',
  `Item` int unsigned NOT NULL DEFAULT '0',
  `Reference` int NOT NULL DEFAULT '0',
  `Chance` float NOT NULL DEFAULT '100',
  `QuestRequired` tinyint NOT NULL DEFAULT '0',
  `LootMode` smallint unsigned NOT NULL DEFAULT '1',
  `GroupId` tinyint unsigned NOT NULL DEFAULT '0',
  `MinCount` tinyint unsigned NOT NULL DEFAULT '1',
  `MaxCount` tinyint unsigned NOT NULL DEFAULT '1',
  `Comment` text,
  PRIMARY KEY (`Entry`,`Item`)
) ENGINE=InnoDB COMMENT='Loot System'
```

Live snapshot on this server: 20 rows, exactly 2 distinct `Entry` values (`0` and `1`).

## Columns

| Column | Meaning |
|---|---|
| `Entry` | `TeamId` of the **looting player** (`TEAM_ALLIANCE = 0`, `TEAM_HORDE = 1` — `SharedDefines.h`), not anything to do with the victim. Only these two values are ever meaningful. |

Rows are grouped by battleground (per `Comment`, e.g. "Alterac Valley - Horde", "Wintergrasp - Alliance") but that's just documentation in the data — the actual key is only the looter's team.

## Relationships

- `Entry` → `TeamId` enum (`SharedDefines.h`), not a DB table.
- `Item` → `item_template.entry` (battleground currency/tokens, faction trophy items).

## Used by

- `src/server/game/Loot/LootMgr.cpp` — `LootTemplates_Player` in-memory store (`LootStore("player_loot_template", "team id", true)`).
- `src/server/game/Entities/Player/Player.cpp` — in the "remove insignia" corpse-loot branch (`guid.IsCorpse()`, `CORPSE_BONES` type): `loot->FillLoot(GetTeamId(), LootTemplates_Player, this, true)` — `GetTeamId()` here is the **looting player's own team**, called once per corpse the first time it's looted.

## Modified by

Not yet touched by a migration on this server.

## Notes

- This table is PvP-battleground-specific — low relevance for a solo/small-group-focused server unless battlegrounds are actively used. Included for completeness of the loot-template family rather than expected day-to-day editing.
- Since there are only 2 possible `Entry` values ever, there's no "resolve the key first" step needed here, unlike most of the family.
