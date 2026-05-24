#include "AllCreatureScript.h"
#include "Chat.h"
#include "DatabaseEnv.h"
#include "GameEventMgr.h"
#include "GossipDef.h"
#include "Player.h"
#include "ScriptedGossip.h"

// Mirror the constants from npc_innkeeper.cpp so we build the menu identically
constexpr uint32 HALLOWEEN_EVENTID        = 12;
constexpr uint32 GOSSIP_MENU_INNKEEPER    = 9733;   // standard inn-bind / vendor items
constexpr uint32 GOSSIP_MENU_HALLOWEEN    = 342;    // "Trick or Treat!" item
constexpr uint32 SPELL_TRICKED_OR_TREATED = 24755;

// Boost-specific sender tags (distinct from GOSSIP_SENDER_MAIN=1 and GOSSIP_SENDER_MAIN=2 etc.)
constexpr uint32 SENDER_BOOST      = 20;   // Level boost submenu (using 20 to avoid collisions)
constexpr uint32 ACTION_BOOST_MENU = 100;  // Show level-boost submenu

// Returns the highest level of any character on the account,
// or 0 if the query fails.
static uint8 GetAccountMaxLevel(uint32 accountId)
{
    QueryResult result = CharacterDatabase.Query(
        "SELECT MAX(level) FROM characters WHERE account = {}", accountId);

    if (!result)
        return 0;

    return result->Fetch()[0].Get<uint8>();
}

// Highest 5-level increment the account is eligible to boost to.
// e.g. accountMaxLevel=42 → 40, accountMaxLevel=45 → 45
static uint8 MaxBoostLevel(uint8 accountMaxLevel)
{
    return (accountMaxLevel / 5) * 5;
}

class AltLevelBoostScript : public AllCreatureScript
{
public:
    AltLevelBoostScript() : AllCreatureScript("AltLevelBoostScript") {}

    bool CanCreatureGossipHello(Player* player, Creature* creature) override
    {
        if (!creature->IsInnkeeper())
            return false;

        // Start from a clean state (ClearGossipMenuFor clears both gossip and quest menus)
        ClearGossipMenuFor(player);

        // --- Exactly mirror npc_innkeeper::OnGossipHello ---

        // Trick or Treat — seasonal Halloween event, only if not already done today
        if (IsEventActive(HALLOWEEN_EVENTID) && !player->HasAura(SPELL_TRICKED_OR_TREATED))
            AddGossipItemFor(player, GOSSIP_MENU_HALLOWEEN, 0,
                GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF + HALLOWEEN_EVENTID);

        // Quest options (e.g. "Rest and Relaxation")
        if (creature->IsQuestGiver())
            player->PrepareQuestMenu(creature->GetGUID());

        // Vendor stock
        if (creature->IsVendor())
            AddGossipItemFor(player, GOSSIP_MENU_INNKEEPER, 2,
                GOSSIP_SENDER_MAIN, GOSSIP_ACTION_TRADE);

        // Inn bind (all innkeepers)
        AddGossipItemFor(player, GOSSIP_MENU_INNKEEPER, 1,
            GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INN);

        // --- Append level-boost option if the account has eligible levels ---
        uint32 accountId    = player->GetSession()->GetAccountId();
        uint8  accountMax   = GetAccountMaxLevel(accountId);
        uint8  boostCap     = MaxBoostLevel(accountMax);
        uint8  playerLevel  = player->GetLevel();
        uint8  nextEligible = ((playerLevel / 5) + 1) * 5;

        if (boostCap >= 5 && nextEligible <= boostCap)
            AddGossipItemFor(player, GOSSIP_ICON_TRAINER,
                "I'd like to advance my character's level.",
                GOSSIP_SENDER_MAIN, ACTION_BOOST_MENU);

        player->TalkedToCreature(creature->GetEntry(), creature->GetGUID());
        SendGossipMenuFor(player, player->GetGossipTextId(creature), creature->GetGUID());
        return true;
    }

    bool CanCreatureGossipSelect(Player* player, Creature* creature, uint32 sender, uint32 action) override
    {
        if (!creature->IsInnkeeper())
            return false;

        // Show boost submenu
        if (sender == GOSSIP_SENDER_MAIN && action == ACTION_BOOST_MENU)
        {
            ClearGossipMenuFor(player);

            uint32 accountId   = player->GetSession()->GetAccountId();
            uint8  accountMax  = GetAccountMaxLevel(accountId);
            uint8  boostCap    = MaxBoostLevel(accountMax);
            uint8  playerLevel = player->GetLevel();

            for (uint8 lvl = 5; lvl <= boostCap; lvl += 5)
            {
                if (lvl <= playerLevel)
                    continue;

                AddGossipItemFor(player, GOSSIP_ICON_TRAINER,
                    "Advance to level " + std::to_string(lvl), SENDER_BOOST, lvl);
            }

            SendGossipMenuFor(player, player->GetGossipTextId(creature), creature->GetGUID());
            return true;
        }

        // Apply boost
        if (sender == SENDER_BOOST)
        {
            uint8  targetLevel = static_cast<uint8>(action);
            uint32 accountId   = player->GetSession()->GetAccountId();
            uint8  accountMax  = GetAccountMaxLevel(accountId);
            uint8  boostCap    = MaxBoostLevel(accountMax);

            if (targetLevel > player->GetLevel() && targetLevel <= boostCap && targetLevel % 5 == 0)
            {
                player->GiveLevel(targetLevel);
                player->SetUInt32Value(PLAYER_XP, 0);
                ChatHandler(player->GetSession()).SendSysMessage(
                    "|cff00ff00You have been advanced to level " + std::to_string(targetLevel) + "!|r");
            }

            CloseGossipMenuFor(player);
            return true;
        }

        // Everything else (inn bind, vendor, Trick or Treat, quests) —
        // let npc_innkeeper::OnGossipSelect handle it with the correct actions.
        return false;
    }
};

void AddSC_AltLevelBoost()
{
    new AltLevelBoostScript();
}
