-- Fix hearthstone client-side cooldown display.
--
-- The server enforces the 10-min cooldown via spell_cooldown_overrides (migration 0004),
-- but SMSG_COOLDOWN_EVENT carries no duration — the client falls back to its local
-- Spell.dbc (30 min) for the visual sweep. Setting an explicit cooldown on the item
-- template makes the client use that value instead.
--
-- spellcooldown_1 and spellcategorycooldown_1: -1 → 600000 ms (10 minutes)

UPDATE `item_template`
SET `spellcooldown_1`         = 600000,
    `spellcategorycooldown_1` = 600000
WHERE `entry` = 6948;
