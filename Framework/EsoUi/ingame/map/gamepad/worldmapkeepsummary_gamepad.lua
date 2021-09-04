--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_KEEP_SUMMARY_GAMEPAD_OFFSET_X = 10

--Keep Summary Window Gamepad
local MapKeepSummary_Gamepad = ZO_MapKeepSummary_Shared:Subclass()

function MapKeepSummary_Gamepad:New(...)
    local object = ZO_MapKeepSummary_Shared.New(self, ...)
    return object
end

function MapKeepSummary_Gamepad:GetKeepUpgradeObject()
    return GAMEPAD_WORLD_MAP_KEEP_INFO:GetKeepUpgradeObject()
end

function MapKeepSummary_Gamepad:Initialize(control)
    self.rowLayout = "ZO_WorldMapKeepSummaryRow_Gamepad"
    ZO_MapKeepSummary_Shared.Initialize(self, control)
end

--Global XML

function ZO_WorldMapKeepSummary_Gamepad_OnInitialized(self)
    GAMEPAD_WORLD_MAP_KEEP_SUMMARY = MapKeepSummary_Gamepad:New(self)
    GAMEPAD_WORLD_MAP_KEEP_INFO:SetFragment("SUMMARY_FRAGMENT", GAMEPAD_WORLD_MAP_KEEP_SUMMARY:GetFragment())
end