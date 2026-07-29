-- Remove the spell_cooldown_overrides entry for Icy Prism, restoring the client-default cooldown.
DELETE FROM `spell_cooldown_overrides` WHERE `Id` = 62242;
