-- Restore Jewelcrafting daily quest token reward to 1 (from 5).
UPDATE `quest_template` SET `RewardAmount1` = 1
WHERE `ID` IN (12958,12959,12960,12961,12962,12963,13041,13148,14103) AND `RewardAmount1` = 5;
