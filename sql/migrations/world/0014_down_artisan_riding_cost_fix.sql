-- Revert Artisan Riding (spell 34091) cost to default 5000g (50000000 copper)
UPDATE `trainer_spell` SET `MoneyCost` = 50000000 WHERE `SpellId` = 34091 AND `TrainerId` IN (35, 36);
