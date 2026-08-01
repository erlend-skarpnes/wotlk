# fishing_loot_template

Loot table rolled when a player successfully catches something while fishing. Same schema/column semantics as [`creature_loot_template`](creature_loot_template.md) — see that page for `Chance`/`QuestRequired`/`LootMode`/`GroupId`/`MinCount`/`MaxCount`/`Comment` and the `LootMode` bitmask table. Unlike every other sibling table, this one is **not** keyed by a creature/item/GO ID — it's keyed by **area**.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `fishing_loot_template` (
  `Entry` int unsigned NOT NULL DEFAULT '0',
  `Item` int unsigned NOT NULL DEFAULT '0',
  `Reference` int NOT NULL DEFAULT '0',
  `Chance` float NOT NULL DEFAULT '100',
  `QuestRequired` tinyint NOT NULL DEFAULT '0',
  `LootMode` smallint unsigned NOT NULL DEFAULT '1',
  `GroupId` tinyint unsigned NOT NULL DEFAULT '0',
  `MinCount` tinyint unsigned NOT NULL DEFAULT '1',
  `MaxCount` tinyint unsigned NOT NULL DEFAULT '1',
  `Comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Entry`,`Item`)
) ENGINE=InnoDB COMMENT='Loot System'
```

Live snapshot on this server: 251 rows across 218 distinct `Entry` values.

## Columns

| Column | Meaning |
|---|---|
| `Entry` | **Area ID** (`AreaTable.dbc`) — the zone/subzone the player is fishing in, not a creature/item/GO entry. Falls back to a generic pool when no area-specific entry exists (see Used by). |

## Relationships

- `Entry` → `AreaTable.dbc` (client data, not a world DB table) — matches `Player`'s current area at the time of the fishing catch.
- `Item` → `item_template.entry`.
- `Reference` → `reference_loot_template.Entry`.
- Distinct from [`gameobject_loot_template`](gameobject_loot_template.md)'s handling of `GAMEOBJECT_TYPE_FISHINGHOLE` (fishing *pools*, a placed gameobject with its own loot ID) — this table is for regular open-water fishing anywhere in a zone, not the special fishing-hole nodes.

## Used by

- `src/server/game/Loot/LootMgr.cpp` — `LootTemplates_Fishing` in-memory store (`LootStore("fishing_loot_template", "area id", true)`).
- Fishing catch resolution looks up the player's current area first, falling back to zone-wide or a generic "default fishing" entry if no exact area row exists (standard AzerothCore fishing behavior — check `Player::UpdateFishingSkill`/fishing spell effect code for the exact fallback chain if tuning this).
- GM command `.reload fishing_loot_template` hot-reloads this table.

## Modified by

Not yet touched by a migration on this server.

## Notes

- Junk catches (old boots, etc.) use `LOOT_MODE_JUNK_FISH` (`0x8000`) — see the `LootMode` bitmask table in `creature_loot_template`'s doc — rather than a separate table.
- Because `Entry` is an area ID rather than an object ID, there's no `creature_template`/`gameobject_template`/`item_template` column to cross-reference — go by `AreaTable.dbc` area IDs (or in-game `.gps`/`.debug area` output) to find the right `Entry` for a zone.
