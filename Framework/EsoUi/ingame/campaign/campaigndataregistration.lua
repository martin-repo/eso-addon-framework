--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_CampaignDataRegistration = ZO_Object:Subclass()

function ZO_CampaignDataRegistration:New(...)
    local registration = ZO_Object.New(self)
    registration:Initialize(...)
    return registration
end

function ZO_CampaignDataRegistration:Initialize(namespace, needsDataFunction)
    self.needsDataFunction = needsDataFunction

    EVENT_MANAGER:RegisterForEvent(namespace, EVENT_PLAYER_ACTIVATED, function() self:OnPlayerActivated() end)
    EVENT_MANAGER:RegisterForEvent(namespace, EVENT_PLAYER_DEACTIVATED, function() self:OnPlayerDeactivated() end)

    self.needsData = false
    self:Refresh()
end

function ZO_CampaignDataRegistration:Refresh()
    local needsData = self.needsDataFunction()
    if self.needsData ~= needsData then
        self.needsData = needsData
        if needsData then
            RegisterForAssignedCampaignData()
        else
            UnregisterForAssignedCampaignData()
        end
    end
end

function ZO_CampaignDataRegistration:OnPlayerActivated()
    self:Refresh()
end

function ZO_CampaignDataRegistration:OnPlayerDeactivated()
    if self.needsData then
        UnregisterForAssignedCampaignData()
    end
    self.needsData = false    
end

