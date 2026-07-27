-- Revert: restore stock 20h cooldown and Transmutation Master doubling eligibility
-- for the 12 cyclic Eternal-element transmutes (Air/Water/Fire/Life/Shadow/Earth ring).
DELETE FROM `spell_cooldown_overrides` WHERE `Id` IN (53771,53773,53774,53775,53776,53777,53779,53780,53781,53782,53783,53784);

INSERT IGNORE INTO `skill_extra_item_template` (spellId, requiredSpecialization, additionalCreateChance, additionalMaxNum)
VALUES
  (53771,28672,16,3),
  (53773,28672,16,3),
  (53774,28672,16,3),
  (53775,28672,16,3),
  (53776,28672,16,3),
  (53777,28672,16,3),
  (53779,28672,16,3),
  (53780,28672,16,3),
  (53781,28672,16,3),
  (53782,28672,16,3),
  (53783,28672,16,3),
  (53784,28672,16,3);
