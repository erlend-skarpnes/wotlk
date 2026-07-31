#ifndef AZEROTHCORE_CHALLENGEMODES_H
#define AZEROTHCORE_CHALLENGEMODES_H

#include "ScriptMgr.h"
#include "Player.h"
#include "Config.h"
#include "Chat.h"
#include "ScriptedCreature.h"
#include "ScriptedGossip.h"
#include "SpellMgr.h"
#include "Item.h"
#include "ItemTemplate.h"
#include "GameObjectAI.h"
#include "Pet.h"
#include "ObjectAccessor.h"
#include <map>


enum ChallengeModeSettings
{
    SETTING_HARDCORE           = 0,
    SETTING_SEMI_HARDCORE      = 1,
    SETTING_SELF_CRAFTED       = 2,
    SETTING_ITEM_QUALITY_LEVEL = 3,
    SETTING_SLOW_XP_GAIN       = 4,
    SETTING_VERY_SLOW_XP_GAIN  = 5,
    SETTING_QUEST_XP_ONLY      = 6,
    SETTING_IRON_MAN           = 7,
    HARDCORE_DEAD              = 8,
    SETTING_SELF_FOUND         = 9
};

enum AllowedProfessions
{
    RUNEFORGING    = 53428,
    POISONS        = 2842,
    BEAST_TRAINING = 5149
};



class ChallengeModes
{
public:
    static ChallengeModes* instance();

    bool challengesEnabled, hardcoreEnable, semiHardcoreEnable, selfCraftedEnable, itemQualityLevelEnable, slowXpGainEnable, verySlowXpGainEnable, questXpOnlyEnable, ironManEnable, selfFoundEnable;
    uint32 hardcoreDisableLevel, semiHardcoreDisableLevel, selfCraftedDisableLevel, itemQualityLevelDisableLevel, slowXpGainDisableLevel, verySlowXpGainDisableLevel, questXpOnlyDisableLevel, ironManDisableLevel, selfFoundDisableLevel, hardcoreItemRewardAmount, semiHardcoreItemRewardAmount, selfCraftedItemRewardAmount, itemQualityLevelItemRewardAmount, slowXpGainItemRewardAmount, verySlowXpGainItemRewardAmount, questXpOnlyItemRewardAmount, ironManItemRewardAmount, selfFoundItemRewardAmount;
    float hardcoreXpBonus, semiHardcoreXpBonus, selfCraftedXpBonus, itemQualityLevelXpBonus, questXpOnlyXpBonus, slowXpGainBonus, verySlowXpGainBonus, ironManXpBonus, selfFoundXpBonus;
    std::unordered_map<uint8, uint32> hardcoreTitleRewards, semiHardcoreTitleRewards, selfCraftedTitleRewards, itemQualityLevelTitleRewards, slowXpGainTitleRewards, verySlowXpGainTitleRewards, questXpOnlyTitleRewards, ironManTitleRewards, selfFoundTitleRewards;
    std::unordered_map<uint8, uint32> hardcoreItemRewards, semiHardcoreItemRewards, selfCraftedItemRewards, itemQualityLevelItemRewards, slowXpGainItemRewards, verySlowXpGainItemRewards, questXpOnlyItemRewards, ironManItemRewards, selfFoundItemRewards;
    std::unordered_map<uint8, uint32> hardcoreTalentRewards, semiHardcoreTalentRewards, selfCraftedTalentRewards, itemQualityLevelTalentRewards, slowXpGainTalentRewards, verySlowXpGainTalentRewards, questXpOnlyTalentRewards, ironManTalentRewards, selfFoundTalentRewards;
    std::unordered_map<uint8, uint32> hardcoreAchievementReward, semiHardcoreAchievementReward, selfCraftedAchievementReward, itemQualityLevelAchievementReward, slowXpGainAchievementReward, verySlowXpGainAchievementReward, questXpOnlyAchievementReward, ironManAchievementReward, selfFoundAchievementReward;

