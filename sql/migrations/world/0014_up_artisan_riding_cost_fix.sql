-- Set Artisan Riding (spell 34091, 280% flying) cost to 1600g (16000000 copper)
-- Applies to all riding trainers: Ilsa Blusterbrew (35), Northrend trainers (36)
UPDATE `trainer_spell` SET `MoneyCost` = 16000000 WHERE `SpellId` = 34091 AND `TrainerId` IN (35, 36);
