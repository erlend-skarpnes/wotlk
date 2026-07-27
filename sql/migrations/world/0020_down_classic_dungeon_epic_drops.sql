-- Restore classic dungeon last boss epic drop chances to original values
-- Scholomance: Darkmaster Gandling
UPDATE `creature_loot_template` SET `Chance` = 7   WHERE `Entry` = 1853  AND `Item` = 14514; -- Pattern: Robe of the Void
UPDATE `creature_loot_template` SET `Chance` = 2   WHERE `Entry` = 1853  AND `Item` = 13937; -- Headmaster's Charge
-- Stratholme Live: Balnazzar
UPDATE `creature_loot_template` SET `Chance` = 6   WHERE `Entry` = 10813 AND `Item` = 14512; -- Pattern: Truefaith Vestments
-- LBRS: Overlord Wyrmthalak
UPDATE `creature_loot_template` SET `Chance` = 2   WHERE `Entry` = 9568  AND `Item` = 13143; -- Mark of the Dragon Lord
-- UBRS: General Drakkisath (via reference table 35025)
UPDATE `reference_loot_template` SET `Chance` = 2   WHERE `Entry` = 35025 AND `Item` = 12592; -- Blackblade of Shahram
-- BRD: Emperor Dagran Thaurissan (via reference table 35014)
UPDATE `reference_loot_template` SET `Chance` = 1   WHERE `Entry` = 35014 AND `Item` = 11684; -- Ironfoe
-- Maraudon: Princess Theradras (via reference table 35009)
UPDATE `reference_loot_template` SET `Chance` = 0.3 WHERE `Entry` = 35009 AND `Item` = 17780; -- Blade of Eternal Darkness
