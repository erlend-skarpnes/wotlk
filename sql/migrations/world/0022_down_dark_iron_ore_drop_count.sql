-- Revert Dark Iron Ore drop count to original (2-4 per node)
UPDATE `gameobject_loot_template`
SET `MinCount` = 2, `MaxCount` = 4
WHERE `Entry` = 165658 AND `Item` = 11370;
