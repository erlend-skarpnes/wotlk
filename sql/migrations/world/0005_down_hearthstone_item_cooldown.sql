-- Restore hearthstone item cooldown fields to "inherit from spell DBC" (-1)

UPDATE `item_template`
SET `spellcooldown_1`         = -1,
    `spellcategorycooldown_1` = -1
WHERE `entry` = 6948;
