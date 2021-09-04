--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local CAMPAIGN_AVA_RANK
CampaignAvARank = ZO_Object:Subclass()

function CampaignAvARank:New(control)
    local manager = ZO_Object.New(self)
    manager.name = GetControl(control, "Name")
    manager.icon = GetControl(control, "Icon")
    manager.rank = GetControl(control, "Rank")
    manager.statusBar = GetControl(control, "XPBar")
    ZO_StatusBar_SetGradientColor(manager.statusBar, ZO_AVA_RANK_GRADIENT_COLORS)

    control:RegisterForEvent(EVENT_RANK_POINT_UPDATE, function() manager:Refresh() end) 

    manager:Refresh()

    return manager
end

local function GetCurrentRankProgress()
    local rankPoints = GetUnitAvARankPoints("player")
    local _, _, rankStartsAt, nextRankAt = GetAvARankProgress(rankPoints)
    if rankPoints >= nextRankAt then
        local rank = GetUnitAvARank("player")
        local lastRankPoints = GetNumPointsNeededForAvARank(rank - 1)
        local maxRankPoints = GetNumPointsNeededForAvARank(rank)
        local fullRankPoints = maxRankPoints - lastRankPoints

        return fullRankPoints, fullRankPoints
    else
        return rankPoints - rankStartsAt, nextRankAt - rankStartsAt
    end
end

function CampaignAvARank:Refresh()
    local alliance = GetUnitAlliance("player")
    local rank = GetUnitAvARank("player")
    self.name:SetText(zo_strformat(SI_AVA_ALLIANCE_AND_RANK_NAME, GetAllianceName(alliance), GetAvARankName(GetUnitGender("player"), rank)))
    self.rank:SetText(rank)
    self.icon:SetTexture(GetLargeAvARankIcon(rank))
    local current, max = GetCurrentRankProgress()
    self.statusBar:SetMinMax(0,max)    
    self.statusBar:SetValue(current)

    if InformationTooltip:GetOwner() == ZO_CampaignAvARankXPBar then
        ZO_CampaignAvARankStatusBar_OnMouseEnter(ZO_CampaignAvARankXPBar)
    end
end

--Global XML

function ZO_CampaignAvARankStatusBar_OnMouseEnter(control)
    InitializeTooltip(InformationTooltip, control, TOP, 0, 5)
    SetTooltipText(InformationTooltip, zo_strformat(SI_AVA_RANK_PROGRESS_TOOLTIP, GetCurrentRankProgress()))
end

function ZO_CampaignAvARankStatusBar_OnMouseExit()
    ClearTooltip(InformationTooltip)
end

function ZO_CampaignAvARank_OnInitialized(self)
    CAMPAIGN_AVA_RANK = CampaignAvARank:New(self)
end