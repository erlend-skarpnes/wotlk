-- 9 custom titles granted immediately when a character starts a mod-challenge-modes
-- challenge (see modules/mod-challenge-modes ChallengeMode_StartTitle wiring), so other
-- players can see at a glance which challenge a character is running.
--
-- This is AzerothCore's documented DBC/SQL hotfix mechanism (DBCStores.cpp LOAD_DBC ->
-- storage.LoadFromDB): it lets the server recognize extra CharTitles.dbc rows without a
-- binary DBC edit, layered on top of whatever the server's own extracted CharTitles.dbc
-- already contains. It is NOT sufficient by itself — every player's client also needs a
-- matching CharTitles.dbc entry (same ID/Mask_ID/text) or the title will be selectable
-- server-side but render as blank text/nothing in the client UI and nameplate. That half
-- ships as a client patch (same category as ARAC's Patch-A.MPQ), applied separately.
--
-- IDs 178-186 and Mask_ID 143-151 were chosen by inspecting this server's own extracted
-- CharTitles.dbc (env/dist/bin/dbc/CharTitles.dbc on the game server): last vanilla-client
-- title is ID 177 / Mask_ID 142, so these are the first free values in both sequences.
-- Name_Lang_Mask/Name1_Lang_Mask (16712190) is a fixed locale-availability flag identical
-- across every existing row in that file, not something specific to a given title.
INSERT INTO `chartitles_dbc`
  (`ID`, `Condition_ID`, `Name_Lang_enUS`, `Name_Lang_Mask`, `Name1_Lang_enUS`, `Name1_Lang_Mask`, `Mask_ID`)
VALUES
  (178, 0, '%s the Deathless',    16712190, '%s the Deathless',    16712190, 143), -- Hardcore
  (179, 0, '%s the Brave',        16712190, '%s the Brave',        16712190, 144), -- SemiHardcore
  (180, 0, '%s the Self-Made',    16712190, '%s the Self-Made',    16712190, 145), -- SelfCrafted
  (181, 0, '%s the Threadbare',   16712190, '%s the Threadbare',   16712190, 146), -- ItemQualityLevel
  (182, 0, '%s the Steady',       16712190, '%s the Steady',       16712190, 147), -- SlowXpGain (not "the Patient" -- ID 172 already owns that text)
  (183, 0, '%s the Painstaking',  16712190, '%s the Painstaking',  16712190, 148), -- VerySlowXpGain
  (184, 0, '%s the Diligent',     16712190, '%s the Diligent',     16712190, 149), -- QuestXpOnly
  (185, 0, '%s the Ironclad',     16712190, '%s the Ironclad',     16712190, 150), -- IronMan
  (186, 0, '%s the Self-Found',   16712190, '%s the Self-Found',   16712190, 151)  -- SelfFound
ON DUPLICATE KEY UPDATE
  Name_Lang_enUS   = VALUES(Name_Lang_enUS),
  Name_Lang_Mask   = VALUES(Name_Lang_Mask),
  Name1_Lang_enUS  = VALUES(Name1_Lang_enUS),
  Name1_Lang_Mask  = VALUES(Name1_Lang_Mask),
  Mask_ID          = VALUES(Mask_ID);
