-- Custom shapeshift models for Gnome druids (RaceID=7).
-- CustomizationID=255 is the catch-all fallback used for all character customisations.
-- GenderID=2 is the gender-neutral value used by all existing race entries.
--
-- ShapeshiftID reference:
--   1  = Cat Form          (FORM_CAT = 0x01)
--   3  = Travel Form       (FORM_TRAVEL = 0x03)  -- may not be read from this table
--   5  = Bear Form         (FORM_BEAR = 0x05)
--   8  = Dire Bear Form    (FORM_DIREBEAR = 0x08)
--   27 = Swift Flight Form (FORM_FLIGHT_EPIC = 0x1B)
--   29 = Flight Form       (FORM_FLIGHT = 0x1D)
--
-- Note: Aquatic Form (FORM_AQUA = 0x04) is not controlled by this table for any race.
--
-- Scale (2.0x for cat and flight) is applied by mod-gnome-druid-forms, not here.

DELETE FROM `player_shapeshift_model` WHERE `RaceID` = 7;
INSERT INTO `player_shapeshift_model` (`ShapeshiftID`, `RaceID`, `CustomizationID`, `GenderID`, `ModelID`) VALUES
(1,  7, 255, 2, 5556),   -- Cat Form        → Bombay Cat
(3,  7, 255, 2, 328),    -- Travel Form      → Rabbit
(5,  7, 255, 2, 16189),  -- Bear Form        → Baby Blizzard Bear
(8,  7, 255, 2, 16189),  -- Dire Bear Form   → Baby Blizzard Bear
(27, 7, 255, 2, 6298),   -- Swift Flight     → Snowy Owl
(29, 7, 255, 2, 6298);   -- Flight Form      → Snowy Owl
