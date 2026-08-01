# spell_cooldown_overrides

DB-driven override for a spell's cooldown values, applied globally to that spell's `SpellInfo` at server startup — the standard AzerothCore way to change a cooldown without patching `Spell.dbc`. This is the table most of this server's "reduce cooldown for solo/small-group play" migrations use.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `spell_cooldown_overrides` (
  `Id` int unsigned NOT NULL,
  `RecoveryTime` int unsigned NOT NULL DEFAULT '0',
  `CategoryRecoveryTime` int unsigned NOT NULL DEFAULT '0',
  `StartRecoveryTime` int unsigned NOT NULL DEFAULT '0',
  `StartRecoveryCategory` int unsigned NOT NULL DEFAULT '0',
  `Comment` text,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB
```

Live snapshot on this server: 1,091 rows — the large majority are stock AzerothCore data for NPC ability cooldowns (e.g. `Id 45` "Harb Foulmountain - War Stomp"), not custom to this server. This server's own migrations add/modify a small subset (see Modified by).

## Columns

| Column | Meaning |
|---|---|
| `Id` | The spell ID this override applies to. Primary key — one override row per spell. |
| `RecoveryTime` | New cooldown in **milliseconds**, replaces `SpellInfo::RecoveryTime` (the spell's own individual cooldown) if different from the DBC value. |
| `CategoryRecoveryTime` | New shared-category cooldown in ms (affects every spell in the same `spellCategory`), replaces `SpellInfo::CategoryRecoveryTime` if different. |
| `StartRecoveryTime` | Overrides the GCD-related start-recovery timer if different from DBC value. |
| `StartRecoveryCategory` | Overrides the start-recovery category if different from DBC value. |
| `Comment` | Free text, not read by the server — always fill in with the reasoning (this server's convention: note the original value and why it changed, e.g. `"Reduced from 86400000 (24h) to 7200000 (2h) for small-group server"`). |

`0` is a valid, meaningful value for `RecoveryTime`/`CategoryRecoveryTime` — it means **no cooldown at all** (used deliberately by `0017` to remove crafting cooldowns entirely in favor of a cast-time-based limiter).

## Relationships

- `Id` → a spell in `spell_template`/DBC. No FK enforcement — any spell ID can have an override row regardless of whether it exists (invalid IDs are simply inert, since nothing looks them up).
- Not linked to `item_template.spellcooldown_N` automatically — see [`item_template`](item_template.md) for why the client-visible cooldown sweep on an item icon needs a **separate, manual** update when the underlying spell's real cooldown changes here (the client doesn't read this table).

## Used by

- `src/server/game/Spells/SpellMgr.cpp` — `LoadSpellCooldownOverrides()` loads this table into `mSpellCooldownOverrideMap`; the override is applied during spell data initialization (`SpellMgr::LoadSpellInfoStore`-adjacent code, around line 3699): for each field that differs from the DBC default, it overwrites the in-memory `SpellInfo` directly (`spellInfo->RecoveryTime = spellOverride.RecoveryTime;`, etc.).
- **This patches the spell globally** — since it modifies the shared in-memory `SpellInfo` for that spell ID, the new cooldown applies to *every* caster of that spell (all players, all NPCs using it), not just one item/creature/context. There's no way to scope an override to a subset of casters via this table alone.
- GM command `.reload spell_cooldown_overrides` reloads the table, but since `SpellInfo` is patched at spell-store load time, a full data reload (or restart) may be needed for changes to take effect on already-loaded spells — check in-game after any change.

## Modified by

- `0004` — Hearthstone (`Id = 8690`) cooldown reduced 60min → 10min.
- `0010` — Inscription research cooldowns (`61177`, `61288`) reduced 24h → 2h.
- `0017` — 12 profession crafting spells (Transmutes, Mooncloth family, Inscription research) set to **zero** cooldown, since `mod-profession-cast-times` (a custom module) replaces the cooldown with a 60-second cast time instead — removing the DB cooldown avoids double-gating the same craft.
- `0024` — the 12 cyclic Eternal-element transmutes (53771–53784) had their cooldowns zeroed here too, paired with a `skill_extra_item_template` deletion in the same migration to prevent an infinite-duplication exploit via Transmutation Master's bonus-item proc (see [`skill_extra_item_template`](skill_extra_item_template.md)).

## Notes

- **Changing a cooldown here can interact with other systems** — `0017`/`0024` show the two big gotchas on this server: (1) crafting cast-time replacement (`mod-profession-cast-times`) expects the DB cooldown to be zeroed, not left at a nonzero value, or players get gated twice; (2) zeroing a transmute's cooldown while Transmutation Master's bonus-item proc (`skill_extra_item_template`) is still active on that spell can create an infinite item-duplication loop for reversible transmute pairs — check whether the target spell has a `skill_extra_item_template` row before zeroing its cooldown.
- Remember to update `item_template.spellcooldown_N`/`spellcategorycooldown_N` on any item that casts the overridden spell, so the client's tooltip/icon cooldown sweep matches (see `0004` + `0005`, done together for Hearthstone).
