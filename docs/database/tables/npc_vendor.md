# npc_vendor

Vendor item lists — what a vendor NPC (`npcflag & UNIT_NPC_FLAG_VENDOR`) sells, at what stock/restock rate, and optionally at a non-gold "extended cost" (tokens/reputation/honor instead of or alongside gold).

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `npc_vendor` (
  `entry` int unsigned NOT NULL DEFAULT '0',
  `slot` smallint NOT NULL DEFAULT '0',
  `item` int NOT NULL DEFAULT '0',
  `maxcount` int unsigned NOT NULL DEFAULT '0',
  `incrtime` int unsigned NOT NULL DEFAULT '0',
  `ExtendedCost` int unsigned NOT NULL DEFAULT '0',
  `VerifiedBuild` int DEFAULT NULL,
  PRIMARY KEY (`entry`,`item`,`ExtendedCost`)
) ENGINE=InnoDB
```

Live snapshot on this server: 37,962 rows.

## Columns

| Column | Meaning |
|---|---|
| `entry` | `creature_template.entry` of the vendor NPC. |
| `slot` | UI tab/ordering position — only affects the order rows are processed at load (`ORDER BY entry, slot ASC, item, ExtendedCost`), not stored per-item at runtime beyond that ordering. |
| `item` | `item_template.entry` to sell. **Negative** value = a reference to another vendor's *entire* item list (reused vendor template, resolved via a separate reference-vendor lookup) rather than a single item. |
| `maxcount` | Stock cap. `0` = unlimited (never depletes, and must pair with `incrtime = 0`). Nonzero requires a nonzero `incrtime` — the loader logs an error and skips the row if only one of the two is set (`maxcount without incrtime` / `incrtime without maxcount`, both rejected). |
| `incrtime` | Seconds for stock to restock by 1, once depleted below `maxcount` by purchases. |
| `ExtendedCost` | `ItemExtendedCost.dbc` ID — when nonzero, the item costs (partly or fully) non-gold currency (honor, arena points, tokens) instead of/alongside `item_template.BuyPrice`. Validated at load — an invalid ID is rejected. |

## Relationships

- `entry` → `creature_template.entry` (must have `UNIT_NPC_FLAG_VENDOR` in `npcflag`, or the loader logs `have data for not creature template (Entry: {}) without vendor flag, ignore`).
- `item` → `item_template.entry` (positive), or another vendor `entry`'s full list (negative, magnitude of `item`).
- `ExtendedCost` → `ItemExtendedCost.dbc`.

## Used by

- `src/server/game/Globals/ObjectMgr.cpp` — `LoadVendors()`: `item_id < 0` triggers `LoadReferenceVendor(entry, -item_id, ...)` to pull in another vendor's item list wholesale; otherwise validates via `IsVendorItemValid()` (checks the vendor flag, item existence, `ExtendedCost` validity, and the `maxcount`/`incrtime` pairing) before adding to `_cacheVendorItemStore[entry]`.
- Also read by the "game event" system (`game_event_npc_vendor`) for event-only temporary vendor items, sharing the same validation path (log messages reference `(game_event_)npc_vendor` for both sources).
- GM command `.reload npc_vendor` hot-reloads this table.

## Modified by

Not yet touched by a migration on this server.

## Notes

- **A negative `item` value is a vendor-list reference, not a real item** — don't try to interpret it as an `item_template` lookup; it points at another `entry`'s whole list instead. Useful for reusing one master item list across many similar vendor NPCs without duplicating rows.
- `maxcount`/`incrtime` must both be zero or both be nonzero — a stock cap with no restock time (or vice versa) is rejected outright at load, not silently clamped.
