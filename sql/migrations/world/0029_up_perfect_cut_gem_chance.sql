-- Increase perfect-cut gem proc chance from 20% to 40% for all 72 JC gem-cutting spells
-- (all share requiredSpecialization 55534).
UPDATE `skill_perfect_item_template` SET `perfectCreateChance` = 40
WHERE `requiredSpecialization` = 55534 AND `perfectCreateChance` = 20;
