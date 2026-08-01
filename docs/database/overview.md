# Database Overview

Reference for the `acore_world` / `acore_characters` tables this server's migrations, modules, and website actually touch. Each row links to a detail page under `tables/` with column-level docs, source usage, and migration history — built to speed up AI-assisted SQL/module changes without re-deriving table structure from scratch each session. Not a full AzerothCore schema dump; see [AzerothCore Wiki](https://www.azerothcore.org/wiki/) for tables not listed here.

| Table | DB | Description | Doc |
|---|---|---|---|
| `creature_loot_template` | world | Per-creature drop tables: item, chance, quantity, roll grouping. | [tables/creature_loot_template.md](tables/creature_loot_template.md) |
| `gameobject_loot_template` | world | Per-gameobject drop tables (chests, nodes) keyed by loot ID, not GO entry. | [tables/gameobject_loot_template.md](tables/gameobject_loot_template.md) |
| `reference_loot_template` | world | Shared/reusable loot sub-tables pointed to by other loot tables' `Reference` column. | [tables/reference_loot_template.md](tables/reference_loot_template.md) |
| `prospecting_loot_template` | world | Gem yields from Jewelcrafting-prospecting an ore stack, keyed by ore item entry. | [tables/prospecting_loot_template.md](tables/prospecting_loot_template.md) |
| `skill_extra_item_template` | world | Bonus-item proc chance for crafting spells (Master/Artisan specializations). | [tables/skill_extra_item_template.md](tables/skill_extra_item_template.md) |
| `gameobject_template` | world | Master gameobject definitions (chests, nodes, doors); `type` selects Data-field meaning. | [tables/gameobject_template.md](tables/gameobject_template.md) |
| `item_template` | world | Master item definitions: stats, requirements, price, sockets, on-use/on-equip spells. | [tables/item_template.md](tables/item_template.md) |
| `creature_template` | world | Master creature/NPC definitions: level, faction, flags, AI, loot IDs. | [tables/creature_template.md](tables/creature_template.md) |
| `creature_template_model` | world | Display model(s) for a creature template, weighted random selection. | [tables/creature_template_model.md](tables/creature_template_model.md) |
| `creature` | world | Per-map spawn instances of a creature template (position, flags overrides, respawn). | [tables/creature.md](tables/creature.md) |
| `creature_default_trainer` | world | Links a creature template to a shared `TrainerId` spell list (`trainer_spell`). | [tables/creature_default_trainer.md](tables/creature_default_trainer.md) |
| `npc_trainer` | world | ⚠ Appears unused by this server's core — see doc before relying on it. | [tables/npc_trainer.md](tables/npc_trainer.md) |
| `trainer_spell` | world | Effective trainer spell list, cost, and requirements per `TrainerId`. | [tables/trainer_spell.md](tables/trainer_spell.md) |
| `spell_cooldown_overrides` | world | DB override for a spell's cooldown, patched into `SpellInfo` globally at load. | [tables/spell_cooldown_overrides.md](tables/spell_cooldown_overrides.md) |
| `player_shapeshift_model` | world | Per-race override of a shapeshift form's display model (used for Gnome Druid forms). | [tables/player_shapeshift_model.md](tables/player_shapeshift_model.md) |
| `module_string` / `module_string_locale` | world | Generic localized-string storage for modules; currently empty, was used by mod-aoe-loot. | [tables/module_string.md](tables/module_string.md) |
| `website_achievement_points` | world | Custom website-only achievement points lookup (mirrors Achievement.dbc); no gameplay effect. | [tables/website_achievement_points.md](tables/website_achievement_points.md) |
| `pickpocketing_loot_template` | world | Rogue pickpocket loot, keyed by `creature_template.pickpocketloot`. | [tables/pickpocketing_loot_template.md](tables/pickpocketing_loot_template.md) |
| `skinning_loot_template` | world | Skinning loot, keyed by `creature_template.skinloot`. | [tables/skinning_loot_template.md](tables/skinning_loot_template.md) |
| `fishing_loot_template` | world | Fishing catch loot, keyed by area ID rather than an object entry. | [tables/fishing_loot_template.md](tables/fishing_loot_template.md) |
| `disenchant_loot_template` | world | Disenchant result loot, keyed by `item_template.DisenchantID`. | [tables/disenchant_loot_template.md](tables/disenchant_loot_template.md) |
| `milling_loot_template` | world | Inscription milling loot, keyed by herb item entry. | [tables/milling_loot_template.md](tables/milling_loot_template.md) |
| `mail_loot_template` | world | Loot attached to system mail, keyed by `MailTemplate.dbc` ID. | [tables/mail_loot_template.md](tables/mail_loot_template.md) |
| `item_loot_template` | world | Loot for openable items (lockboxes), keyed by the container's own item entry. | [tables/item_loot_template.md](tables/item_loot_template.md) |
| `spell_loot_template` | world | Loot for "create random item" spell effects, keyed by spell ID. | [tables/spell_loot_template.md](tables/spell_loot_template.md) |
| `player_loot_template` | world | PvP corpse "insignia" loot, keyed by looter's TeamId (0/1 only). | [tables/player_loot_template.md](tables/player_loot_template.md) |
| `trainer` | world | Trainer identity: type, class/skill requirement, greeting — joined by `trainer_spell`. | [tables/trainer.md](tables/trainer.md) |
| `conditions` | world | Generic condition system gating loot, gossip, vendor, spell, and quest availability. | [tables/conditions.md](tables/conditions.md) |
| `quest_template` | world | Master quest definition: objectives, rewards, requirements, log text. | [tables/quest_template.md](tables/quest_template.md) |
| `quest_template_addon` | world | AC extension of quest_template: chains, exclusivity, mail rewards, special flags. | [tables/quest_template_addon.md](tables/quest_template_addon.md) |
| `quest_offer_reward` | world | Turn-in "offer reward" screen text/emotes per quest. | [tables/quest_offer_reward.md](tables/quest_offer_reward.md) |
| `quest_request_items` | world | Turn-in "request items" screen text/emotes per quest. | [tables/quest_request_items.md](tables/quest_request_items.md) |
| `points_of_interest` | world | Reusable map marker pool referenced by gossip options and quest POI links. | [tables/points_of_interest.md](tables/points_of_interest.md) |
| `npc_text` | world | Gossip-window text pool (up to 8 weighted slots + emotes), referenced by `gossip_menu`. | [tables/npc_text.md](tables/npc_text.md) |
| `gossip_menu` | world | Links a gossip MenuID to its `npc_text` pool. | [tables/gossip_menu.md](tables/gossip_menu.md) |
| `gossip_menu_option` | world | Individual selectable gossip lines: icon, semantic type, action, confirmation box. | [tables/gossip_menu_option.md](tables/gossip_menu_option.md) |
| `creature_text` | world | General-purpose creature chat/emote/sound system, used by SmartAI `SMART_ACTION_TALK`. | [tables/creature_text.md](tables/creature_text.md) |
| `npc_vendor` | world | Vendor item lists: stock, restock rate, extended (non-gold) cost. | [tables/npc_vendor.md](tables/npc_vendor.md) |
| `creature_addon` | world | Per-spawn mount/stand-state/sheath/emote/auras/waypoint override. | [tables/creature_addon.md](tables/creature_addon.md) |
| `creature_template_addon` | world | Same fields as `creature_addon` but per-template (all spawns). | [tables/creature_template_addon.md](tables/creature_template_addon.md) |
| `creature_equip_template` | world | Visual-only weapon/item sets shown in a creature's hands, selected via `creature.equipment_id`. | [tables/creature_equip_template.md](tables/creature_equip_template.md) |
