--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_WorldMapInfo_Shared = ZO_Object:Subclass()

function ZO_WorldMapInfo_Shared:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function ZO_WorldMapInfo_Shared:Initialize(control, fragmentClass)
    self.control = control

    self.worldMapInfoFragment = fragmentClass:New(control)
    self.worldMapInfoFragment:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_FRAGMENT_SHOWING then
            self:OnShowing()
        elseif newState == SCENE_FRAGMENT_HIDDEN then
            self:OnHidden()
        end
    end)

    self:InitializeTabs()
end

function ZO_WorldMapInfo_Shared:GetFragment()
    return self.worldMapInfoFragment
end

function ZO_WorldMapInfo_Shared:OnShowing()
    -- To be overridden
end

function ZO_WorldMapInfo_Shared:OnHidden()
    -- To be overridden
end