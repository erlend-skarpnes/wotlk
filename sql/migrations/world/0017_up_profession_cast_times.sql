-- Remove cooldowns from profession crafting spells that have long cooldown timers.
-- Cast times are set to 60s by the mod-profession-cast-times module (applied at server startup).
INSERT INTO spell_cooldown_overrides (Id, RecoveryTime, CategoryRecoveryTime, StartRecoveryTime, StartRecoveryCategory, Comment)
VALUES
  (17187, 0, 0, 0, 0, 'Transmute: Arcanite — cooldown replaced by 60s cast time'),
  (18560, 0, 0, 0, 0, 'Mooncloth — cooldown replaced by 60s cast time'),
  (29688, 0, 0, 0, 0, 'Transmute: Primal Might — cooldown replaced by 60s cast time'),
  (31373, 0, 0, 0, 0, 'Spellcloth — cooldown replaced by 60s cast time'),
  (36686, 0, 0, 0, 0, 'Shadowcloth — cooldown replaced by 60s cast time'),
  (56001, 0, 0, 0, 0, 'Moonshroud — cooldown replaced by 60s cast time'),
  (56002, 0, 0, 0, 0, 'Ebonweave — cooldown replaced by 60s cast time'),
  (56003, 0, 0, 0, 0, 'Spellweave — cooldown replaced by 60s cast time'),
  (57425, 0, 0, 0, 0, 'Transmute: Skyflare Diamond — cooldown replaced by 60s cast time'),
  (57427, 0, 0, 0, 0, 'Transmute: Earthsiege Diamond — cooldown replaced by 60s cast time'),
  (60350, 0, 0, 0, 0, 'Transmute: Titanium — cooldown replaced by 60s cast time'),
  (61177, 0, 0, 0, 0, 'Northrend Inscription Research — cooldown replaced by 60s cast time'),
  (61288, 0, 0, 0, 0, 'Minor Inscription Research — cooldown replaced by 60s cast time')
ON DUPLICATE KEY UPDATE
  RecoveryTime         = VALUES(RecoveryTime),
  CategoryRecoveryTime = VALUES(CategoryRecoveryTime),
  Comment              = VALUES(Comment);
