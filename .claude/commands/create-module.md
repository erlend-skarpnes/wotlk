# Create a new AzerothCore module

Create a new custom module named `$ARGUMENTS` by copying the skeleton template and wiring everything up correctly.

## Steps

1. **Validate the name.** The argument must be in `mod-kebab-name` format (starts with `mod-`, lowercase, hyphens only). If it is missing or malformed, tell the user and stop.

2. **Check the destination doesn't already exist.** If `modules/$ARGUMENTS/` already exists, tell the user and stop.

3. **Copy the skeleton.**
   ```
   cp -r modules/skeleton-module modules/$ARGUMENTS
   ```
   Then remove the placeholder SQL file — it's only there to show the pattern:
   ```
   rm modules/$ARGUMENTS/data/sql/db-world/skeleton_module_acore_string.sql
   ```

4. **Derive naming variants** from `$ARGUMENTS`:
   - `SNAKE` — replace every `-` with `_`  (e.g. `mod-hearthstone-fix` → `mod_hearthstone_fix`)
   - `PASCAL` — title-case each word after splitting on `-` and dropping the `mod-` prefix  (e.g. `HearthstoneFix`)
   - `UPPER` — uppercase of SNAKE  (e.g. `MOD_HEARTHSTONE_FIX`)

5. **Rename source files.**
   - `src/MP_loader.cpp` → `src/${SNAKE}_loader.cpp`
   - `src/MyPlayer.cpp`  → `src/${SNAKE}.cpp`

6. **Rewrite `src/${SNAKE}_loader.cpp`** with the correct loader function name and a forward declaration stub:
   ```cpp
   // Forward-declare one AddSC_ function per script file
   void AddSC_${PASCAL}();

   // Entry point — AzerothCore calls this at startup
   // Name = "Add" + module folder name with '-' replaced by '_' + "Scripts"
   void Add${SNAKE}Scripts()
   {
       AddSC_${PASCAL}();
   }
   ```

7. **Rewrite `src/${SNAKE}.cpp`** with a minimal, ready-to-edit stub (no MyPlayer/MyWorld boilerplate):
   ```cpp
   // TODO: add required headers here
   // e.g. #include "Player.h"

   // TODO: implement your script classes here

   void AddSC_${PASCAL}()
   {
       // TODO: register your script classes here
       // e.g. new MyScript();
       // e.g. RegisterSpellScript(my_spell_script);
   }
   ```

8. **Rewrite `conf/my_custom.conf.dist`** → rename to `conf/${SNAKE}.conf.dist` and update the contents:
   ```ini
   [worldserver]

   ########################################
   # ${PASCAL} module configuration
   ########################################
   #
   #    ${PASCAL}.Enable
   #        Default: 1 - Enabled / 0 - Disabled
   #

   ${PASCAL}.Enable = 1
   ```
   Delete the old `conf/my_custom.conf.dist`.

9. **Print a summary** of what was created and remind the user of the next steps:
   - Edit `modules/$ARGUMENTS/src/${SNAKE}.cpp` to add script logic
   - Add a `config/modules/${SNAKE}.conf` (copy from `.conf.dist`, remove `.dist`) if config is needed
   - Add a SQL migration in `sql/migrations/world/` if the module needs DB changes (e.g. `spell_script_names` for SpellScripts)
   - Deploy: `scp -r modules/$ARGUMENTS root@azerothcore:~/azerothcore-wotlk/modules/` then build and restart (see CLAUDE.md)