    std::unordered_map<std::string, std::unordered_map<uint8, uint32>*> rewardConfigMap =
            {
                    { "Hardcore.TitleRewards",                &hardcoreTitleRewards                 },
                    { "SemiHardcore.TitleRewards",            &semiHardcoreTitleRewards             },
                    { "SelfCrafted.TitleRewards",             &selfCraftedTitleRewards              },
                    { "ItemQualityLevel.TitleRewards",        &itemQualityLevelTitleRewards         },
                    { "SlowXpGain.TitleRewards",              &slowXpGainTitleRewards               },
                    { "VerySlowXpGain.TitleRewards",          &verySlowXpGainTitleRewards           },
                    { "QuestXpOnly.TitleRewards",             &questXpOnlyTitleRewards              },
                    { "IronMan.TitleRewards",                 &ironManTitleRewards                  },
                    { "SelfFound.TitleRewards",                &selfFoundTitleRewards                },

                    { "Hardcore.TalentRewards",               &hardcoreTalentRewards                },
                    { "SemiHardcore.TalentRewards",           &semiHardcoreTalentRewards            },
                    { "SelfCrafted.TalentRewards",            &selfCraftedTalentRewards             },
                    { "ItemQualityLevel.TalentRewards",       &itemQualityLevelTalentRewards        },
                    { "SlowXpGain.TalentRewards",             &slowXpGainTalentRewards              },
                    { "VerySlowXpGain.TalentRewards",         &verySlowXpGainTalentRewards          },
                    { "QuestXpOnly.TalentRewards",            &questXpOnlyTalentRewards             },
                    { "IronMan.TalentRewards",                &ironManTalentRewards                 },
                    { "SelfFound.TalentRewards",               &selfFoundTalentRewards               },

                    { "Hardcore.ItemRewards",                 &hardcoreItemRewards                  },
                    { "SemiHardcore.ItemRewards",             &semiHardcoreItemRewards              },
                    { "SelfCrafted.ItemRewards",              &selfCraftedItemRewards               },
                    { "ItemQualityLevel.ItemRewards",         &itemQualityLevelItemRewards          },
                    { "SlowXpGain.ItemRewards",               &slowXpGainItemRewards                },
                    { "VerySlowXpGain.ItemRewards",           &verySlowXpGainItemRewards            },
                    { "QuestXpOnly.ItemRewards",              &questXpOnlyItemRewards               },
                    { "IronMan.ItemRewards",                  &ironManItemRewards                   },
                    { "SelfFound.ItemRewards",                 &selfFoundItemRewards                 },

                    { "Hardcore.AchievementReward",           &hardcoreAchievementReward            },
                    { "SemiHardcore.AchievementReward",       &semiHardcoreAchievementReward        },
                    { "SelfCrafted.AchievementReward",        &selfCraftedAchievementReward         },
                    { "ItemQualityLevel.AchievementReward",   &itemQualityLevelAchievementReward    },
                    { "SlowXpGain.AchievementReward",         &slowXpGainAchievementReward          },
                    { "VerySlowXpGain.AchievementReward",     &verySlowXpGainAchievementReward      },
                    { "QuestXpOnly.AchievementReward",        &questXpOnlyAchievementReward         },
                    { "IronMan.AchievementReward",             &ironManAchievementReward             },
                    { "SelfFound.AchievementReward",           &selfFoundAchievementReward           }
            };

    [[nodiscard]] bool enabled() const { return challengesEnabled; }
    [[nodiscard]] bool challengeEnabled(ChallengeModeSettings setting) const;
    [[nodiscard]] uint32 getDisableLevel(ChallengeModeSettings setting) const;
    [[nodiscard]] float getXpBonusForChallenge(ChallengeModeSettings setting) const;
    bool challengeEnabledForPlayer(ChallengeModeSettings setting, Player* player) const;
    [[nodiscard]] const std::unordered_map<uint8, uint32> *getTitleMapForChallenge(ChallengeModeSettings setting) const;
    [[nodiscard]] const std::unordered_map<uint8, uint32> *getTalentMapForChallenge(ChallengeModeSettings setting) const;
    [[nodiscard]] const std::unordered_map<uint8, uint32> *getItemMapForChallenge(ChallengeModeSettings setting) const;
    [[nodiscard]] const std::unordered_map<uint8, uint32> *getAchievementMapForChallenge(ChallengeModeSettings setting) const;
    [[nodiscard]] uint32 getItemRewardAmount(ChallengeModeSettings setting) const;
};

#define sChallengeModes ChallengeModes::instance()

#endif //AZEROTHCORE_CHALLENGEMODES_H
