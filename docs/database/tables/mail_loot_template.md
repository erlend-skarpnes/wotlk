# mail_loot_template

Loot table for items attached to a system-generated mail (e.g. GM reward mail, quest-completion mail via `MailTemplate.dbc`). Same schema/column semantics as [`creature_loot_template`](creature_loot_template.md).

**Database:** `acore_world`

## Schema

```sql
CREATE TABLE `mail_loot_template` (
  `Entry` int unsigned NOT NULL DEFAULT '0',
  `Item` int unsigned NOT NULL DEFAULT '0',
  `Reference` int NOT NULL DEFAULT '0',
  `Chance` float NOT NULL DEFAULT '100',
  `QuestRequired` tinyint NOT NULL DEFAULT '0',
  `LootMode` smallint unsigned NOT NULL DEFAULT '1',
  `GroupId` tinyint unsigned NOT NULL DEFAULT '0',
  `MinCount` tinyint unsigned NOT NULL DEFAULT '1',
  `MaxCount` tinyint unsigned NOT NULL DEFAULT '1',
  `Comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Entry`,`Item`)
) ENGINE=InnoDB COMMENT='Loot System'
```

Live snapshot on this server: 112 rows across 110 distinct `Entry` values.

## Columns

| Column | Meaning |
|---|---|
| `Entry` | Mail template ID (`MailTemplate.dbc`) — which client-defined mail this loot table attaches to, not a creature/item/GO entry. |

Example — `Entry = 84/85/86` all grant item `21746` "Lucky Red Envelope" at 100% chance (a Lunar Festival holiday mail template reused across several near-identical mail entries).

## Relationships

- `Entry` → `MailTemplate.dbc` (client data, not a world DB table) — read together with the DBC's subject/body text.
- `Item` → `item_template.entry`.
- `Reference` → `reference_loot_template.Entry`.

## Used by

- `src/server/game/Loot/LootMgr.cpp` — `LootTemplates_Mail` in-memory store, registered with `false` for the "standalone entry required" flag (`LootStore("mail_loot_template", "mail template id", false)`) — meaning, like `reference_loot_template`, rows here are only ever reached by another system pointing at them (the mail template ID), not treated as a root/independent lookup requiring every ID to also exist elsewhere.
- `src/server/game/Mails/Mail.cpp` — `mailLoot.FillLoot(m_mailTemplateId, LootTemplates_Mail, receiver, true, true)` — populates the attached-item loot when a templated mail is delivered/opened.
- GM command `.reload mail_loot_template` hot-reloads this table.

## Modified by

Not yet touched by a migration on this server.

## Notes

- Relevant if adding custom holiday/event mail rewards — pair a new `MailTemplate.dbc` entry (client-side, requires a DBC edit/patch) with rows here for the loot; the world DB alone can't add a new mail template ID that doesn't exist client-side.
