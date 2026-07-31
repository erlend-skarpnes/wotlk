-- 9 custom npc_text rows used as the Shrine of Challenge's confirm-step header
-- text (mod-challenge-modes gobject_challenge_modes::OnGossipSelect). Gossip
-- header text is server-driven (unlike CharTitles.dbc, no client patch needed)
-- but only settable via an npc_text ID lookup, not literal runtime text -- this
-- gives each challenge its own header showing its actual rules before the
-- player confirms. IDs 900001-900009 chosen from an empty custom range well
-- clear of existing content (checked: 0 rows between 900000-900010 before
-- this migration).
INSERT INTO `npc_text` (`ID`, `text0_0`, `text0_1`, `Probability0`) VALUES
  (900001, 'Hardcore: death is permanent. When you die you become a ghost forever and will be disconnected on login. No resurrection is possible.', '', 1),
  (900002, 'Semi-Hardcore: on death, all equipped gear and all carried gold are destroyed. Your character survives. Cannot be combined with Hardcore.', '', 1),
  (900003, 'Self-Crafted: you may only equip gear you crafted yourself. Anything else refuses to equip.', '', 1),
  (900004, 'Item Quality Level: you may only equip Poor or Common quality gear. Uncommon and above refuses to equip.', '', 1),
  (900005, 'Slow XP Gain: you receive only 50% of normal experience from all sources.', '', 1),
  (900006, 'Very Slow XP Gain: you receive only 25% of normal experience from all sources. Cannot be combined with Slow XP Gain.', '', 1),
  (900007, 'Quest XP Only: you gain experience only from quests. Kills grant no XP to you (your pet still gains reduced XP from kills).', '', 1),
  (900008, 'Iron Man: gear capped at Common quality, no enchants, no potions/flasks/food buffs, no trade skills (except Runeforging/Poisons/Beast Training), no grouping, and talent points reset on level-up. The strictest challenge available.', '', 1),
  (900009, 'Self-Found: you cannot trade with other players, send or receive mail, or use the guild bank. Everything you use must be found, looted, or crafted by this character alone.', '', 1)
ON DUPLICATE KEY UPDATE
  text0_0 = VALUES(text0_0),
  text0_1 = VALUES(text0_1),
  Probability0 = VALUES(Probability0);
