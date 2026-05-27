-- Restore the Coldridge Valley Druid Trainer to the standard generic NPC (entry 26324).

SET @ENTRY := 900001;
SET @SPAWN_GUID := 95999;

-- Revert the spawn back to the generic druid trainer
UPDATE `creature` SET `id1` = 26324 WHERE `guid` = @SPAWN_GUID;

-- Remove the custom template data
DELETE FROM `creature_default_trainer` WHERE `CreatureId` = @ENTRY;
DELETE FROM `creature_template_model` WHERE `CreatureID` = @ENTRY;
DELETE FROM `creature_template` WHERE `entry` = @ENTRY;
