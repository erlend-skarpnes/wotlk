-- Remove cooldown on Icy Prism creation (JC spell 62242).
INSERT INTO `spell_cooldown_overrides` (Id, RecoveryTime, CategoryRecoveryTime, StartRecoveryTime, StartRecoveryCategory, Comment)
VALUES
  (62242, 0, 0, 0, 0, 'Icy Prism — cooldown removed')
ON DUPLICATE KEY UPDATE
  RecoveryTime         = VALUES(RecoveryTime),
  CategoryRecoveryTime = VALUES(CategoryRecoveryTime),
  Comment              = VALUES(Comment);
