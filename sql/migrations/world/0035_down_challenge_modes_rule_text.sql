-- Rollback for the 9 custom npc_text rows used as the Shrine of Challenge's
-- confirm-step header text (see 0035_up for details).
DELETE FROM `npc_text` WHERE `ID` BETWEEN 900001 AND 900009;
