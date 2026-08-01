# gossip_menu

Links a gossip menu ID to the [`npc_text`](npc_text.md) pool it displays. Thin table — the actual selectable options live in [`gossip_menu_option`](gossip_menu_option.md), keyed by the same `MenuID`.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `gossip_menu` (
  `MenuID` int unsigned NOT NULL DEFAULT '0',
  `TextID` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`MenuID`,`TextID`)
) ENGINE=InnoDB
```

Live snapshot on this server: 6,080 rows. A `MenuID` can have multiple `TextID` rows (the game picks one, similar to `npc_text`'s own internal slot weighting, though typically one `MenuID` maps to exactly one `TextID` in practice).

## Columns

| Column | Meaning |
|---|---|
| `MenuID` | The gossip menu ID — matches `creature_template.gossip_menu_id` (for NPCs) or a gameobject's `GetGossipMenuId()` (for `GAMEOBJECT_TYPE_QUESTGIVER`/`GAMEOBJECT_TYPE_GOOBER`, see [`gameobject_template`](gameobject_template.md)). |
| `TextID` | `npc_text.ID` — which text pool this menu shows. Validated at load; a dangling `TextID` logs `Table gossip_menu entry {} are using non-existing TextID {}`. |

## Relationships

- `MenuID` → `creature_template.gossip_menu_id` or a gameobject's gossip menu ID.
- `MenuID` ← `gossip_menu_option.MenuID` (the selectable options for this menu).
- `TextID` → `npc_text.ID`.

## Used by

- `src/server/game/Globals/ObjectMgr.cpp` — `SELECT MenuID, TextID FROM gossip_menu` loads `_gossipMenusStore`; validates every `TextID` resolves to a real `npc_text` row.
- GM command `.reload gossip_menu` hot-reloads this table (also reload `gossip_menu_option` for a full refresh).

## Modified by

Not yet touched by a migration on this server.

## Notes

- Adding a custom gossip menu to an NPC needs all three pieces working together: `creature_template.gossip_menu_id` (or the creature/GO's `npcflag`/type) pointing at a `MenuID`, a `gossip_menu` row linking that `MenuID` to an `npc_text.ID`, and `gossip_menu_option` rows defining what's selectable.
- Multiple creature templates can share one `MenuID` (same pattern as loot IDs/trainer IDs across this doc set) — check what else uses a `MenuID` before editing it for one specific NPC's sake.
