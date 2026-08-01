# creature_equip_template

Visual-only weapon/item equipment sets for creatures — up to 3 "held" item slots (mainhand/offhand/ranged) shown on the model, purely cosmetic (no stat effect, no actual `item_template` ownership by the creature). Selected per-spawn via `creature.equipment_id`.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `creature_equip_template` (
  `CreatureID` int unsigned NOT NULL DEFAULT '0',
  `ID` tinyint unsigned NOT NULL DEFAULT '1',
  `ItemID1` int unsigned NOT NULL DEFAULT '0',
  `ItemID2` int unsigned NOT NULL DEFAULT '0',
  `ItemID3` int unsigned NOT NULL DEFAULT '0',
  `VerifiedBuild` int DEFAULT NULL,
  PRIMARY KEY (`CreatureID`,`ID`)
) ENGINE=InnoDB
```

Live snapshot on this server: 10,854 rows, `ID` ranges 1-8 (a template can offer several alternate equipment sets).

## Columns

| Column | Meaning |
|---|---|
| `CreatureID` | `creature_template.entry`. |
| `ID` | Equipment set index for this template (1-based) — a template can define multiple sets; which one a given spawn uses is chosen by `creature.equipment_id` (see below). |
| `ItemID1`/`ItemID2`/`ItemID3` | `item_template.entry` shown in mainhand/offhand/ranged visual slots. `0` = nothing shown in that slot. Each must be equippable in a hand slot — the loader rejects (forces to `0`, logs an error) any item that isn't a weapon/shield/ranged type. |

## Relationships

- `CreatureID` → `creature_template.entry`.
- `ItemID1..3` → `item_template.entry` (visual reference only — no `creature`/`character` inventory link).
- Selected by `creature.equipment_id` (on the **spawn** table, not `creature_template`): `-1` = pick a random defined `ID` for this `CreatureID` at spawn time, `0` = no equipment override (creature shows its base model with no held items from this table), a positive value = use that specific `ID`.

## Used by

- `src/server/game/Globals/ObjectMgr.cpp` — `LoadEquipmentTemplates()` (`SELECT CreatureID, ID, ItemID1, ItemID2, ItemID3 FROM creature_equip_template`); validates `CreatureID` exists and each `ItemID` is a real, hand-equippable item. `GetEquipmentInfo(entry, id)` is the runtime lookup — when called with `id == -1`, it randomly selects one of the defined `ID`s for that `CreatureID` and writes the chosen `ID` back into the passed reference (so a specific spawn's random roll is fixed at load, not re-rolled every time).
- `src/server/game/Globals/ObjectMgr.cpp` (`creature`-table loading, ~lines 2443/2622) — cross-validates every spawn's `equipment_id` resolves via `GetEquipmentInfo`, logging `have creature (Entries: ...) with equipment_id {} not found in table 'creature_equip_template', set to no equipment` and falling back to no equipment rather than failing the spawn.
- GM command `.reload creature_equip_template` hot-reloads this table.

## Modified by

Not yet touched by a migration on this server.

## Notes

- **Purely visual** — this table never grants an actual item, affects stats, or interacts with loot. It only changes what's rendered in the creature's hands.
- Random equipment selection (`creature.equipment_id = -1`) is resolved **once at load**, not re-rolled per-view or per-respawn within the same server session — if you want visual variety across many spawns of one template, define multiple `ID`s here and set each spawn's `equipment_id` to `-1`.
