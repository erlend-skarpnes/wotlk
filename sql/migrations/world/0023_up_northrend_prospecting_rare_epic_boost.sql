-- Double rare + epic gem chance from Northrend ore prospecting (Cobalt/Saronite/Titanium)
-- Rare weight doubled within each ore's guaranteed draw; uncommon weight trimmed to compensate (group still always yields 1 gem)
-- Epic (Titanium only): independent 20% trigger chance doubled to 40%

-- Cobalt Ore (ref 1001): rare 1%->2% each (6%->12% total), uncommon trimmed 1pt each
UPDATE `reference_loot_template` SET `chance` = 2 WHERE `entry` = 1001 AND `item` IN (36918,36921,36924,36927,36930,36933);
UPDATE `reference_loot_template` SET `chance` = 15 WHERE `entry` = 1001 AND `item` IN (36917,36920,36923,36926);
UPDATE `reference_loot_template` SET `chance` = 14 WHERE `entry` = 1001 AND `item` IN (36929,36932);

-- Saronite Ore (ref 1004): rare doubled (14%->28% total), uncommon flattened to 12% each (86%->72%)
UPDATE `reference_loot_template` SET `chance` = 6 WHERE `entry` = 1004 AND `item` IN (36918,36921);
UPDATE `reference_loot_template` SET `chance` = 4 WHERE `entry` = 1004 AND `item` IN (36924,36927,36930,36933);
UPDATE `reference_loot_template` SET `chance` = 12 WHERE `entry` = 1004 AND `item` IN (36917,36920,36923,36926,36929,36932);

-- Titanium Ore (ref 1002): rare doubled (25%->50% total), uncommon halved to compensate (75%->50%)
UPDATE `reference_loot_template` SET `chance` = 10 WHERE `entry` = 1002 AND `item` = 36918;
UPDATE `reference_loot_template` SET `chance` = 8 WHERE `entry` = 1002 AND `item` IN (36921,36924,36927,36930,36933);
UPDATE `reference_loot_template` SET `chance` = 8.333333 WHERE `entry` = 1002 AND `item` IN (36917,36920,36923,36926,36929,36932);

-- Titanium Ore epic trigger chance doubled (20%->40%)
UPDATE `prospecting_loot_template` SET `Chance` = 40 WHERE `Entry` = 36910 AND `Reference` = 13005;
