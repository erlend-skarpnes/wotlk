-- Restore Rich Saronite Deposit / Titanium Vein spawn weights to their original values.
UPDATE `pool_gameobject` pg
JOIN `gameobject` g ON g.`guid` = pg.`guid`
SET pg.`chance` = CASE pg.`chance` WHEN 30 THEN 15 WHEN 26 THEN 13 WHEN 38 THEN 19 END
WHERE g.`id` = 189981 AND pg.`chance` IN (30,26,38);

UPDATE `pool_gameobject` pg
JOIN `gameobject` g ON g.`guid` = pg.`guid`
SET pg.`chance` = CASE pg.`chance` WHEN 16 THEN 8 WHEN 10 THEN 5 WHEN 26 THEN 13 END
WHERE g.`id` = 191133 AND pg.`chance` IN (16,10,26);
