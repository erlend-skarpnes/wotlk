-- Remove cooldown on Glacial Bag crafting (JC spell 56005).
INSERT INTO `spell_cooldown_overrides` (Id, RecoveryTime, CategoryRecoveryTime, StartRecoveryTime, StartRecoveryCategory, Comment)
VALUES
  (56005, 0, 0, 0, 0, 'Glacial Bag — cooldown removed')
ON DUPLICATE KEY UPDATE
  RecoveryTime         = VALUES(RecoveryTime),
  CategoryRecoveryTime = VALUES(CategoryRecoveryTime),
  Comment              = VALUES(Comment);
