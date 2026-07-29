-- Increase Jewelcrafting daily quest token reward from 1 to 5 (item 41596, Dalaran Jewelcrafter's Token).
-- Covers the full rotating pool of JC dailies: Shipment x6, Finish the Shipment, Necklace Repair, Titanium Powder.
UPDATE `quest_template` SET `RewardAmount1` = 5
WHERE `ID` IN (12958,12959,12960,12961,12962,12963,13041,13148,14103) AND `RewardAmount1` = 1;
