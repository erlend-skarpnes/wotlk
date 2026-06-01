-- Reduce inscription research cooldowns from 24h to 2h for small-group server.
-- Affects both Minor Inscription Research (61288) and Northrend Inscription Research (61177).
INSERT INTO spell_cooldown_overrides (Id, RecoveryTime, CategoryRecoveryTime, StartRecoveryTime, StartRecoveryCategory, Comment)
VALUES
  (61177, 7200000, 0, 0, 0, 'Reduced from 86400000 (24h) to 7200000 (2h) for small-group server'),
  (61288, 7200000, 0, 0, 0, 'Reduced from 86400000 (24h) to 7200000 (2h) for small-group server')
ON DUPLICATE KEY UPDATE
  RecoveryTime = VALUES(RecoveryTime),
  Comment      = VALUES(Comment);
