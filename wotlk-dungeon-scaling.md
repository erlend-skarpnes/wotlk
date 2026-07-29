# Dungeon difficulty reduction — investigation notes

Requests from friend feedback list:
- #7: Reduce difficulty on the last 3 WotLK 5-mans (Forge of Souls, Pit of Saron, Halls of Reflection), both heroic and normal.
- #8: Reduce difficulty on normal WotLK dungeons in general.

Both are **config changes** in `config/modules/AutoBalance.conf`, not SQL migrations — the `mod-autobalance` module already handles all difficulty scaling.

## Current state

- `AutoBalance.StatModifier.PerInstance` already applies a **0.8 global multiplier** (20% easier) to **trash mobs only**, for ~16 WotLK 5-mans including Forge of Souls (632), Pit of Saron (658), Halls of Reflection (668):
  ```
  AutoBalance.StatModifier.PerInstance="269 0.8, 540 0.8, 542 0.8, 543 0.8, 545 0.8, 546 0.8, 547 0.8, 548 0.8, 552 0.8, 553 0.8, 556 0.8, 557 0.8, 558 0.8, 560 0.8, 574 0.8, 575 0.8, 576 0.8, 578 0.8, 595 0.8, 599 0.8, 600 0.8, 601 0.8, 602 0.8, 604 0.8, 608 0.8, 619 0.8, 632 0.8, 650 0.8, 658 0.8, 668 0.8"
  ```
  Map IDs 632/658/668 (FoS/PoS/HoR) per widely-documented WotLK map ID values — **not** independently verified against this server's DB, since `map_dbc` mirror table is empty (0 rows) here.
- `AutoBalance.StatModifier.Boss.PerInstance` is **completely empty** — no boss discount anywhere, including FoS/PoS/HoR. This is likely where most of the perceived difficulty comes from.
- Per-instance overrides apply identically to heroic and normal, since WotLK 5-man heroic/normal share the same map ID (only raids differ in map ID by size). So a per-instance fix for FoS/PoS/HoR automatically covers "both heroic and normal" as requested in #7.
- Separately, there are difficulty-specific global base multipliers that stack on top of the per-instance table:
  - `AutoBalance.StatModifier.Global` — Normal 5-mans, currently `1.0`
  - `AutoBalance.StatModifierHeroic.Global` — Heroic 5-mans, currently `1.0`
  (each also has `.Health`, `.Mana`, `.Armor`, `.Damage` variants)

## Proposed approach (not yet implemented)

**#7 — FoS/PoS/HoR specifically:**
- Lower their existing trash-mob `StatModifier.PerInstance` value further (0.8 → e.g. 0.6)
- Add a `Boss.PerInstance` entry for map IDs 632, 658, 668 (currently unset / full 1.0) — bosses are likely the actual difficulty spike, not trash

**#8 — normal dungeons in general:**
- Lower `AutoBalance.StatModifier.Global` (and possibly `.Health`/`.Damage`) below 1.0
- Leave `AutoBalance.StatModifierHeroic.Global` untouched so heroics keep full difficulty

## Open question before implementing

If both are applied, FoS/PoS/HoR **normal** mode gets hit by both the #8 general normal-dungeon cut *and* the #7 specific per-instance cut — multiplicatively compounding (e.g. 0.8 × 0.6 = 0.48 effective). Need to decide:
- Is that intended (last-3 should end up extra easy on normal)?
- Or should #7's specific numbers be chosen with the #8 general cut already factored in, so the combined effect isn't more aggressive than intended?

## Reference

Local config file: `config/modules/AutoBalance.conf` (synced to server via `./scripts/deploy.sh --all` or manual rsync per repo convention — never edit directly on the server).
