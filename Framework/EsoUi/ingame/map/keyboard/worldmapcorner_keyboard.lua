--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local g_nextUpdate = nil

local function UpdateTitle(titleLabel)
    titleLabel:SetText(ZO_WorldMap_GetMapTitle())
end

function ZO_WorldMapCorner_OnInitialized(self)
    local titleLabel = self:GetNamedChild("Title")
    local function UpdateTitleEventCallback()
        UpdateTitle(titleLabel)
    end

    CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", UpdateTitleEventCallback)
    CALLBACK_MANAGER:RegisterCallback("OnWorldMapCampaignChanged", UpdateTitleEventCallback)
    self:RegisterForEvent(EVENT_PLAYER_ACTIVATED, UpdateTitleEventCallback)

    UpdateTitle(titleLabel)
end

function ZO_WorldMapCorner_OnUpdate(self, time)
    if(g_nextUpdate == nil or time > g_nextUpdate) then
        local formattedTime, nextUpdateIn = ZO_FormatClockTime()
        self:GetNamedChild("Time"):SetText(formattedTime)
        g_nextUpdate = time + nextUpdateIn
    end
end