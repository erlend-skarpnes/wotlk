# quest_template_addon

AzerothCore's extension table for `quest_template` — a one-to-one addon row holding fields the AC data team added beyond the stock 3.3.5a client schema (quest chains, exclusivity groups, breadcrumbs, mail rewards, extra requirement gates).

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `quest_template_addon` (
  `ID` int unsigned NOT NULL DEFAULT '0',
  `MaxLevel` tinyint unsigned NOT NULL DEFAULT '0',
  `AllowableClasses` int unsigned NOT NULL DEFAULT '0',
  `SourceSpellID` int unsigned NOT NULL DEFAULT '0',
  `PrevQuestID` int NOT NULL DEFAULT '0',
  `NextQuestID` int unsigned NOT NULL DEFAULT '0',
  `ExclusiveGroup` int NOT NULL DEFAULT '0',
  `BreadcrumbForQuestId` mediumint unsigned NOT NULL DEFAULT '0',
  `RewardMailTemplateID` int unsigned NOT NULL DEFAULT '0',
  `RewardMailDelay` int unsigned NOT NULL DEFAULT '0',
  `RequiredSkillID` smallint unsigned NOT NULL DEFAULT '0',
  `RequiredSkillPoints` smallint unsigned NOT NULL DEFAULT '0',
  `RequiredMinRepFaction` smallint unsigned NOT NULL DEFAULT '0',
  `RequiredMaxRepFaction` smallint unsigned NOT NULL DEFAULT '0',
  `RequiredMinRepValue` int NOT NULL DEFAULT '0',
  `RequiredMaxRepValue` int NOT NULL DEFAULT '0',
  `ProvidedItemCount` tinyint unsigned NOT NULL DEFAULT '0',
  `SpecialFlags` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB
```

Live snapshot on this server: 9,464 rows (one per quest, same as `quest_template`).

## Columns

| Column | Meaning |
|---|---|
| `MaxLevel` | Upper level bound, `0` = no cap (complements `quest_template.MinLevel`). |
| `AllowableClasses` | Class bitmask restriction (like `item_template.AllowableClass`), `0` = all classes. |
| `SourceSpellID` | Spell that must be cast to trigger/progress this quest. |
| `PrevQuestID` | The quest that must be completed first (quest chain, negative = "quest must NOT be completed" per AC convention). |
| `NextQuestID` | Quest chain forward-link, separate from `quest_template.RewardNextQuest` (which auto-offers; this is just a chain marker). |
| `ExclusiveGroup` | Quests sharing a nonzero (usually negative) value here are mutually exclusive — completing one removes the others from availability. Validated at load: a quest can't have both `ExclusiveGroup` and `BreadcrumbForQuestId` set (logged as an error if it does). |
| `BreadcrumbForQuestId` | Marks this quest as a "breadcrumb" pointing to a target quest chain elsewhere — validated to reference a real quest ID at load. |
| `RewardMailTemplateID`/`RewardMailDelay` | Sends a templated mail (see [`mail_loot_template`](mail_loot_template.md) if the mail has attached loot) some delay after turn-in, instead of/alongside direct rewards. |
| `RequiredSkillID`/`RequiredSkillPoints` | Profession/skill gate beyond `quest_template`'s faction/level gates. |
| `RequiredMinRepFaction`/`RequiredMaxRepFaction` + `RequiredMinRepValue`/`RequiredMaxRepValue` | Reputation range gate (distinct from `quest_template.RequiredFactionId1/2`). |
| `ProvidedItemCount` | How many of `quest_template.StartItem` to grant. |
| `SpecialFlags` | `QuestSpecialFlags` bitmask (`QuestDef.h`) — repeatable (`0x0001`), exploration/event-triggered completion (`0x0002`), auto-accept (`0x0004`), Dungeon Finder quest (`0x0008`), monthly reset (`0x0010`), kill-credit-via-spell-cast (`0x0020`), no reputation spillover (`0x0040`), can-fail-in-any-state (`0x0080`), excluded from Loremaster count (`0x0100`). |

## Relationships

- `ID` → `quest_template.ID` (one-to-one).
- `PrevQuestID`/`NextQuestID`/`BreadcrumbForQuestId` → other `quest_template.ID` rows (validated at load — a dangling reference logs an error).
- `RewardMailTemplateID` → `MailTemplate.dbc`, joined at load with `quest_mail_sender.QuestId` (not documented here) to get the sender NPC.

## Used by

- `src/server/game/Globals/ObjectMgr.cpp` — loaded right after `quest_template` (`LEFT JOIN quest_mail_sender ON Id=QuestId` in the same query); logs `Table 'quest_template_addon' has data for quest {} but such quest does not exist` for orphaned rows; validates `ExclusiveGroup`/`BreadcrumbForQuestId` aren't both set, and that `BreadcrumbForQuestId` resolves.
- `src/server/game/Quests/QuestDef.h` — fields live directly on the `Quest` struct alongside the base `quest_template` fields (`ExclusiveGroup`, `BreadcrumbForQuestId`, etc. are marked "quest_template_addon table (custom data)" in the header).
- GM command `.reload quest_template_addon` hot-reloads this table (or the combined `.reload quest_template` depending on server version's reload grouping).

## Modified by

Not yet touched by a migration on this server.

## Notes

- **A new custom quest needs a `quest_template_addon` row too**, even if just defaults — `RequiredSkillID`, `SpecialFlags` (e.g. repeatable), and class/level caps all live here, not on the base table.
- `ExclusiveGroup` and `BreadcrumbForQuestId` are mutually exclusive by design — setting both on one quest is a load-time error, not silently ignored.
