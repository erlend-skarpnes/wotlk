-- Boost Thunderfury crafting drops for solo/small-group play
-- Bindings of the Windseeker: 3% → 33% (Baron Geddon + Garr, ~70% chance across 3 runs)
-- Elementium Ore: 7.68% → 23% (Blackwing Technician, 3x boost)
UPDATE `creature_loot_template` SET `Chance` = 33    WHERE `Entry` = 12056 AND `Item` = 18563;
UPDATE `creature_loot_template` SET `Chance` = 33    WHERE `Entry` = 12057 AND `Item` = 18564;
UPDATE `creature_loot_template` SET `Chance` = 23.04 WHERE `Entry` = 13996 AND `Item` = 18562;
