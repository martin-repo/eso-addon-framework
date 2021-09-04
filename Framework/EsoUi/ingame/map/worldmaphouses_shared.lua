--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_MapHouses_Shared = ZO_Object:Subclass()

function ZO_MapHouses_Shared:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function ZO_MapHouses_Shared:Initialize(control, fragmentClass)
    self.control = control
    self:InitializeList(control)

    self.fragment = fragmentClass:New(control)
    self.fragment:RegisterCallback("StateChange",  function(oldState, newState)
        if newState == SCENE_FRAGMENT_SHOWING then
            self:OnShowing()
        elseif newState == SCENE_FRAGMENT_HIDDEN then
            self:OnHidden()
        end
    end)

    local function UpdateForModeChange(modeData)
        self:SetListEnabled(WORLD_MAP_MANAGER:IsMapChangingAllowed())
    end

    local function OnFastTravelNetworkUpdated()
        if self.fragment:IsShowing() then
            self:RefreshHouseList()
        end
    end

    CALLBACK_MANAGER:RegisterCallback("OnWorldMapModeChanged", UpdateForModeChange)
    control:RegisterForEvent(EVENT_FAST_TRAVEL_NETWORK_UPDATED, OnFastTravelNetworkUpdated)
end

function ZO_MapHouses_Shared:InitializeList()
    -- To be overriden
end

function ZO_MapHouses_Shared:RefreshHouseList()
    WORLD_MAP_HOUSES_DATA:RefreshHouseList()
    local houseList = WORLD_MAP_HOUSES_DATA:GetHouseList()
    self.noHousesLabel:SetHidden(#houseList > 0)
end

function ZO_MapHouses_Shared:SetListEnabled(enabled)
    self.listEnabled = enabled
end

function ZO_MapHouses_Shared:IsListEnabled()
    return self.listEnabled
end

function ZO_MapHouses_Shared:GetFragment()
    return self.fragment
end

function ZO_MapHouses_Shared:SetNoHousesLabelControl(control)
    self.noHousesLabel = control
end

function ZO_MapHouses_Shared:OnShowing()
    self:RefreshHouseList()
end

function ZO_MapHouses_Shared:OnHidden()
    --To be overriden
end