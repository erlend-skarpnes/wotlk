-- Revert arcane crystal drop rate boost
UPDATE `gameobject_loot_template` SET `Chance` = 25 WHERE `Entry` = 12883 AND `Item` = 1 AND `Reference` = 12900;
UPDATE `reference_loot_template` SET `Chance` = 40 WHERE `entry` = 12900 AND `item` = 12363;
