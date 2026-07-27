-- Restore inscription research cooldowns to the 2h values set in migration 0010
INSERT INTO spell_cooldown_overrides (Id, RecoveryTime, CategoryRecoveryTime, StartRecoveryTime, StartRecoveryCategory, Comment)
VALUES
  (61177, 7200000, 0, 0, 0, 'Reduced from 86400000 (24h) to 7200000 (2h) for small-group server'),
  (61288, 7200000, 0, 0, 0, 'Reduced from 86400000 (24h) to 7200000 (2h) for small-group server')
ON DUPLICATE KEY UPDATE
  RecoveryTime         = VALUES(RecoveryTime),
  CategoryRecoveryTime = VALUES(CategoryRecoveryTime),
  Comment              = VALUES(Comment);

-- Remove cooldown overrides added for alchemy and tailoring spells
DELETE FROM spell_cooldown_overrides
WHERE Id IN (17187, 18560, 29688, 31373, 36686, 56001, 56002, 56003, 57425, 57427, 60350);
