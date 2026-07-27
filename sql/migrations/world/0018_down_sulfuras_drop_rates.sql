-- Revert Sulfuras drop rate changes
UPDATE `creature_loot_template` SET `Chance` = 3,  `MinCount` = 1, `MaxCount` = 1 WHERE `Entry` = 11502 AND `Item` = 17204;
UPDATE `creature_loot_template` SET `Chance` = 20, `MinCount` = 1, `MaxCount` = 1 WHERE `Entry` = 11988 AND `Item` = 17203;
UPDATE `creature_loot_template` SET `Chance` = 14, `MinCount` = 1, `MaxCount` = 1 WHERE `Entry` = 11988 AND `Item` = 17011;
