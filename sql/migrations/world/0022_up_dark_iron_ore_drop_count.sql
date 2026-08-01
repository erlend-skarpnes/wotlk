-- Double Dark Iron Ore drops per node (2-4 → 4-8)
-- Entry must be 11213 (loot template id from gameobject_template.Data1 for GO 165658),
-- not the gameobject entry itself — chest-type GOs key loot by Data1, not Entry.
UPDATE `gameobject_loot_template`
SET `MinCount` = 4, `MaxCount` = 8
WHERE `Entry` = 11213 AND `Item` = 11370;
