-- Remove the spell_cooldown_overrides entry for Glacial Bag, restoring the client-default cooldown.
DELETE FROM `spell_cooldown_overrides` WHERE `Id` = 56005;
