#include "ScriptMgr.h"
#include "SpellMgr.h"
#include "SpellInfo.h"
#include "DBCStores.h"
#include "WorldScript.h"
#include "Log.h"

// Replace long cooldowns on profession-cooldown crafting spells with a 60-second cast time.
// SpellCastTimes.dbc ID 208 = 60000ms base, no per-level scaling, 60000ms minimum.
// Cooldowns are removed via spell_cooldown_overrides (migration 0017).
static constexpr uint32 CAST_TIME_ENTRY_60S = 208;

static const uint32 PROFESSION_SPELL_IDS[] = {
    17187,  // Transmute: Arcanite
    18560,  // Mooncloth
    29688,  // Transmute: Primal Might
    31373,  // Spellcloth
    36686,  // Shadowcloth
    56001,  // Moonshroud
    56002,  // Ebonweave
    56003,  // Spellweave
    57425,  // Transmute: Skyflare Diamond
    57427,  // Transmute: Earthsiege Diamond
    60350,  // Transmute: Titanium
    61177,  // Northrend Inscription Research
    61288,  // Minor Inscription Research
};

class ProfessionCastTimesScript : public WorldScript
{
public:
    ProfessionCastTimesScript() : WorldScript("ProfessionCastTimesScript", { WORLDHOOK_ON_STARTUP }) {}

    void OnStartup() override
    {
        SpellCastTimesEntry const* castEntry = sSpellCastTimesStore.LookupEntry(CAST_TIME_ENTRY_60S);
        if (!castEntry)
        {
            LOG_ERROR("module", "mod-profession-cast-times: SpellCastTimes entry {} not found — no cast times applied", CAST_TIME_ENTRY_60S);
            return;
        }

        uint32 count = 0;
        for (uint32 spellId : PROFESSION_SPELL_IDS)
        {
            SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(spellId);
            if (!spellInfo)
            {
                LOG_WARN("module", "mod-profession-cast-times: Spell {} not found — skipped", spellId);
                continue;
            }
            const_cast<SpellInfo*>(spellInfo)->CastTimeEntry = castEntry;
            ++count;
        }
        LOG_INFO("module", "mod-profession-cast-times: Applied 60s cast time to {} profession spells", count);
    }
};

void AddProfessionCastTimesScripts()
{
    new ProfessionCastTimesScript();
}
