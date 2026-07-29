-- Restore Bag of Fishing Treasures rare-item (Stormjewel) chance to 1% (from 10%).
UPDATE `item_loot_template` SET `Chance` = 1
WHERE `Entry` = 46007 AND `Reference` = 10019 AND `Chance` = 10;
