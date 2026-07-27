-- Revert Northrend prospecting rare/epic gem chance boost
UPDATE `reference_loot_template` SET `chance` = 1 WHERE `entry` = 1001 AND `item` IN (36918,36921,36924,36927,36930,36933);
UPDATE `reference_loot_template` SET `chance` = 16 WHERE `entry` = 1001 AND `item` IN (36917,36920,36923,36926);
UPDATE `reference_loot_template` SET `chance` = 15 WHERE `entry` = 1001 AND `item` IN (36929,36932);

UPDATE `reference_loot_template` SET `chance` = 3 WHERE `entry` = 1004 AND `item` IN (36918,36921);
UPDATE `reference_loot_template` SET `chance` = 2 WHERE `entry` = 1004 AND `item` IN (36924,36927,36930,36933);
UPDATE `reference_loot_template` SET `chance` = 15 WHERE `entry` = 1004 AND `item` IN (36917,36920);
UPDATE `reference_loot_template` SET `chance` = 14 WHERE `entry` = 1004 AND `item` IN (36923,36926,36929,36932);

UPDATE `reference_loot_template` SET `chance` = 5 WHERE `entry` = 1002 AND `item` = 36918;
UPDATE `reference_loot_template` SET `chance` = 4 WHERE `entry` = 1002 AND `item` IN (36921,36924,36927,36930,36933);
UPDATE `reference_loot_template` SET `chance` = 12.5 WHERE `entry` = 1002 AND `item` IN (36917,36920,36923,36926,36929,36932);

UPDATE `prospecting_loot_template` SET `Chance` = 20 WHERE `Entry` = 36910 AND `Reference` = 13005;
