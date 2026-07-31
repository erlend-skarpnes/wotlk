-- Rollback for the 9 custom challenge-start titles (mod-challenge-modes).
DELETE FROM `chartitles_dbc` WHERE `ID` BETWEEN 178 AND 186;
