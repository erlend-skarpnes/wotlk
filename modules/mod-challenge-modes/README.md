# AzerothCore Challenge Modes
Challenge Modes Module for AzerothCore

This module adds the following challenge modes:

- **Hardcore** - Players who die are permanently ghosts and can never be revived.
- **Semi-Hardcore** - Players who die lose all worn equipment and carried gold.
- **Self Crafted** - Players can only wear equipment that they have crafted. Items at or below `SelfCrafted.MaxItemLevel`
  (default 5) are always allowed regardless of maker *(local relaxation, not upstream)* — covers fishing poles and
  one-off quest-equip items (e.g. Torch of Retribution for "Set Them Ablaze!") that were never craftable in the first
  place. Recipe/pattern/schematic loot drops are also boosted by `SelfCrafted.RecipeDropMultiplier` (default 2.0x)
  for these characters *(local addition, not upstream)*, since they must craft nearly everything they wear — applies
  to RNG-gated loot only, not trainer-taught or vendor-sold recipes. Known limitation: loot rolls once per corpse
  using whichever player AC's loot code passes at generation time, so the boost isn't guaranteed to apply to the
  right character in a mixed group — acceptable given this server's solo/small-group focus.
- **Item Quality Level** - Players can only wear equipment that is of Normal or Poor quality
- **Slow XP Gain** - Players receive 0.5x the normal amount of XP.
- **Very Slow XP Gain** - Players receive 0.25x the normal amount of XP.
- **Quest XP Only** - Players can receive XP only from quests
- **Iron Man Mode** - Enforces the [Iron Man Ruleset](https://wowchallenges.com/challangeinfo/iron-man/)
- **Self Found** *(local addition, not upstream)* - Players cannot trade, send/receive mail, or use the guild bank.

Challenges can be activated per-character by interacting with the Shrine of Challenge added near the graveyard of each starting area.
Challenges can only be enabled on characters at level 1 (or level 55 for Death Knights).

Multiple challenges can be activated on a single character as long as they do not conflict, such as Hardcore and Semi-Hardcore.

Rewards for reaching level thresholds for each challenge can be added using the Config file, and can include:
- Items
- Titles
- Talent Points
- Increased XP Rate

### Start titles *(local addition, not upstream)*

Each challenge grants and equips a title the moment it's activated (not at a level threshold), so other players can
see at a glance which challenge a character is running:

| Challenge | Title | ID |
|---|---|---|
| Hardcore | `%s the Deathless` | 178 |
| SemiHardcore | `%s the Brave` | 179 |
| SelfCrafted | `%s the Self-Made` | 180 |
| ItemQualityLevel | `%s the Threadbare` | 181 |
| SlowXpGain | `%s the Steady` | 182 |
| VerySlowXpGain | `%s the Painstaking` | 183 |
| QuestXpOnly | `%s the Diligent` | 184 |
| IronMan | `%s the Ironclad` | 185 |
| SelfFound | `%s the Self-Found` | 186 |

These are custom `CharTitles.dbc` rows (IDs 178-186 / bit_index 143-151 — the first free values past
retail 3.3.5a's last title, ID 177 / bit_index 142). Two halves are required, both included in this repo:

1. **Server-side**: `sql/migrations/world/0034_up_challenge_modes_start_titles.sql` inserts the 9 rows into
   the `chartitles_dbc` table, AzerothCore's documented DBC/SQL hotfix mechanism
   (`DBCStores.cpp` `LOAD_DBC` → `storage.LoadFromDB`). This alone lets the *server* recognize and grant
   the title IDs, but does **not** make them render for players.
2. **Client-side**: every player's client needs a matching `CharTitles.dbc` entry (same ID, `Mask_ID`, and
   text) or the title will be selectable server-side but show as blank/nothing in the Titles UI and above
   the character's head. Ship this the same way as the ARAC race/class patch — a small client-side MPQ
   patch containing the patched `DBFilesClient\CharTitles.dbc`, dropped into each player's `Data` folder.

Please note that this module uses Player Settings to store enabled challenges, so please ensure EnablePlayerSettings is set to 1 in your worldserver.conf.
