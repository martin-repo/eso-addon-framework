--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local PresenceEvents = "PresenceEvents"

local function UpdateInformation()
	UpdatePlayerPresenceInformation()
end

local function UpdateName()
	UpdatePlayerPresenceName()
end

local function OnPlayerActivated()
    UpdateInformation()
    UpdateName()
end

local platform = GetUIPlatform()
if platform ~= UI_PLATFORM_PC then
    EVENT_MANAGER:RegisterForEvent(PresenceEvents, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(PresenceEvents, EVENT_LEVEL_UPDATE, UpdateInformation)
    EVENT_MANAGER:RegisterForEvent(PresenceEvents, EVENT_CHAMPION_POINT_UPDATE, UpdateInformation)
    EVENT_MANAGER:RegisterForEvent(PresenceEvents, EVENT_ZONE_UPDATE, UpdateInformation)
end