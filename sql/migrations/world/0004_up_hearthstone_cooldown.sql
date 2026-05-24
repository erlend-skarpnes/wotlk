-- Reduce Hearthstone (spell 8690) cooldown from 60 minutes to 10 minutes
-- RecoveryTime and CategoryRecoveryTime are in milliseconds

INSERT INTO `spell_cooldown_overrides` (`Id`, `RecoveryTime`, `CategoryRecoveryTime`, `StartRecoveryTime`, `StartRecoveryCategory`, `Comment`)
VALUES (8690, 600000, 600000, 0, 0, 'Custom: 10-minute hearthstone cooldown')
ON DUPLICATE KEY UPDATE
    `RecoveryTime`         = 600000,
    `CategoryRecoveryTime` = 600000,
    `Comment`              = 'Custom: 10-minute hearthstone cooldown';
