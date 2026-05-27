#include "Config.h"
#include "DatabaseEnv.h"
#include "DBCStructure.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "World.h"

#include <array>
#include <sstream>

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// Reads all taximask values for an account (excluding one character) and
// returns the bitwise-OR of all of them as a TaxiMask array.
static std::array<uint32, TaxiMaskSize> LoadAccountTaxiUnion(uint32 accountId, ObjectGuid::LowType excludeGuid)
{
    std::array<uint32, TaxiMaskSize> merged{};

    QueryResult result = CharacterDatabase.Query(
        "SELECT taximask FROM characters WHERE account = {} AND guid != {}",
        accountId, excludeGuid);

    if (!result)
        return merged;

    do
    {
        Field* fields = result->Fetch();
        std::string maskStr = fields[0].Get<std::string>();
        std::istringstream iss(maskStr);
        for (size_t i = 0; i < TaxiMaskSize; ++i)
        {
            uint32 chunk = 0;
            iss >> chunk;
            merged[i] |= chunk;
        }
    } while (result->NextRow());

    return merged;
}

// Applies a raw TaxiMask to a player (bitwise-OR, never clears known nodes).
static void MergeTaxiMask(Player* player, std::array<uint32, TaxiMaskSize> const& mask)
{
    for (size_t i = 0; i < TaxiMaskSize; ++i)
    {
        if (!mask[i])
            continue;

        for (uint8 bit = 0; bit < 32; ++bit)
        {
            if (mask[i] & (1u << bit))
            {
                uint32 nodeId = static_cast<uint32>(i) * 32 + bit + 1;
                player->m_taxi.SetTaximaskNode(nodeId);
            }
        }
    }
}

// Writes a single taxi node bit into every other character on the account
// in the characters table (and in memory if they are online).
static void PropagateNodeToAccount(uint32 accountId, ObjectGuid::LowType excludeGuid, uint32 nodeId)
{
    QueryResult result = CharacterDatabase.Query(
        "SELECT guid, taximask FROM characters WHERE account = {} AND guid != {}",
        accountId, excludeGuid);

    if (!result)
        return;

    uint8 const maskField  = static_cast<uint8>((nodeId - 1) / 32);
    uint32 const maskBit   = 1u << ((nodeId - 1) % 32);

    do
    {
        Field* fields           = result->Fetch();
        ObjectGuid::LowType guid = fields[0].Get<uint32>();
        std::string maskStr     = fields[1].Get<std::string>();

        // Parse
        std::array<uint32, TaxiMaskSize> mask{};
        std::istringstream iss(maskStr);
        for (size_t i = 0; i < TaxiMaskSize; ++i)
            iss >> mask[i];

        // Already known — skip the write
        if (mask[maskField] & maskBit)
            continue;

        mask[maskField] |= maskBit;

        // Reformat
        std::ostringstream oss;
        for (size_t i = 0; i < TaxiMaskSize; ++i)
        {
            if (i > 0) oss << ' ';
            oss << mask[i];
        }

        CharacterDatabase.Execute(
            "UPDATE `characters` SET `taximask` = '{}' WHERE `guid` = {}",
            oss.str(), guid);

        // If this character is currently online, update their live mask too
        if (Player* other = ObjectAccessor::FindPlayerByLowGUID(guid))
            other->m_taxi.SetTaximaskNode(nodeId);

    } while (result->NextRow());
}

// ---------------------------------------------------------------------------
// Script
// ---------------------------------------------------------------------------

class TaxiImprovementsPlayerScript : public PlayerScript
{
public:
    TaxiImprovementsPlayerScript() : PlayerScript("TaxiImprovementsPlayerScript", {
        PLAYERHOOK_ON_LOGIN,
        PLAYERHOOK_ON_LEARN_TAXI_NODE,
    }) {}

    // On login: merge all flight nodes discovered by any account character.
    void OnPlayerLogin(Player* player) override
    {
        if (!sConfigMgr->GetOption<bool>("TaxiImprovements.Enable", true))
            return;
        if (!sConfigMgr->GetOption<bool>("TaxiImprovements.ShareTaxiMask", true))
            return;

        auto merged = LoadAccountTaxiUnion(
            player->GetSession()->GetAccountId(),
            player->GetGUID().GetCounter());

        MergeTaxiMask(player, merged);
    }

    // On discovery: push the new node to all other account characters.
    void OnPlayerLearnTaxiNode(Player const* player, uint32 nodeId) override
    {
        if (!sConfigMgr->GetOption<bool>("TaxiImprovements.Enable", true))
            return;
        if (!sConfigMgr->GetOption<bool>("TaxiImprovements.ShareTaxiMask", true))
            return;

        PropagateNodeToAccount(
            player->GetSession()->GetAccountId(),
            player->GetGUID().GetCounter(),
            nodeId);
    }
};

void AddTaxiImprovementsScripts()
{
    new TaxiImprovementsPlayerScript();
}
