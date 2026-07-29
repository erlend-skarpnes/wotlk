-- Roughly double Rich Saronite Deposit / Titanium Vein spawn weights within their ore pools.
-- Regular Saronite Deposit weight is left untouched — pool_gameobject chance values don't need
-- to sum to 100, so this just shifts the relative odds toward the rich/titanium nodes.
UPDATE `pool_gameobject` pg
JOIN `gameobject` g ON g.`guid` = pg.`guid`
SET pg.`chance` = CASE pg.`chance` WHEN 15 THEN 30 WHEN 13 THEN 26 WHEN 19 THEN 38 END
WHERE g.`id` = 189981 AND pg.`chance` IN (15,13,19);

UPDATE `pool_gameobject` pg
JOIN `gameobject` g ON g.`guid` = pg.`guid`
SET pg.`chance` = CASE pg.`chance` WHEN 8 THEN 16 WHEN 5 THEN 10 WHEN 13 THEN 26 END
WHERE g.`id` = 191133 AND pg.`chance` IN (8,5,13);
