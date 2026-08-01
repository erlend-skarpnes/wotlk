-- Restore the bogus GM-earned realm-first achievement (undo of 0001_up).
INSERT IGNORE INTO `character_achievement` (`guid`, `achievement`, `date`)
VALUES (1010, 1404, 1779817372);
