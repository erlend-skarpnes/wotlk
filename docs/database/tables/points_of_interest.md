# points_of_interest

Named map markers ("POIs") shown on the world map — a reusable pool of `(position, icon, name)` entries referenced by gossip options and quest POI links, rather than embedded directly in each quest/gossip row.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `points_of_interest` (
  `ID` int unsigned NOT NULL DEFAULT '0',
  `PositionX` float NOT NULL DEFAULT '0',
  `PositionY` float NOT NULL DEFAULT '0',
  `Icon` int unsigned NOT NULL DEFAULT '0',
  `Flags` int unsigned NOT NULL DEFAULT '0',
  `Importance` int unsigned NOT NULL DEFAULT '0',
  `Name` text NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB
```

Live snapshot on this server: 463 rows.

## Columns

| Column | Meaning |
|---|---|
| `ID` | Referenced by `gossip_menu_option.ActionPoiID` and `quest_poi.PoiID` — not tied to a specific quest or NPC itself, just a reusable marker. |
| `PositionX`/`PositionY` | World map coordinates. Validated at load — invalid coordinates are logged and the row is ignored (`have invalid coordinates (X: {} Y: {}), ignored`). |
| `Icon` | Map icon ID shown at this point. |
| `Flags` | Display flag bitmask (icon behavior, minor — check `POIFlags`-style usage in map/minimap rendering code if tuning). |
| `Importance` | Relative priority when multiple POIs are close together (affects which stays visible when zoomed out). |
| `Name` | Label shown on the map for this point. |

## Relationships

- `ID` ← `gossip_menu_option.ActionPoiID` (a gossip option that shows a map point when selected, e.g. "Show me on my map").
- `ID` ← `quest_poi.PoiID` (not documented here — links a quest's objective markers to entries here).
- Distinct from `quest_template`'s own inline `POIContinent`/`POIx`/`POIy`/`POIPriority` columns, which are a separate, single-point mechanism for the quest-giver's own location rather than objective markers.

## Used by

- `src/server/game/Globals/ObjectMgr.cpp` — `LoadPointsOfInterest()` (`SELECT ID, PositionX, PositionY, Icon, Flags, Importance, Name FROM points_of_interest`); `GetPointOfInterest(id)` is the runtime lookup, called when validating `gossip_menu_option.ActionPoiID` at gossip-menu load time (`if (gMenuItem.ActionPoiID && !GetPointOfInterest(gMenuItem.ActionPoiID))` — logs an error for a dangling reference).
- GM command `.reload points_of_interest` hot-reloads this table.

## Modified by

Not yet touched by a migration on this server.

## Notes

- If adding a custom gossip option with a "show on map" action, create (or reuse) a row here first, then point `gossip_menu_option.ActionPoiID` at it — a dangling `ActionPoiID` is caught and logged at load, so check server logs after adding a gossip option that references a new POI ID.
