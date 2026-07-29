-- WotLK Alchemy/JC transmutes share a cooldown Category (310). Migrations 0017/0024 zeroed the
-- RecoveryTime/CategoryRecoveryTime for a curated list of transmute spells, but any OTHER spell
-- sharing Category 310 still has its full original (multi-hour/day) cooldown. Casting one of
-- those un-fixed spells locks the whole shared category, blocking every "already fixed" transmute
-- too — confirmed via a stuck player cooldown (character_spell_cooldown) after casting one of the
-- WotLK epic-gem transmutes (66658-66664 range) that wasn't in the original list.
--
-- This adds every other Category-310 spell found in live cooldown data (classic/TBC elemental
-- transmutes, WotLK epic gem transmutes, and a few unidentified IDs) to the override table.
-- Exact names for some IDs could not be confirmed — this server's spell_dbc/item_template mirrors
-- are incomplete for older content — so comments are generic where the specific transmute is unknown.
INSERT INTO `spell_cooldown_overrides` (Id, RecoveryTime, CategoryRecoveryTime, StartRecoveryTime, StartRecoveryCategory, Comment)
VALUES
  (17559, 0, 0, 0, 0, 'Classic elemental transmute (category 310) — cooldown removed'),
  (17560, 0, 0, 0, 0, 'Classic elemental transmute (category 310) — cooldown removed'),
  (17561, 0, 0, 0, 0, 'Classic elemental transmute (category 310) — cooldown removed'),
  (17562, 0, 0, 0, 0, 'Classic elemental transmute (category 310) — cooldown removed'),
  (17563, 0, 0, 0, 0, 'Classic elemental transmute (category 310) — cooldown removed'),
  (17564, 0, 0, 0, 0, 'Classic elemental transmute (category 310) — cooldown removed'),
  (17565, 0, 0, 0, 0, 'Classic elemental transmute (category 310) — cooldown removed'),
  (17566, 0, 0, 0, 0, 'Classic elemental transmute (category 310) — cooldown removed'),
  (11479, 0, 0, 0, 0, 'Classic Transmute: Iron to Gold / Mithril to Truesilver family (category 310) — cooldown removed'),
  (11480, 0, 0, 0, 0, 'Classic Transmute: Iron to Gold / Mithril to Truesilver family (category 310) — cooldown removed'),
  (28566, 0, 0, 0, 0, 'TBC Primal elemental transmute (category 310) — cooldown removed'),
  (28567, 0, 0, 0, 0, 'TBC Primal elemental transmute (category 310) — cooldown removed'),
  (28568, 0, 0, 0, 0, 'TBC Primal elemental transmute (category 310) — cooldown removed'),
  (28569, 0, 0, 0, 0, 'TBC Primal elemental transmute (category 310) — cooldown removed'),
  (28580, 0, 0, 0, 0, 'TBC Primal elemental transmute (category 310) — cooldown removed'),
  (28581, 0, 0, 0, 0, 'TBC Primal elemental transmute (category 310) — cooldown removed'),
  (28582, 0, 0, 0, 0, 'TBC Primal elemental transmute (category 310) — cooldown removed'),
  (28583, 0, 0, 0, 0, 'TBC Primal elemental transmute (category 310) — cooldown removed'),
  (28584, 0, 0, 0, 0, 'TBC Primal elemental transmute (category 310) — cooldown removed'),
  (28585, 0, 0, 0, 0, 'TBC Primal elemental transmute (category 310) — cooldown removed'),
  (46714, 0, 0, 0, 0, 'Alchemy/JC transmute, unidentified exact recipe (category 310) — cooldown removed'),
  (54020, 0, 0, 0, 0, 'Alchemy/JC transmute, unidentified exact recipe (category 310) — cooldown removed'),
  (60893, 0, 0, 0, 0, 'Alchemy/JC transmute, unidentified exact recipe (category 310) — cooldown removed'),
  (66658, 0, 0, 0, 0, 'WotLK epic gem transmute (category 310) — cooldown removed'),
  (66659, 0, 0, 0, 0, 'WotLK epic gem transmute (category 310) — cooldown removed'),
  (66660, 0, 0, 0, 0, 'WotLK epic gem transmute (category 310) — cooldown removed'),
  (66662, 0, 0, 0, 0, 'WotLK epic gem transmute (category 310) — cooldown removed'),
  (66663, 0, 0, 0, 0, 'WotLK epic gem transmute (category 310) — cooldown removed'),
  (66664, 0, 0, 0, 0, 'WotLK epic gem transmute (category 310) — cooldown removed')
ON DUPLICATE KEY UPDATE
  RecoveryTime         = VALUES(RecoveryTime),
  CategoryRecoveryTime = VALUES(CategoryRecoveryTime),
  Comment              = VALUES(Comment);
