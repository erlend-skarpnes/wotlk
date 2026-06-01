-- Restore default 24-hour cooldown for inscription research spells
DELETE FROM spell_cooldown_overrides
WHERE Id IN (61177, 61288);
