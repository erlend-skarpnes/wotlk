-- Revert Thunderfury drop rate changes
UPDATE `creature_loot_template` SET `Chance` = 3      WHERE `Entry` = 12056 AND `Item` = 18563;
UPDATE `creature_loot_template` SET `Chance` = 3      WHERE `Entry` = 12057 AND `Item` = 18564;
UPDATE `creature_loot_template` SET `Chance` = 7.6811 WHERE `Entry` = 13996 AND `Item` = 18562;
