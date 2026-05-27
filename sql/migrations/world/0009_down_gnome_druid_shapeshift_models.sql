-- Remove custom shapeshift models for Gnome druids (RaceID=7).
-- Gnome is not a vanilla druid race, so there are no original rows to restore;
-- dropping these entries returns gnomes to the server's default fallback behaviour.

DELETE FROM `player_shapeshift_model` WHERE `RaceID` = 7;
