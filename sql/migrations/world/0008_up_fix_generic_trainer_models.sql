-- Fix generic class trainer NPC models (entries 26324-26332).
--
-- Their CreatureDisplayIDs (24029-24036, 23777) don't resolve to valid models,
-- so the creatures are invisible/unloaded in-game.
-- Replace with confirmed working display IDs from real trainers in Coldridge Valley.

-- 26324 Druid Trainer  → replaced by custom entry 900001 (squirrel), leave unchanged
-- 26325 Hunter Trainer → 3395 (Thorgas Grimson model, Dwarf male)
-- 26326 Mage Trainer   → 10216 (Marryk Nurribit model, Dwarf female)
-- 26327 Paladin Trainer→ 3393 (Bromos Grummner model, Dwarf male)
-- 26328 Priest Trainer → 3401 (Branstock Khalder model, Dwarf male)
-- 26329 Rogue Trainer  → 3407 (Solm Hargrin model, Dwarf male)
-- 26330 Shaman Trainer → 3406 (Durnan Furcutter model, Dwarf male)
-- 26331 Warlock Trainer→ 1930 (Alamar Grimm model, Dwarf male)
-- 26332 Warrior Trainer→ 3399 (Thran Khorman model, Dwarf male)

UPDATE `creature_template_model` SET `CreatureDisplayID` = 3395  WHERE `CreatureID` = 26325 AND `Idx` = 0;
UPDATE `creature_template_model` SET `CreatureDisplayID` = 10216 WHERE `CreatureID` = 26326 AND `Idx` = 0;
UPDATE `creature_template_model` SET `CreatureDisplayID` = 3393  WHERE `CreatureID` = 26327 AND `Idx` = 0;
UPDATE `creature_template_model` SET `CreatureDisplayID` = 3401  WHERE `CreatureID` = 26328 AND `Idx` = 0;
UPDATE `creature_template_model` SET `CreatureDisplayID` = 3407  WHERE `CreatureID` = 26329 AND `Idx` = 0;
UPDATE `creature_template_model` SET `CreatureDisplayID` = 3406  WHERE `CreatureID` = 26330 AND `Idx` = 0;
UPDATE `creature_template_model` SET `CreatureDisplayID` = 1930  WHERE `CreatureID` = 26331 AND `Idx` = 0;
UPDATE `creature_template_model` SET `CreatureDisplayID` = 3399  WHERE `CreatureID` = 26332 AND `Idx` = 0;
