-- Restore perfect-cut gem proc chance to 20% (from 40%).
UPDATE `skill_perfect_item_template` SET `perfectCreateChance` = 20
WHERE `requiredSpecialization` = 55534 AND `perfectCreateChance` = 40;
