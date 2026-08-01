-- Character "Ekornet" (guid 1010) is on the GM account (acore_auth.account id 101,
-- gmlevel 3) and holds achievement 1404 "Realm First! Level 80 Gnome" (ACHIEVEMENT_FLAG_REALM_FIRST_REACH).
-- It was earned during testing and should not occupy the realm-first slot.
-- Requires a worldserver restart to take effect: AchievementGlobalMgr caches
-- realm-first completion state in memory at boot (LoadCompletedAchievements()).
DELETE FROM `character_achievement`
WHERE `guid` = 1010 AND `achievement` = 1404;
