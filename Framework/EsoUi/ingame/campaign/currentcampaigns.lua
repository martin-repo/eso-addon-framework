--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local CURRENT_CAMPAIGNS
CurrentCampaigns = ZO_Object:Subclass()

function CurrentCampaigns:New(control)
    local manager = ZO_Object.New(self)
    manager.control = control
    manager.assigned = GetControl(control, "Assigned")

    control:RegisterForEvent(EVENT_ASSIGNED_CAMPAIGN_CHANGED, function(_, assignedCampaignId) self:RefreshCampaign(assignedCampaignId, manager.assigned) end)

    manager:RefreshCampaigns()

    return manager
end

function CurrentCampaigns:RefreshCampaigns()
    self:RefreshCampaign(GetAssignedCampaignId(), self.assigned)
end

function CurrentCampaigns:RefreshCampaign(campaignId, label)
    label:SetText(ZO_CurrentCampaigns_GetName(campaignId))
end

function ZO_CurrentCampaigns_GetName(campaignId)
    local campaignName
    if campaignId ~= 0 then
        campaignName = ZO_CachedStrFormat(SI_CAMPAIGN_NAME, GetCampaignName(campaignId))
    else
        campaignName = GetString(SI_UNASSIGNED_CAMPAIGN)
    end
    return campaignName
end

function ZO_CurrentCampaigns_OnInitialized(self)
    CURRENT_CAMPAIGNS = CurrentCampaigns:New(self)
end