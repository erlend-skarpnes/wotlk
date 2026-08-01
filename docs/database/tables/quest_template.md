# quest_template

Master quest definition — objectives, rewards, level range, requirements, and log text. ~104 columns; grouped here by purpose rather than listed exhaustively (full reference: `src/server/game/Quests/QuestDef.h`/`.cpp`, or [AzerothCore wiki](https://www.azerothcore.org/wiki/quest_template)).

**Database:** `acore_world`

Live snapshot on this server: 9,464 rows.

## Column groups

### Identity & classification
`ID` (PK), `QuestType` (maps to client `QuestInfo.dbc` — values like `1` Elite, `21` Life, `41` PvP, `62` Raid, `81` Dungeon, `84` Escort — see `QuestTypes` enum), `QuestLevel` (`-1` = scales to player level), `MinLevel`, `QuestSortID` (`QuestSort.dbc` — zone/category grouping in the quest log), `QuestInfoID` (`QuestInfo.dbc` — quest log icon category), `SuggestedGroupNum`, `Flags` (see below).

### Requirements
`RequiredFactionId1`/`2` + `RequiredFactionValue1`/`2` (reputation gates), `RequiredPlayerKills` (PvP quests), `AllowableRaces` (bitmask, matches `item_template.AllowableRace` convention), `TimeAllowed` (timed quest seconds, `0` = untimed).

### Objectives
`RequiredNpcOrGo1..4` (**signed**: positive = creature entry to kill/interact, negative = gameobject entry to use — client expects `|0x80000000` for GOs, handled automatically) + `RequiredNpcOrGoCount1..4`, `RequiredItemId1..6` + `RequiredItemCount1..6` (items to collect/turn in), `ItemDrop1..4` + `ItemDropQuantity1..4` (items auto-granted for progress tracking on kill, separate from final rewards).

### Rewards
`RewardMoney`, `RewardMoneyDifficulty`, `RewardXPDifficulty`, `RewardItem1..4` + `RewardAmount1..4` (guaranteed), `RewardChoiceItemID1..6` + `RewardChoiceItemQuantity1..6` (player picks one), `RewardSpell`/`RewardDisplaySpell`, `RewardHonor`/`RewardKillHonor`, `RewardTitle`, `RewardTalents`, `RewardArenaPoints`, `RewardNextQuest` (auto-offered follow-up), `RewardFactionID1..5` + `RewardFactionValue1..5` + `RewardFactionOverride1..5` (reputation rewards).

### Text
`LogTitle`/`LogDescription` (quest log entry), `QuestDescription` (quest-giver detail text), `AreaDescription`, `QuestCompletionLog`, `ObjectiveText1..4` (per-objective progress text overrides).

### POI (map markers)
`POIContinent`, `POIx`/`POIy`, `POIPriority` — a single inline point; for multi-point objective markers see [`points_of_interest`](points_of_interest.md) + `quest_poi`/`quest_poi_points` (not documented here).

### Misc
`StartItem` (item that grants this quest when used, e.g. a quest-starting letter).

## `Flags` bitmask (`QuestFlags` enum, `QuestDef.h`)

| Value | Name | Meaning |
|---|---|---|
| `0x00000008` | `QUEST_FLAGS_SHARABLE` | Can be shared with party members. |
| `0x00000200` | `QUEST_FLAGS_HIDDEN_REWARDS` | Rewards only shown in the offer-reward screen, not the quest log. |
| `0x00000400` | `QUEST_FLAGS_TRACKING` | Auto-completed, never shown in quest log — used for background tracking quests. |
| `0x00001000` | `QUEST_FLAGS_DAILY` | Daily quest. |
| `0x00002000` | `QUEST_FLAGS_FLAGS_PVP` | Having this quest active forces PvP flag. |
| `0x00008000` | `QUEST_FLAGS_WEEKLY` | Weekly quest. |
| `0x00010000` | `QUEST_FLAGS_AUTOCOMPLETE` | Auto-completes on accept/turn-in. |

Several other bits are explicitly marked "Not used currently" in the source comment — check `QuestDef.h` before assuming a flag has effect.

## Relationships

- `ID` ← `creature_queststarter`/`creature_questender` (which NPCs offer/accept it), `gameobject_queststarter`/`gameobject_questender`, `quest_template_addon` (one-to-one, AC-specific extra fields), `quest_offer_reward` (turn-in reward text/emotes), `quest_request_items` (turn-in request text/emotes), `quest_greeting`, `quest_poi`/`quest_poi_points`.
- `RequiredNpcOrGo1..4` → `creature_template.entry` (positive) or `gameobject_template.entry` (negative, magnitude).
- `RequiredItemId1..6`/`ItemDrop1..4`/`RewardItem1..4`/`RewardChoiceItemID1..6`/`StartItem` → `item_template.entry`.
- `RewardNextQuest` → another `quest_template.ID`.

## Used by

- `src/server/game/Globals/ObjectMgr.cpp` — `LoadQuests()` reads the full column set in a fixed order (see source for exact SELECT) into `_questTemplates`.
- `src/server/game/Quests/QuestDef.h`/`.cpp` — the `Quest` struct itself; `QuestFlags`/`QuestSpecialFlags`/`QuestTypes` enums.
- GM command `.reload quest_template` hot-reloads this table (also needs `.reload quest_template_addon`/`quest_offer_reward`/`quest_request_items` for a full refresh since those are separate reload commands).

## Modified by

Not yet touched by a migration on this server.

## Notes

- **`RequiredNpcOrGo` sign matters** — positive means kill/interact-with-creature, negative means use-gameobject. Don't mix this up when adding kill/collect objectives.
- Quest log text is spread across `quest_template` (log/description text) plus [`quest_offer_reward`](quest_offer_reward.md) and [`quest_request_items`](quest_request_items.md) (turn-in screen text/emotes) — changing quest text often means touching all three tables, not just this one.
- `QUEST_FLAGS_TRACKING` quests never appear in the visible quest log — if a custom quest silently seems to "not exist" to the player, check this flag isn't accidentally set.
