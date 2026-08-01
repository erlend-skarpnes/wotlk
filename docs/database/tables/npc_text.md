# npc_text

Text pool for the gossip/quest-giver dialogue window — up to 8 "slots" (`text0` through `text7`), each with a male/female variant and a weighted probability, plus up to 6 emotes per slot. Referenced by [`gossip_menu.TextID`](gossip_menu.md) and by quest-giver default greeting text.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `npc_text` (
  `ID` int unsigned NOT NULL DEFAULT '0',
  -- repeated 8x (N = 0..7):
  `textN_0` longtext,              -- male/generic variant
  `textN_1` longtext,              -- female variant
  `BroadcastTextIDN` int NOT NULL DEFAULT '0',
  `langN` tinyint unsigned NOT NULL DEFAULT '0',
  `ProbabilityN` float NOT NULL DEFAULT '0',
  `emN_0` .. `emN_5` smallint unsigned NOT NULL DEFAULT '0',  -- up to 6 emotes for this slot
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB
```

Live snapshot on this server: 8,361 rows.

## Columns

| Column | Meaning |
|---|---|
| `ID` | Referenced by `gossip_menu.TextID`. |
| `textN_0`/`textN_1` | Text variants for slot `N` (0-7) — `_0` is the default/male text, `_1` is used if the target/speaker is female (falls back to `_0` if empty). |
| `BroadcastTextIDN` | Optional `broadcast_text.ID` reference — when set, the client can use the broadcast text's localization/sound instead of the raw `textN_0`/`textN_1` strings. |
| `langN` | `Language` enum value the text is spoken in (usually `0` = Universal). |
| `ProbabilityN` | Weight for randomly picking which of the 8 slots displays — slots with `Probability = 0` are effectively unused/disabled. |
| `emN_0..emN_5` | Up to 6 emotes (`Emotes.dbc` IDs) the NPC plays while slot `N` is showing. |

## Relationships

- `ID` ← `gossip_menu.TextID` (which gossip menu shows this text pool).
- `BroadcastTextIDN` → `broadcast_text.ID`.

## Used by

- `src/server/game/Globals/ObjectMgr.cpp` — loads this table into the NPC text store; the gossip window build code rolls a slot weighted by `ProbabilityN` each time the window opens, so the same NPC can show varied flavor lines.
- GM command `.reload npc_text` hot-reloads this table.

## Modified by

Not yet touched by a migration on this server.

## Notes

- This is the **older**, gossip-window-specific text system — for general creature chat/yell/emote text outside the gossip window (used by scripts, SmartAI, and combat barks), see [`creature_text`](creature_text.md) instead, which is more flexible (arbitrary chat type, broadcast range, sound).
- If only one slot is populated, its `Probability` value doesn't need to be `100` — a single nonzero-probability slot with no competing rows always wins.
