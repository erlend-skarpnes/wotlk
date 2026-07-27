-- Re-apply Elementium Ore drop rate boost (undo of 0025_down)
UPDATE `creature_loot_template` SET `Chance` = 23.04 WHERE `Entry` = 13996 AND `Item` = 18562;
