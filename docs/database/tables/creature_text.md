# creature_text

Modern, general-purpose text/emote/sound system for creature chat — say/yell/emote/whisper lines used by SmartAI (`SMART_ACTION_TALK`), core scripts, and C++ `CreatureAI` code via `CreatureTextMgr::SendChat()`. More flexible than the gossip-only [`npc_text`](npc_text.md): supports any chat type, broadcast range, and an attached sound.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `creature_text` (
  `CreatureID` int unsigned NOT NULL DEFAULT '0',
  `GroupID` tinyint unsigned NOT NULL DEFAULT '0',
  `ID` tinyint unsigned NOT NULL DEFAULT '0',
  `Text` longtext,
  `Type` tinyint unsigned NOT NULL DEFAULT '0',
  `Language` tinyint NOT NULL DEFAULT '0',
  `Probability` float NOT NULL DEFAULT '0',
  `Emote` int unsigned NOT NULL DEFAULT '0',
  `Duration` int unsigned NOT NULL DEFAULT '0',
  `Sound` int unsigned NOT NULL DEFAULT '0',
  `BroadcastTextId` int NOT NULL DEFAULT '0',
  `TextRange` tinyint unsigned NOT NULL DEFAULT '0',
  `comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`CreatureID`,`GroupID`,`ID`)
) ENGINE=InnoDB
```

Live snapshot on this server: 18,564 rows.

## Columns

| Column | Meaning |
|---|---|
| `CreatureID` | `creature_template.entry`. |
| `GroupID` | A named "line group" for this creature — e.g. group `0` might be "aggro yells", group `1` "kill yells". Scripts/SmartAI reference a `(CreatureID, GroupID)` pair, not a specific `ID`. |
| `ID` | Variant index within the group — when multiple rows share a `GroupID`, one is picked (weighted by `Probability`), same pattern as `npc_text`'s slots. |
| `Text` | The line itself. |
| `Type` | `ChatMsg` enum value — `0x01` Say, `0x06` Yell, `0x07` Whisper, `0x0A` Emote (text), `0x0C` Monster Say, `0x0E` Monster Yell, `0x0F` Monster Whisper, `0x10` Monster Emote. "Monster" variants use the creature's name as speaker rather than "You". |
| `Language` | `Language` enum — usually `0` (Universal, readable by everyone regardless of language skill). |
| `Probability` | Weight for random selection among rows sharing the same `GroupID` (not a 0-100 percentage requirement — relative weight, like the loot-template family's `Chance = 0` equal-weight convention). |
| `Emote` | Emote (`Emotes.dbc`/`Emote` enum) played alongside the text. |
| `Duration` | How long (ms) the text bubble/display persists. |
| `Sound` | Optional `SoundEntries.dbc` ID played alongside — validated at load (invalid sound IDs are logged and zeroed). |
| `BroadcastTextId` | Optional `broadcast_text.ID` — when set, supersedes `Text` with the broadcast text's content/localization. |
| `TextRange` | `CreatureTextRange` enum (`CreatureTextMgr.h`): `0` Normal (say/yell's natural radius, ignores team/GM-only filtering), `1` Area, `2` Zone, `3` Map, `4` World — how far the chat broadcasts regardless of the `Type`'s normal range. |
| `comment` | Free text, not read by the server — convention on this server (and stock AC data) is to note the creature name + line purpose. |

## Relationships

- `CreatureID` → `creature_template.entry`.
- `BroadcastTextId` → `broadcast_text.ID`.
- `Sound` → `SoundEntries.dbc`.
- `(CreatureID, GroupID)` ← referenced by SmartAI `SMART_ACTION_TALK` (`smart_scripts` table, not documented here) and by C++ `CreatureAI`/script code calling `sCreatureTextMgr->SendChat(creature, groupId, ...)`.

## Used by

- `src/server/game/Texts/CreatureTextMgr.cpp` — `LoadCreatureTexts()` loads this into `mTextMap`; validates `Sound` against `SoundEntriesStore`; `SendChat()` is the runtime entry point — picks a variant from the `(CreatureID, GroupID)` group weighted by `Probability`, then dispatches via `SendChatPacket` respecting `TextRange` (area/zone/map/world broadcast) and optional team/GM-only filtering.
- SmartAI's `SMART_ACTION_TALK` action (defined in `smart_scripts`) is the most common trigger — scripted NPC dialogue during events/combat/gossip typically goes through this table plus a SmartAI action, not hardcoded C++.
- GM command `.reload creature_text` hot-reloads this table.

## Modified by

Not yet touched by a migration on this server.

## Notes

- **This is the table to use for new custom NPC dialogue** (combat yells, scripted event lines, ambient chatter) — prefer it over `npc_text` unless the line is specifically for the gossip window, since it supports broadcast range, sound, and more chat types.
- `GroupID` is the stable reference point for scripts — when adding dialogue variants, add new `ID` rows under the same `GroupID` rather than creating a new group, so existing SmartAI/script references keep working and just get more variety.
