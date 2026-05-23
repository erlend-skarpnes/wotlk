-- Boost world drop rates on reference_loot_template for small-group play
-- GroupId 5 (Epics):   ×20  (~0.07% → ~1.4% avg per kill)
-- GroupId 4 (Blues):   ×15  (~0.15% → ~2.2% avg per kill)
-- GroupId 6 (Recipes): ×5   (~0.6%  → ~3%   avg per kill)
-- GroupId 3 (Greens):  ×2   (~2.8%  → ~5.6% avg per kill)
-- GroupId 2 (Lockboxes): unchanged

UPDATE `reference_loot_template`
SET `Chance` = `Chance` * 20
WHERE `Entry` BETWEEN 1000000 AND 1099999
  AND `GroupId` = 5
  AND `Reference` > 0;

UPDATE `reference_loot_template`
SET `Chance` = `Chance` * 15
WHERE `Entry` BETWEEN 1000000 AND 1099999
  AND `GroupId` = 4
  AND `Reference` > 0;

UPDATE `reference_loot_template`
SET `Chance` = `Chance` * 5
WHERE `Entry` BETWEEN 1000000 AND 1099999
  AND `GroupId` = 6
  AND `Reference` > 0;

UPDATE `reference_loot_template`
SET `Chance` = `Chance` * 2
WHERE `Entry` BETWEEN 1000000 AND 1099999
  AND `GroupId` = 3
  AND `Reference` > 0;
