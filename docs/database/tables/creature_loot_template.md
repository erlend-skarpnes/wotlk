# creature_loot_template

Defines what items a creature (NPC) can drop on death/loot, and with what chance. This is the table most of this server's SQL migrations touch (drop-rate boosts for epics, ore, crafting reagents, etc).

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `creature_loot_template` (
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
  PRIMARY KEY (`Entry`,`Item`,`Reference`,`GroupId`)
) ENGINE=InnoDB COMMENT='Loot System'
```

Live snapshot on this server: 93,663 rows across 7,797 distinct `Entry` values.

## Columns

| Column | Type | Meaning |
|---|---|---|
| `Entry` | int unsigned | Creature ID — matches `creature_template.entry`. All rows with the same `Entry` form one creature's loot table. |
| `Item` | int unsigned | Item ID from `item_template` to grant. `0` when the row is a pure `Reference` (see below). |
| `Reference` | int | Points to a `reference_loot_template.Entry` instead of a direct item. When this row is selected, the *entire* referenced template is processed (recursively, so a reference can itself grant many possible items). **Self-reference crashes the server** — never set `Reference` to the row's own `Entry`. Most rows have `Reference = 0` (not a reference). |
| `Chance` | float | Drop chance in percent (0–100). `0` means "equal chance" — split evenly among all rows in the same `GroupId` that also have `Chance = 0`. Within one `GroupId`, chances must not sum past 100. Ungrouped rows (`GroupId = 0`) are each rolled independently, not against each other. |
| `QuestRequired` | tinyint (bool) | `0` = always droppable. `1` = only drops if the looting player has an active quest that needs this item (checked against `quest_template`). |
| `LootMode` | smallint unsigned | Bitmask, see below. Row only considered when `(current lootMode & LootMode) != 0`. Setting this to `0` is a config error — the server logs `LootMode is equal to 0, item will never drop` and forces it back to `1`. |
| `GroupId` | tinyint unsigned | Groups rows into a mutually-exclusive roll: at most **one** item from a given `GroupId` (within the same `Entry`) drops per loot roll. `0` = ungrouped (row rolled on its own). Must be `< 128` (`1 << 7`) — the loader logs an error and skips the row otherwise. |
| `MinCount` / `MaxCount` | tinyint unsigned | Quantity range granted when the item drops (uniform random between them). `MinCount` must be ≥ 1. For `Reference` rows, `MaxCount` instead means how many times the referenced template is processed (i.e. how many items to pull from it). |
| `Comment` | varchar(255) | Free-text, not read by the server — used purely for human/AI readability (creature name + drop description). Always fill this in on new rows. |

### `LootMode` bitmask values

From `src/server/shared/SharedDefines.h` (`enum LootModes`):

| Value | Name | Meaning |
|---|---|---|
| `0x01` | `LOOT_MODE_DEFAULT` | Normal loot — what nearly every row on this server uses. |
| `0x02` | `LOOT_MODE_HARD_MODE_1` | Hard-mode / heroic variant 1 (raid difficulty gating). |
| `0x04` | `LOOT_MODE_HARD_MODE_2` | Hard-mode variant 2. |
| `0x08` | `LOOT_MODE_HARD_MODE_3` | Hard-mode variant 3. |
| `0x10` | `LOOT_MODE_HARD_MODE_4` | Hard-mode variant 4. |
| `0x8000` | `LOOT_MODE_JUNK_FISH` | Junk fishing catch (unrelated to creature loot in practice). |

Bits can be combined (it's a bitmask) — e.g. `3` = default + hard-mode-1. Since this is a solo/small-group server, essentially all rows use `1`.

## Relationships

- `Entry` → `creature_template.lootid`, **not** `creature_template.entry` directly (though by convention `lootid` is usually set equal to `entry` for one-off creatures — see the [`creature_template`](creature_template.md) doc). Multiple creature templates can share one loot table by pointing `lootid` at the same value, same pattern as `gameobject_template.Data1`.
- `Item` → `item_template.entry` (what actually drops).
- `Reference` → `reference_loot_template.Entry` (shared/reusable loot sub-tables, e.g. "Linen Cloth", "Small Pouch" tables reused across many creatures).
- `QuestRequired = 1` rows implicitly depend on `quest_template` (item must be a quest-required item for some active quest).

## Used by

- `src/server/game/Loot/LootMgr.cpp` — `LootTemplates_Creature` is the in-memory store loaded from this table (`LootStore("creature_loot_template", "creature entry", true)`); `LootTemplate::LootGroup::Roll()` implements the `GroupId`/`Chance` roll logic; reference resolution happens via `LootTemplates_Reference`.
- `src/server/game/Conditions/ConditionMgr.cpp` — the `condition` table can attach extra drop conditions keyed by `SourceGroup` = a `GroupId` in this table.
- `src/server/scripts/Commands/cs_reload.cpp` — GM command `.reload creature_loot_template` hot-reloads this table from DB without a server restart (useful when iterating on drop-rate changes).

## Modified by

- `0015` — creature/gameobject loot template baseline changes.
- `0018`, `0019`, `0025` — Thunderfury / Sulfuras solo-crafting drop-rate boosts.
- `0020` — classic dungeon last-boss epic drop chance boosted to 20% (also touches `reference_loot_template`).
- `0023` — interacts with `prospecting_loot_template` / `reference_loot_template` changes.

Check `sql/migrations/world/00NN_up_*.sql` for the exact `Entry`/`Item` rows each one touches before writing a new migration that overlaps them.

## Notes

- Because `Entry`/`Item`/`Reference`/`GroupId` form the primary key, you can have multiple rows for the same `Entry`+`Item` only if they differ in `Reference` or `GroupId` — this is how "same item, different roll group" rows coexist.
- When writing a drop-rate migration, prefer `UPDATE ... SET Chance = ... WHERE Entry = ? AND Item = ?` over blind `INSERT` — most target rows already exist.
- `.reload creature_loot_template` in-game lets you verify a migration's effect immediately without restarting the world server.
