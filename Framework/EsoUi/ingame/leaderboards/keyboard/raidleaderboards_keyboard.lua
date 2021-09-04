--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local RAID_LEADERBOARD_FRAGMENT

local ZO_RaidLeaderboardsManager_Keyboard = ZO_RaidLeaderboardsManager_Shared:Subclass()

function ZO_RaidLeaderboardsManager_Keyboard:New(...)
    return ZO_RaidLeaderboardsManager_Shared.New(self, ...)
end

function ZO_RaidLeaderboardsManager_Keyboard:Initialize(control)
    RAID_LEADERBOARD_FRAGMENT = ZO_FadeSceneFragment:New(control)

    self.currentScoreLabel = GetControl(control, "CurrentScore")
    self.currentRankLabel = GetControl(control, "CurrentRank")
    self.scoringInfoLabel = GetControl(control, "ScoringInfo")
    self.timerLabel = GetControl(control, "Timer")
    self.activeScore = GetControl(control, "ActiveScore")

    self.scoringInfoHelpIcon = GetControl(control, "ScoringInfoHelp")
    self.scoringInfoHelpIcon:SetParent(self.scoringInfoLabel)
    
    ZO_RaidLeaderboardsManager_Shared.Initialize(self, control, LEADERBOARDS, LEADERBOARDS_SCENE, RAID_LEADERBOARD_FRAGMENT)

    self:RegisterForEvents()

    RAID_LEADERBOARD_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
                                                 if newState == SCENE_FRAGMENT_SHOWING then
                                                     self:UpdateAllInfo()
                                                 end
                                             end)

    SYSTEMS:RegisterKeyboardObject(RAID_LEADERBOARD_SYSTEM_NAME, self)
    LEADERBOARDS:UpdateCategories()
end

function ZO_RaidLeaderboardsManager_Keyboard:RefreshHeaderPlayerInfo(isWeekly)
    local displayedScore = self.currentScoreData or GetString(SI_LEADERBOARDS_NO_SCORE_RECORDED)
    self.currentScoreLabel:SetText(zo_strformat(SI_LEADERBOARDS_BEST_SCORE, displayedScore))

    local rankingTypeText = GetString("SI_LEADERBOARDTYPE", LEADERBOARD_LIST_MANAGER.leaderboardRankType)
    local displayedRank = self.currentRankData or GetString(SI_LEADERBOARDS_NOT_RANKED)
    self.currentRankLabel:SetText(zo_strformat(SI_LEADERBOARDS_CURRENT_RANK, rankingTypeText, displayedRank))

    self.timerLabel:SetHidden(not isWeekly)
end

function ZO_RaidLeaderboardsManager_Keyboard:RefreshHeaderTimer()
    if self.timerLabelData then
        self.timerLabel:SetText(zo_strformat(self.timerLabelIdentifier, self.timerLabelData))
    else
        self.timerLabel:SetText("")
    end
end

function ZO_RaidLeaderboardsManager_Keyboard:UpdateRaidScore()
    ZO_RaidLeaderboardsManager_Shared.UpdateRaidScore(self)

    if not self.selectedSubType then
        return
    end

    local eligible = not self.participating or self.credited
    local currentScoreTextFormat = GetString(eligible and SI_LEADERBOARDS_CURRENT_SCORE or SI_RAID_LEADERBOARDS_CURRENT_SCORE_NOT_ELIGIBLE)
    self.scoringInfoLabel:SetText(zo_strformat(currentScoreTextFormat, self.currentScoreData))
    self.scoringInfoHelpIcon:SetHidden(eligible)
end

function ZO_RaidLeaderboardsInformationArea_CurrentRankHelp_OnMouseEnter(control)
    InitializeTooltip(InformationTooltip, control, TOPLEFT, 5, 0)
    SetTooltipText(InformationTooltip, GetString(SI_RAID_LEADERBOARDS_RANK_HELP_TOOLTIP))
end

function ZO_RaidLeaderboardsInformationArea_CurrentRankHelp_OnMouseExit(control)
    ClearTooltip(InformationTooltip)
end

function ZO_RaidLeaderboardsInformationArea_ScoringInfoHelp_OnMouseEnter(control)
    InitializeTooltip(InformationTooltip, control, TOPRIGHT, -5, 0)
    SetTooltipText(InformationTooltip, GetString(SI_RAID_LEADERBOARDS_PARTICIPATING_NOT_ELIGIBLE_HELP_TOOLTIP))
end

function ZO_RaidLeaderboardsInformationArea_ScoringInfoHelp_OnMouseExit(control)
    ClearTooltip(InformationTooltip)
end

function ZO_RaidLeaderboardsInformationArea_OnInitialized(self)
    RAID_LEADERBOARDS = ZO_RaidLeaderboardsManager_Keyboard:New(self)
end