-- Remove mod-aoe-loot module strings now that the module is disabled.
-- These were added in migration 0002. Removing them is safe because the
-- module is disabled via config and will never look them up.

SET @MODULE_STRING := CONVERT('mod-aoe-loot' USING utf8mb4) COLLATE utf8mb4_unicode_ci;

DELETE FROM `module_string` WHERE `module` = @MODULE_STRING;
DELETE FROM `module_string_locale` WHERE `module` = @MODULE_STRING;
