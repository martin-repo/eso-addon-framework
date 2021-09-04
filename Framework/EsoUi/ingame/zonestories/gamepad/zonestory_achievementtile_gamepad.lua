--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_ZONE_STORIES_ACHIEVEMENT_TILE_GAMEPAD_DIMENSIONS_X = 390
ZO_ZONE_STORIES_ACHIEVEMENT_TILE_GAMEPAD_DIMENSIONS_Y = 90
ZO_ZONE_STORIES_ACHIEVEMENT_TILE_GAMEPAD_ICON_DIMENSIONS = 64

-- Primary logic class must be subclassed after the platform class so that platform specific functions will have priority over the logic class functionality
ZO_ZoneStory_AchievementTile_Gamepad = ZO_Object.MultiSubclass(ZO_Tile_Gamepad, ZO_ZoneStory_AchievementTile)

function ZO_ZoneStory_AchievementTile_Gamepad:New(...)
    return ZO_ZoneStory_AchievementTile.New(self, ...)
end

function ZO_ZoneStory_AchievementTile_Gamepad_OnInitialized(control)
    ZO_ZoneStory_AchievementTile_Gamepad:New(control)
end