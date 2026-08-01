# quest_offer_reward

Text and emotes shown on the "offer reward" screen — the quest-giver dialogue that appears just before a player clicks "Complete Quest" and picks their reward. One row per quest, one-to-one with `quest_template`.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `quest_offer_reward` (
  `ID` int unsigned NOT NULL DEFAULT '0',
  `Emote1`/`Emote2`/`Emote3`/`Emote4` smallint unsigned NOT NULL DEFAULT '0',
  `EmoteDelay1`/`EmoteDelay2`/`EmoteDelay3`/`EmoteDelay4` int unsigned NOT NULL DEFAULT '0',
  `RewardText` text,
  `VerifiedBuild` int DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB
```

Live snapshot on this server: 8,660 rows.

## Columns

| Column | Meaning |
|---|---|
| `ID` | `quest_template.ID` — one row per quest. |
| `Emote1..4` | Up to 4 sequential emotes (`Emotes.dbc` IDs) the quest-giver NPC plays during the offer-reward dialogue. |
| `EmoteDelay1..4` | Delay in milliseconds before each corresponding emote fires. |
| `RewardText` | The quest-giver's spoken line shown on the offer-reward screen (translations in `quest_offer_reward_locale`, keyed the same way). |

## Relationships

- `ID` → `quest_template.ID` (one-to-one).
- `ID` → `quest_offer_reward_locale.Id` (translated `RewardText`, not documented here).

## Used by

- `src/server/game/Globals/ObjectMgr.cpp` — `SELECT ID, Emote1, Emote2, Emote3, Emote4, EmoteDelay1, EmoteDelay2, EmoteDelay3, EmoteDelay4, RewardText FROM quest_offer_reward`, loaded right after `quest_template_addon`; logs `Table 'quest_offer_reward' has data for quest {} but such quest does not exist` for orphaned rows (same validation pattern as `quest_template_addon`). Locale variant loaded separately via `quest_offer_reward_locale`.
- GM command `.reload quest_offer_reward` hot-reloads this table.

## Modified by

Not yet touched by a migration on this server.

## Notes

- Distinct from [`quest_request_items`](quest_request_items.md) — that table covers the *request-items* screen (shown when turning in item-collection objectives, before rewards are offered), this one covers the *reward* screen. A quest can use either, both, or neither depending on its objective type.
- A quest with no row here just shows no special dialogue/emote on the reward screen — not an error, just a gap worth filling for custom quests that want more flavor.
