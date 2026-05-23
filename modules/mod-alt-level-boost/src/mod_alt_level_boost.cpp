#include "AllCreatureScript.h"
#include "DatabaseEnv.h"
#include "GossipDef.h"
#include "Player.h"
#include "ScriptedGossip.h"

constexpr uint32 SENDER_MAIN       = 1;   // Main gossip menu
constexpr uint32 SENDER_BOOST      = 2;   // Level boost submenu

constexpr uint32 ACTION_TRADE      = 1;   // GOSSIP_ACTION_TRADE — open vendor
constexpr uint32 ACTION_INN        = 7;   // GOSSIP_ACTION_INN   — set hearthstone
constexpr uint32 ACTION_BOOST_MENU = 100; // Show level-boost submenu

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

        ClearGossipMenuFor(player);

        // Re-add standard innkeeper options that we're taking over from the core script
        if (creature->IsInnkeeper())
            AddGossipItemFor(player, GOSSIP_ICON_INTERACT_1, "Make this inn your home.", SENDER_MAIN, ACTION_INN);

        if (creature->IsVendor())
            AddGossipItemFor(player, GOSSIP_ICON_VENDOR, "Let me browse your goods.", SENDER_MAIN, ACTION_TRADE);

        // Add level-boost option if any eligible levels exist
        uint32 accountId    = player->GetSession()->GetAccountId();
        uint8  accountMax   = GetAccountMaxLevel(accountId);
        uint8  boostCap     = MaxBoostLevel(accountMax);
        uint8  playerLevel  = player->GetLevel();

        // Show the option only if there is at least one valid target level
        // (a 5-level increment above the player's current level and within the cap)
        uint8 nextEligible = ((playerLevel / 5) + 1) * 5;
        if (boostCap >= 5 && nextEligible <= boostCap)
            AddGossipItemFor(player, GOSSIP_ICON_TRAINER, "I'd like to advance my character's level.", SENDER_MAIN, ACTION_BOOST_MENU);

        SendGossipMenuFor(player, player->GetGossipTextId(creature), creature);
        return true;
    }

    bool CanCreatureGossipSelect(Player* player, Creature* creature, uint32 sender, uint32 action) override
    {
        if (!creature->IsInnkeeper())
            return false;

        ClearGossipMenuFor(player);

        if (sender == SENDER_MAIN)
        {
            switch (action)
            {
                case ACTION_INN:
                    player->SetBindPoint(creature->GetGUID());
                    CloseGossipMenuFor(player);
                    break;

                case ACTION_TRADE:
                    player->GetSession()->SendListInventory(creature->GetGUID());
                    break;

                case ACTION_BOOST_MENU:
                {
                    uint32 accountId   = player->GetSession()->GetAccountId();
                    uint8  accountMax  = GetAccountMaxLevel(accountId);
                    uint8  boostCap    = MaxBoostLevel(accountMax);
                    uint8  playerLevel = player->GetLevel();

                    for (uint8 lvl = 5; lvl <= boostCap; lvl += 5)
                    {
                        if (lvl <= playerLevel)
                            continue;

                        std::string label = "Advance to level " + std::to_string(lvl);
                        AddGossipItemFor(player, GOSSIP_ICON_TRAINER, label, SENDER_BOOST, lvl);
                    }

                    SendGossipMenuFor(player, player->GetGossipTextId(creature), creature);
                    break;
                }

                default:
                    CloseGossipMenuFor(player);
                    break;
            }

            return true;
        }

        if (sender == SENDER_BOOST)
        {
            uint8 targetLevel = static_cast<uint8>(action);

            // Validate: target must be higher than current level and within account cap
            uint32 accountId  = player->GetSession()->GetAccountId();
            uint8  accountMax = GetAccountMaxLevel(accountId);
            uint8  boostCap   = MaxBoostLevel(accountMax);

            if (targetLevel > player->GetLevel() && targetLevel <= boostCap && targetLevel % 5 == 0)
            {
                player->GiveLevel(targetLevel);
                player->SetUInt32Value(PLAYER_XP, 0);
                ChatHandler(player->GetSession()).PSendSysMessage(
                    "|cff00ff00You have been advanced to level %u!|r", targetLevel);
            }

            CloseGossipMenuFor(player);
            return true;
        }

        return false;
    }
};

void AddSC_AltLevelBoost()
{
    new AltLevelBoostScript();
}
