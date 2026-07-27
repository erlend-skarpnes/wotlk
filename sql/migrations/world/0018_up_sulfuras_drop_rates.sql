-- Boost Sulfuras crafting drops for solo/small-group 2-3 run goal
-- Eye of Sulfuras: 3% → 33% (Ragnaros, ~70% chance across 3 runs)
-- Sulfuron Ingot:  20%/×1 → 100%/×3-4 (Golemagg, covers 9 needed in 3 runs)
-- Lava Core:       14%/×1 → 100%/×3-4 (Golemagg, covers 8 needed in 3 runs)
UPDATE `creature_loot_template` SET `Chance` = 33,  `MinCount` = 1, `MaxCount` = 1 WHERE `Entry` = 11502 AND `Item` = 17204;
UPDATE `creature_loot_template` SET `Chance` = 100, `MinCount` = 3, `MaxCount` = 4 WHERE `Entry` = 11988 AND `Item` = 17203;
UPDATE `creature_loot_template` SET `Chance` = 100, `MinCount` = 3, `MaxCount` = 4 WHERE `Entry` = 11988 AND `Item` = 17011;
