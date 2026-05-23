-- Revert world drop rate boosts on reference_loot_template
-- GroupId 5 (Epics):   ÷10
-- GroupId 4 (Blues):   ÷10
-- GroupId 6 (Recipes): ÷5
-- GroupId 3 (Greens):  ÷2

UPDATE `reference_loot_template`
SET `Chance` = `Chance` / 10
WHERE `Entry` BETWEEN 1000000 AND 1099999
  AND `GroupId` = 5
  AND `Reference` > 0;

UPDATE `reference_loot_template`
SET `Chance` = `Chance` / 10
WHERE `Entry` BETWEEN 1000000 AND 1099999
  AND `GroupId` = 4
  AND `Reference` > 0;

UPDATE `reference_loot_template`
SET `Chance` = `Chance` / 5
WHERE `Entry` BETWEEN 1000000 AND 1099999
  AND `GroupId` = 6
  AND `Reference` > 0;

UPDATE `reference_loot_template`
SET `Chance` = `Chance` / 2
WHERE `Entry` BETWEEN 1000000 AND 1099999
  AND `GroupId` = 3
  AND `Reference` > 0;
