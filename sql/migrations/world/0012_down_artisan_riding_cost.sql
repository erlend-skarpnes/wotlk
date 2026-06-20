-- Revert Artisan Riding cost to default 5000g (50000000 copper)
UPDATE `npc_trainer` SET `moneycost` = 50000000 WHERE `SpellID` = 34090;
