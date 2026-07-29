-- Increase Bag of Fishing Treasures rare-item (Stormjewel) chance from 1% to 10%.
-- Reward from the Dalaran fishing daily quests (Ghostfish, Jewel of the Sewers, etc).
UPDATE `item_loot_template` SET `Chance` = 10
WHERE `Entry` = 46007 AND `Reference` = 10019 AND `Chance` = 1;
