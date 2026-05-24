-- Restore Hearthstone (spell 8690) cooldown to default (60 minutes)

DELETE FROM `spell_cooldown_overrides` WHERE `Id` = 8690;
