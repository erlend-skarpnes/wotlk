-- Remove cooldown from the 12 cyclic Eternal-element transmutes (Air/Water/Fire/Life/Shadow/Earth ring).
-- These share Alchemy's global transmute cooldown category with the already-fixed transmutes
-- (Arcanite/Primal Might/Diamonds/Titanium), and stay reversible (Fire<->Water etc), so with
-- Transmutation Master (spell 28672, chance to create bonus items on craft) still active they'd
-- be an infinite duplication loop if simply zeroed. Blacklist the doubling proc for just these
-- 12 spell IDs first (skill_extra_item_template — see SkillExtraItems.cpp: no row = no proc,
-- regardless of spec), then zero their cooldown same as the other transmutes.
DELETE FROM `skill_extra_item_template` WHERE `spellId` IN (53771,53773,53774,53775,53776,53777,53779,53780,53781,53782,53783,53784);

INSERT INTO `spell_cooldown_overrides` (Id, RecoveryTime, CategoryRecoveryTime, StartRecoveryTime, StartRecoveryCategory, Comment)
VALUES
  (53771, 0, 0, 0, 0, 'Transmute: Eternal Life to Shadow — cooldown removed, doubling blacklisted'),
  (53773, 0, 0, 0, 0, 'Transmute: Eternal Life to Fire — cooldown removed, doubling blacklisted'),
  (53774, 0, 0, 0, 0, 'Transmute: Eternal Fire to Water — cooldown removed, doubling blacklisted'),
  (53775, 0, 0, 0, 0, 'Transmute: Eternal Fire to Life — cooldown removed, doubling blacklisted'),
  (53776, 0, 0, 0, 0, 'Transmute: Eternal Air to Water — cooldown removed, doubling blacklisted'),
  (53777, 0, 0, 0, 0, 'Transmute: Eternal Air to Earth — cooldown removed, doubling blacklisted'),
  (53779, 0, 0, 0, 0, 'Transmute: Eternal Shadow to Earth — cooldown removed, doubling blacklisted'),
  (53780, 0, 0, 0, 0, 'Transmute: Eternal Shadow to Life — cooldown removed, doubling blacklisted'),
  (53781, 0, 0, 0, 0, 'Transmute: Eternal Earth to Air — cooldown removed, doubling blacklisted'),
  (53782, 0, 0, 0, 0, 'Transmute: Eternal Earth to Shadow — cooldown removed, doubling blacklisted'),
  (53783, 0, 0, 0, 0, 'Transmute: Eternal Water to Air — cooldown removed, doubling blacklisted'),
  (53784, 0, 0, 0, 0, 'Transmute: Eternal Water to Fire — cooldown removed, doubling blacklisted')
ON DUPLICATE KEY UPDATE
  RecoveryTime         = VALUES(RecoveryTime),
  CategoryRecoveryTime = VALUES(CategoryRecoveryTime),
  Comment              = VALUES(Comment);
