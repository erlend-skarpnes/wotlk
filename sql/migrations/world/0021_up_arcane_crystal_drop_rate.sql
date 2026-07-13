-- Boost arcane crystal drop rate: ref table 25%→50%, arcane weight 40→80
-- Effective rate: ~28.6% per Rich Thorium Vein (was ~10%)
UPDATE `gameobject_loot_template` SET `Chance` = 50 WHERE `Entry` = 12883 AND `Item` = 1 AND `Reference` = 12900;
UPDATE `reference_loot_template` SET `Chance` = 80 WHERE `entry` = 12900 AND `item` = 12363;
