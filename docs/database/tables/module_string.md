# module_string / module_string_locale

Generic, reusable localized-string storage for any module (core or third-party) that wants to avoid hardcoding player-facing text in C++. `module_string` holds the default-locale string; `module_string_locale` holds translations. Not this server's own invention — a stock AzerothCore facility (`ObjectMgr::GetModuleString`) — used here for `mod-aoe-loot`.

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `module_string` (
  `module` varchar(255) NOT NULL COMMENT 'module dir name, eg mod-cfbg',
  `id` int unsigned NOT NULL,
  `string` text NOT NULL,
  PRIMARY KEY (`module`,`id`)
) ENGINE=InnoDB

CREATE TABLE `module_string_locale` (
  `module` varchar(255) NOT NULL COMMENT 'Corresponds to an existing entry in module_string',
  `id` int unsigned NOT NULL COMMENT 'Corresponds to an existing entry in module_string',
  `locale` enum('koKR','frFR','deDE','zhCN','zhTW','esES','esMX','ruRU') NOT NULL,
  `string` text NOT NULL,
  PRIMARY KEY (`module`,`id`,`locale`)
) ENGINE=InnoDB
```

Live snapshot on this server: **both tables are currently empty (0 rows)** — see Modified by / Notes for why.

## Columns

| Column | Meaning |
|---|---|
| `module` | Module directory name, e.g. `mod-aoe-loot`, `mod-cfbg` — must exactly match what the module's C++ code passes to `GetModuleString()`. |
| `id` | Numeric string ID within that module's namespace, chosen by the module author (arbitrary, just needs to match the C++ call site). |
| `string` | The text itself, in `module_string`; supports `|cffXXXXXX...|r` WoW chat-link color codes as seen in this server's own data. |
| `locale` (locale table only) | One of the 8 non-English client locales AzerothCore supports (enUS/enGB use the base `module_string` row as default — there's no `enUS` value in the enum). |

## Relationships

- `module_string_locale.(module, id)` → `module_string.(module, id)` — enforced only at load time (not a real DB foreign key): a locale row with no matching base row is logged as an error and skipped, not inserted.

## Used by

- `src/server/game/Globals/ObjectMgr.cpp` — `LoadModuleStrings()`/`LoadModuleStringsLocale()` populate `_moduleStringStore`; `GetModuleString(module, id, locale)` is the runtime lookup, falling back to the default-locale string if no translation exists for the requested locale.
- **Important defensive-coding gotcha found in this core:** if the requested `(module, id)` doesn't exist at all, `GetModuleString()` logs `Module string module {} id {} not found in DB` and returns `(std::string*)"error"` — a raw C-string literal reinterpret-cast to `std::string*`, **not a valid `std::string` object**. Any caller that dereferences this "as if" it were a real `std::string` (e.g. calling `->c_str()` or copying it) invokes undefined behavior — this is exactly the crash `0002`'s migration comment describes ("strlen on null pointer") when `mod-aoe-loot` looked up a missing string at every player login.
- `src/server/scripts/Commands/cs_reload.cpp` — GM command `.reload module_string` hot-reloads both tables.

## Modified by

- `0002` — added all 8 `mod-aoe-loot` strings (English + `esES`/`esMX` locale translations) after discovering their absence crashed the server on every login.
- `0006` — deleted those same rows after `mod-aoe-loot` was disabled via config (`AOELoot.Enable = 0`, see root `CLAUDE.md`), on the reasoning that a disabled module never reaches the `GetModuleString()` call site, so the crash risk doesn't reappear.

## Notes

- **This table is a landmine for any module that calls `GetModuleString()` without defensively checking `AOELoot.Enable`-style config flags first** — if a currently-disabled module gets re-enabled (or a new module using this API gets installed), check whether it needs rows here *before* enabling it, not after a login crash. The `(std::string*)"error"` fallback means the failure mode is a crash/UB, not a graceful "string not found" message.
- Both tables are empty right now — if you re-enable `mod-aoe-loot` or install another module that uses `module_string`, re-apply (or write a new) migration adding that module's required strings before flipping its config to enabled.
