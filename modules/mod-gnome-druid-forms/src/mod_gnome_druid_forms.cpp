#include "Player.h"
#include "ScriptMgr.h"
#include "UnitScript.h"

// Per-form scale overrides for Gnome Druids.
// The player_shapeshift_model table has no scale column, so we apply it here
// via OnDisplayIdChange, which fires after the engine resets scale to 1.0f.
static constexpr float SCALE_CAT         = 1.8f;
static constexpr float SCALE_BEAR        = 1.5f;
static constexpr float SCALE_FLIGHT      = 1.8f;
static constexpr float SCALE_MOONKIN     = 0.7f;
static constexpr float SCALE_TREE        = 0.7f;

class GnomeDruidFormsScript : public UnitScript
{
public:
    GnomeDruidFormsScript() : UnitScript("GnomeDruidFormsScript", true,
        { UNITHOOK_ON_DISPLAYID_CHANGE }) { }

    void OnDisplayIdChange(Unit* unit, uint32 /*displayId*/) override
    {
        Player* player = unit->ToPlayer();
        if (!player)
            return;

        if (player->getRace() != RACE_GNOME)
            return;

        if (player->getClass() != CLASS_DRUID)
            return;

        switch (player->GetShapeshiftForm())
        {
            case FORM_CAT:
                player->SetObjectScale(SCALE_CAT);
                break;
            case FORM_BEAR:
            case FORM_DIREBEAR:
                player->SetObjectScale(SCALE_BEAR);
                break;
            case FORM_FLIGHT:
            case FORM_FLIGHT_EPIC:
                player->SetObjectScale(SCALE_FLIGHT);
                break;
            case FORM_MOONKIN:
                player->SetObjectScale(SCALE_MOONKIN);
                break;
            case FORM_TREE:
                player->SetObjectScale(SCALE_TREE);
                break;
            default:
                // Restore native scale (1.0f for players), respecting any
                // scale-modifier auras that may be active.
                player->RecalculateObjectScale();
                break;
        }
    }
};

void AddGnomeDruidFormsScripts()
{
    new GnomeDruidFormsScript();
}
