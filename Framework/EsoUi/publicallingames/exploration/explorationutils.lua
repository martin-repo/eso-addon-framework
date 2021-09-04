--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-------------------------------
-- Exploration Utilities
-------------------------------

function ZO_ExplorationUtils_GetPlayerCurrentZoneId()
    local zoneIndex = GetUnitZoneIndex("player")
    return GetZoneId(zoneIndex)
end

function ZO_ExplorationUtils_GetZoneStoryZoneIdByZoneIndex(zoneIndex)
    local zoneId = GetZoneId(zoneIndex)
    return GetZoneStoryZoneIdForZoneId(zoneId)
end