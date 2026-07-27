-- Revert Elementium Ore drop rate boost (Bindings of the Windseeker boost from 0019 stays)
UPDATE `creature_loot_template` SET `Chance` = 7.6811 WHERE `Entry` = 13996 AND `Item` = 18562;
