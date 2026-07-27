-- Buff classic dungeon last boss epic drop chances to 20% for solo/small-group play
-- Baron Rivendare (Deathcharger's Reins) already at 20%, skipped
-- Scholomance: Darkmaster Gandling
UPDATE `creature_loot_template` SET `Chance` = 20 WHERE `Entry` = 1853  AND `Item` = 14514; -- Pattern: Robe of the Void (was 7%)
UPDATE `creature_loot_template` SET `Chance` = 20 WHERE `Entry` = 1853  AND `Item` = 13937; -- Headmaster's Charge (was 2%)
-- Stratholme Live: Balnazzar
UPDATE `creature_loot_template` SET `Chance` = 20 WHERE `Entry` = 10813 AND `Item` = 14512; -- Pattern: Truefaith Vestments (was 6%)
-- LBRS: Overlord Wyrmthalak
UPDATE `creature_loot_template` SET `Chance` = 20 WHERE `Entry` = 9568  AND `Item` = 13143; -- Mark of the Dragon Lord (was 2%)
-- UBRS: General Drakkisath (via reference table 35025)
UPDATE `reference_loot_template` SET `Chance` = 20 WHERE `Entry` = 35025 AND `Item` = 12592; -- Blackblade of Shahram (was 2%)
-- BRD: Emperor Dagran Thaurissan (via reference table 35014)
UPDATE `reference_loot_template` SET `Chance` = 20 WHERE `Entry` = 35014 AND `Item` = 11684; -- Ironfoe (was 1%)
-- Maraudon: Princess Theradras (via reference table 35009)
-- Note: Blade of Eternal Darkness is in a grouped loot pool with blues; 20% weight gives ~16% effective drop rate
UPDATE `reference_loot_template` SET `Chance` = 20 WHERE `Entry` = 35009 AND `Item` = 17780; -- Blade of Eternal Darkness (was 0.3%)
