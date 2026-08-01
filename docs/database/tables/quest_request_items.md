# quest_request_items

Text and emotes shown on the "request items" screen — the quest-giver dialogue prompting a player to hand over collected items, or confirming completion for kill/explore-type quests before the reward screen appears. One row per quest, one-to-one with `quest_template`.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `quest_request_items` (
  `ID` int unsigned NOT NULL DEFAULT '0',
  `EmoteOnComplete` smallint unsigned NOT NULL DEFAULT '0',
  `EmoteOnIncomplete` smallint unsigned NOT NULL DEFAULT '0',
  `CompletionText` text,
  `VerifiedBuild` int DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB
```

Live snapshot on this server: 7,757 rows.

## Columns

| Column | Meaning |
|---|---|
| `ID` | `quest_template.ID` — one row per quest. |
| `EmoteOnComplete` | Emote (`Emotes.dbc` ID) played if the player has all required items/objectives when talking to the quest-giver. |
| `EmoteOnIncomplete` | Emote played if the player is still missing objectives. |
| `CompletionText` | The quest-giver's line shown on this screen (translations in `quest_request_items_locale`). |

## Relationships

- `ID` → `quest_template.ID` (one-to-one).
- `ID` → `quest_request_items_locale.Id` (translated `CompletionText`, not documented here).

## Used by

- `src/server/game/Globals/ObjectMgr.cpp` — `SELECT ID, EmoteOnComplete, EmoteOnIncomplete, CompletionText FROM quest_request_items`, loaded before `quest_offer_reward` in the quest-loading sequence; same orphaned-row validation (`Table 'quest_request_items' has data for quest {} but such quest does not exist`).
- GM command `.reload quest_request_items` hot-reloads this table.

## Modified by

Not yet touched by a migration on this server.

## Notes

- Only relevant for quests where the client shows a request-items confirmation step (typically item-collection objectives) — kill-only quests may skip straight to the reward screen, making a row here a no-op for those.
- Pairs with [`quest_offer_reward`](quest_offer_reward.md) to give a custom quest full turn-in flavor text; neither is required, both default to generic client text if absent.
