-- Test migration: add a custom broadcast text
INSERT IGNORE INTO `broadcast_text` (`ID`, `MaleText`, `FemaleText`)
VALUES (100000, 'Welcome to the server! Good luck and have fun.', 'Welcome to the server! Good luck and have fun.');
