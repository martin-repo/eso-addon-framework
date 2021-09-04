--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

----
-- ZO_CharacterSelect_EventTile_Gamepad
----

-- Primary logic class must be subclassed after the platform class so that platform specific functions will have priority over the logic class functionality
ZO_CharacterSelect_EventTile_Gamepad = ZO_Object.MultiSubclass(ZO_Tile_Gamepad, ZO_CharacterSelect_EventTile_Shared)

function ZO_CharacterSelect_EventTile_Gamepad:New(...)
    return ZO_CharacterSelect_EventTile_Shared.New(self, ...)
end

function ZO_CharacterSelect_EventTile_Gamepad:Initialize(...)
    return ZO_CharacterSelect_EventTile_Shared.Initialize(self, ...)
end

-----
-- Global XML Functions
-----

function ZO_CharacterSelect_EventTile_Gamepad_OnInitialized(control)
    ZO_CharacterSelect_EventTile_Gamepad:New(control)
end