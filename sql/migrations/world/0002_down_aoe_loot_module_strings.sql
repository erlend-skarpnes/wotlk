-- Rollback: remove mod-aoe-loot module strings
DELETE FROM `module_string` WHERE `module` = CONVERT('mod-aoe-loot' USING utf8mb4) COLLATE utf8mb4_unicode_ci;
DELETE FROM `module_string_locale` WHERE `module` = CONVERT('mod-aoe-loot' USING utf8mb4) COLLATE utf8mb4_unicode_ci;
