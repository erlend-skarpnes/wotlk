-- Revert rare mount drop rates to original values

-- creature_loot_template
UPDATE `creature_loot_template` SET `Chance` = 1      WHERE `Entry` = 10440 AND `Item` = 13335;  -- Deathcharger's Reins (Baron Rivendare)
UPDATE `creature_loot_template` SET `Chance` = 2      WHERE `Entry` = 14509 AND `Item` = 19902;  -- Swift Zulian Tiger (High Priest Thekal)
UPDATE `creature_loot_template` SET `Chance` = 2      WHERE `Entry` = 11382 AND `Item` = 19872;  -- Swift Razzashi Raptor (Bloodlord Mandokir)
UPDATE `creature_loot_template` SET `Chance` = 1      WHERE `Entry` = 16152 AND `Item` = 30480;  -- Fiery Warhorse's Reins (Attumen)
UPDATE `creature_loot_template` SET `Chance` = 2      WHERE `Entry` = 19622 AND `Item` = 32458;  -- Ashes of Al'ar (Kael'thas TK)
UPDATE `creature_loot_template` SET `Chance` = 0.9342 WHERE `Entry` = 23035 AND `Item` = 32768;  -- Reins of the Raven Lord (Anzu)
UPDATE `creature_loot_template` SET `Chance` = 5      WHERE `Entry` = 24857 AND `Item` = 35513;  -- Swift White Hawkstrider (Kael'thas MgT)
UPDATE `creature_loot_template` SET `Chance` = 1.5    WHERE `Entry` = 30807 AND `Item` = 44151;  -- Reins of the Blue Proto-Drake (Skadi)
UPDATE `creature_loot_template` SET `Chance` = 1      WHERE `Entry` = 10184 AND `Item` = 49636;  -- Reins of the Onyxian Drake (Onyxia 10)
UPDATE `creature_loot_template` SET `Chance` = 2      WHERE `Entry` = 36538 AND `Item` = 49636;  -- Reins of the Onyxian Drake (Onyxia 25)

-- gameobject_loot_template
UPDATE `gameobject_loot_template` SET `Chance` = 1 WHERE `Entry` = 26094 AND `Item` = 43952;  -- Reins of the Azure Drake (Malygos 10 chest)
UPDATE `gameobject_loot_template` SET `Chance` = 1 WHERE `Entry` = 26097 AND `Item` = 43952;  -- Reins of the Azure Drake (Malygos 25 chest)
