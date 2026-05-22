-- Rollback: remove the custom motd broadcast text
DELETE FROM `broadcast_text` WHERE `ID` = 100000;
