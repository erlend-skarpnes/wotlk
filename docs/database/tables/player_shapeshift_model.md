# player_shapeshift_model

Per-race (and optionally per-customization/gender) override for the display model used in a given shapeshift form. Stock AzerothCore table — checked **before** falling back to `SpellShapeshiftForm.dbc`'s default Alliance/Horde models. This is the mechanism behind the custom `mod-gnome-druid-forms` module: Gnome Druids (a race that can't normally cast Druid forms) get their own model per form via rows here.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `player_shapeshift_model` (
  `ShapeshiftID` tinyint unsigned NOT NULL,
  `RaceID` tinyint unsigned NOT NULL,
  `CustomizationID` tinyint unsigned NOT NULL,
  `GenderID` tinyint unsigned NOT NULL,
  `ModelID` int unsigned NOT NULL,
  PRIMARY KEY (`ShapeshiftID`,`RaceID`,`CustomizationID`,`GenderID`)
) ENGINE=InnoDB
```

Live snapshot on this server: 114 rows — 7 of them are this server's Gnome Druid (`RaceID = 7`) overrides; the rest are stock AzerothCore data for other races/forms.

## Columns

| Column | Meaning |
|---|---|
| `ShapeshiftID` | The shapeshift form ID (`ShapeshiftForm` enum / `SpellShapeshiftForm.dbc` ID) — e.g. `1` Cat Form, `5` Bear Form, `8` Dire Bear Form, `27` Swift Flight Form, `29` Flight Form. **Not** the spell ID that casts the form. |
| `RaceID` | Player race (`ChrRaces.dbc` ID) this override applies to, e.g. `7` = Gnome. |
| `CustomizationID` | Character customization variant. `255` is the catch-all/fallback used by every existing row on this server (and all stock AC data) — race-specific customization variants (e.g. different skin/face) aren't currently differentiated here. |
| `GenderID` | `2` = gender-neutral, used by every existing row (both stock and custom) rather than splitting `0`/`1` (male/female). |
| `ModelID` | `CreatureDisplayInfo.dbc` model ID to show while shapeshifted into this form, for this race/customization/gender. |

## Relationships

- `RaceID` → `ChrRaces.dbc` (client data).
- `ShapeshiftID` → `SpellShapeshiftForm.dbc` (client data) — same ID space as `Unit::GetShapeshiftForm()`'s `ShapeshiftForm` enum.
- `ModelID` → `CreatureDisplayInfo.dbc`.
- No FK to `spell_template` — the shapeshift-casting spell (e.g. Cat Form's spell ID) is not stored here; only the resulting form ID.

## Used by

- `src/server/game/Globals/ObjectMgr.cpp` — `LoadPlayerShapeshiftModels()` loads this into `_playerShapeshiftModel` (keyed by `(ShapeshiftID, RaceID, CustomizationID, GenderID)` tuple); logs and skips rows with an invalid `RaceID` or a `ModelID` that doesn't resolve to a real display info entry.
- `src/server/game/Entities/Unit/Unit.cpp` — `Unit::GetModelForForm()` is the runtime lookup, called whenever a shapeshift aura applies. Order of precedence: (1) a hardcoded special case for two specific spell IDs (7090 Bear Form, 35200 Roc Form — unrelated to this table), then (2) **this table**, via `sObjectMgr->GetModelForShapeshift(form, player)` — if it returns a nonzero model, that wins outright, (3) otherwise fall back to `SpellShapeshiftForm.dbc`'s `modelID_A`/`modelID_H` (Alliance/Horde default), matched to the player's team.
- `src/server/game/Spells/Auras/SpellAuraEffects.cpp` — calls `GetModelForForm()` when applying/checking the shapeshift model aura effect.

## Modified by

- `0009` — added the initial 6-row set of Gnome Druid (`RaceID = 7`) form overrides (Cat, Travel, Bear, Dire Bear, Swift Flight, Flight), all at `CustomizationID = 255, GenderID = 2` matching the convention of every existing row.
- `0013` — added Tree of Life form (`ShapeshiftID = 2`) → Ancient Protector model (`ModelID = 2429`) for Gnome Druids, following the same convention.
- `0016` — changed Gnome Dire Bear Form (`ShapeshiftID = 8`) model from the initial Baby Blizzard Bear (`16189`) to a Tigon/Roar model (`18261`).

## Notes

- **Aquatic Form (`FORM_AQUA`) is not controlled by this table for any race** — per `0009`'s migration comment, if you need a custom aquatic-form model you'll need a different mechanism (likely a core/DBC change, not a DB row here).
- **Travel Form may not be read from this table** per the same comment — worth confirming in-game after any Travel Form change, since the fallback chain above doesn't guarantee every `ShapeshiftID` is actually checked against this table at every call site.
- Model *scale* (e.g. the 2.0× applied to Gnome cat/flight forms) is **not** a column here — it's applied separately by the `mod-gnome-druid-forms` module's C++ code, not by this table.
- `CustomizationID = 255` / `GenderID = 2` is the working convention for whole-race overrides on this server — don't introduce a different combination without a specific reason, since nothing else here differentiates by customization or gender.
