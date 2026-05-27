-- Replace the generic Druid Trainer in Coldridge Valley (GUID 95999) with a squirrel model.
--
-- We create a new creature_template (900001) rather than modifying entry 26324 directly,
-- because 26324 is spawned in ~24 locations worldwide and we only want the squirrel in
-- Coldridge Valley. The new entry is otherwise identical to 26324.

SET @ENTRY := 900001;
SET @SPAWN_GUID := 95999;      -- Druid Trainer at -6188, 392, 397 (Coldridge Valley)
SET @SQUIRREL_DISPLAY := 134;  -- standard squirrel model (used by Squirrel, Woodland Squirrel, etc.)
SET @TRAINER_ID := 33;         -- full druid spell list

-- 1. Creature template (copy of 26324, same stats/flags)
DELETE FROM `creature_template` WHERE `entry` = @ENTRY;
INSERT INTO `creature_template`
    (`entry`, `name`, `subname`, `gossip_menu_id`, `minlevel`, `maxlevel`, `exp`,
     `faction`, `npcflag`, `speed_walk`, `speed_run`, `unit_class`, `unit_flags`,
     `unit_flags2`, `type`, `type_flags`, `DamageModifier`, `BaseAttackTime`,
     `RangeAttackTime`, `AIName`, `ScriptName`, `flags_extra`, `RegenHealth`, `MovementType`)
VALUES
    (@ENTRY, 'Druid Trainer', 'Definitely Not A Squirrel', 0, 70, 70, 2,
     35, 48, 1, 1.14286, 2, 768,
     2048, 7, 0, 1, 2000,
     2000, '', '', 0, 1, 0);

-- 2. Squirrel model (DisplayScale 1.0 — enjoy the tiny trainer)
DELETE FROM `creature_template_model` WHERE `CreatureID` = @ENTRY;
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`)
VALUES (@ENTRY, 0, @SQUIRREL_DISPLAY, 1.0, 1);

-- 3. Link to the full druid trainer spell list
DELETE FROM `creature_default_trainer` WHERE `CreatureId` = @ENTRY;
INSERT INTO `creature_default_trainer` (`CreatureId`, `TrainerId`)
VALUES (@ENTRY, @TRAINER_ID);

-- 4. Swap the Coldridge Valley spawn to use our new template
UPDATE `creature` SET `id1` = @ENTRY WHERE `guid` = @SPAWN_GUID;
