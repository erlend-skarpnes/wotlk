-- Rollback for mod-challenge-modes: removes the "Shrine of Challenge" gameobject
-- template and its 9 spawns near starting-area graveyards.
DELETE FROM `gameobject` WHERE `guid` BETWEEN 5530536 AND 5530544;
DELETE FROM `gameobject_template` WHERE `entry` = 254605;
