-- Revert Gnome Druid Dire Bear Form back to Baby Blizzard Bear (DisplayID 16189).

UPDATE `player_shapeshift_model`
SET `ModelID` = 16189
WHERE `RaceID` = 7 AND `ShapeshiftID` = 8;
