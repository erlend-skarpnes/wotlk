-- Double Dark Iron Ore drops per node (2-4 → 4-8)
UPDATE `gameobject_loot_template`
SET `MinCount` = 4, `MaxCount` = 8
WHERE `Entry` = 165658 AND `Item` = 11370;
