# gossip_menu_option

The individual selectable lines within a gossip menu — "Train me", "What do you have for sale?", "Show me on my map", etc. Keyed by `MenuID` (matches [`gossip_menu`](gossip_menu.md)) plus an `OptionID` within that menu.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `gossip_menu_option` (
  `MenuID` int unsigned NOT NULL DEFAULT '0',
  `OptionID` smallint unsigned NOT NULL DEFAULT '0',
  `OptionIcon` int unsigned NOT NULL DEFAULT '0',
  `OptionText` text,
  `OptionBroadcastTextID` int NOT NULL DEFAULT '0',
  `OptionType` tinyint unsigned NOT NULL DEFAULT '0',
  `OptionNpcFlag` int unsigned NOT NULL DEFAULT '0',
  `ActionMenuID` int unsigned NOT NULL DEFAULT '0',
  `ActionPoiID` int unsigned NOT NULL DEFAULT '0',
  `BoxCoded` tinyint unsigned NOT NULL DEFAULT '0',
  `BoxMoney` int unsigned NOT NULL DEFAULT '0',
  `BoxText` text,
  `BoxBroadcastTextID` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`MenuID`,`OptionID`)
) ENGINE=InnoDB
```

Live snapshot on this server: 4,674 rows.

## Columns

| Column | Meaning |
|---|---|
| `MenuID` | → `gossip_menu.MenuID`. |
| `OptionID` | Order/index of this option within the menu (0-based). |
| `OptionIcon` | Display icon — `GossipOptionIcon` enum (`GossipDef.h`): `0` white chat bubble, `1` vendor bag, `2` taxi/flight, `3` trainer book, `6` money bag, `9` crossed swords (battlemaster), `10` yellow dot, etc. |
| `OptionText` | The line's label text (translated in `gossip_menu_option_locale`). |
| `OptionBroadcastTextID` | Optional `broadcast_text.ID` alternative to `OptionText`. |
| `OptionType` | **Semantic** type — `GossipOptionNpc`/`GOSSIP_OPTION_*` enum (distinct from `OptionIcon`, which is only visual): `1` Gossip, `2` Questgiver, `3` Vendor, `4` Taxi Vendor, `5` Trainer, `6` Spirit Healer, `8` Innkeeper, `9` Banker, `13` Auctioneer, `16`/`17`/`18`/`20` trainer bonus options (unlearn talents, unlearn pet talents, dual-spec learn/info). Validated at load — an out-of-range value is rejected (`has unknown option id {}. Option will not be used`). |
| `OptionNpcFlag` | The `npcflag` bit (`NPCFlags`, see [`creature_template`](creature_template.md)) that must be set on the speaking NPC for this option to be relevant/shown. |
| `ActionMenuID` | If set, selecting this option jumps to another `gossip_menu.MenuID` (sub-menu navigation) instead of triggering the action directly. |
| `ActionPoiID` | → [`points_of_interest`](points_of_interest.md) — shows a map marker when this option is selected (e.g. "Show me on my map"). Validated at load against `GetPointOfInterest()`. |
| `BoxCoded` | If `1`, the confirmation box requires the player to type a code/number rather than just clicking OK (rare, used for a few special interactions). |
| `BoxMoney` | Copper cost shown/charged in the confirmation box (e.g. "This will cost 10 gold, continue?"). |
| `BoxText`/`BoxBroadcastTextID` | Text shown in the confirmation box before the action executes. |

## Relationships

- `MenuID` → `gossip_menu.MenuID`.
- `ActionMenuID` → another `gossip_menu.MenuID`.
- `ActionPoiID` → `points_of_interest.ID`.
- `OptionNpcFlag` → a bit from `creature_template.npcflag`'s `NPCFlags` enum.

## Used by

- `src/server/game/Globals/ObjectMgr.cpp` — `SELECT MenuID, OptionID, OptionIcon, OptionText, OptionBroadcastTextID, OptionType, OptionNpcFlag, ActionMenuID, ActionPoiID, BoxCoded, BoxMoney, BoxText, BoxBroadcastTextID FROM gossip_menu_option`; validates `OptionType < GOSSIP_OPTION_MAX` and that `ActionPoiID` (if set) resolves via `GetPointOfInterest()`.
- `src/server/game/Entities/Creature/GossipDef.h` — `GossipOptionIcon` and `GossipOptionNpc`/`GOSSIP_OPTION_*` enums.
- GM command `.reload gossip_menu_option` hot-reloads this table.

## Modified by

Not yet touched by a migration on this server.

## Notes

- **`OptionIcon` and `OptionType` are independent** — one controls what the option *looks like*, the other controls what it *does*. Don't assume setting the trainer icon (`3`) makes an option behave as a trainer link; `OptionType` must also be `5` (Trainer) for the actual trainer window to open.
- A dangling `ActionPoiID` is caught at load (logged, not silently ignored) — check server logs after adding a "show on map" option.
