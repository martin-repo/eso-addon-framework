--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

----
-- ZO_CharacterSelect_EventTile_Keyboard
----

-- Primary logic class must be subclassed after the platform class so that platform specific functions will have priority over the logic class functionality
ZO_CharacterSelect_EventTile_Keyboard = ZO_Object.MultiSubclass(ZO_Tile_Keyboard, ZO_CharacterSelect_EventTile_Shared)

function ZO_CharacterSelect_EventTile_Keyboard:New(...)
    return ZO_CharacterSelect_EventTile_Shared.New(self, ...)
end

function ZO_CharacterSelect_EventTile_Keyboard:Initialize(...)
    return ZO_CharacterSelect_EventTile_Shared.Initialize(self, ...)
end

----
-- ZO_CharacterSelect_SmallEventTile_Keyboard
----

ZO_CharacterSelect_SmallEventTile_Keyboard = ZO_CharacterSelect_EventTile_Keyboard:Subclass()

function ZO_CharacterSelect_SmallEventTile_Keyboard:New(...)
    return ZO_CharacterSelect_EventTile_Keyboard.New(self, ...)
end

function ZO_CharacterSelect_SmallEventTile_Keyboard:Initialize(...)
    return ZO_CharacterSelect_EventTile_Keyboard.Initialize(self, ...)
end

function ZO_CharacterSelect_SmallEventTile_Keyboard:Layout(data)
    ZO_CharacterSelect_EventTile_Shared.Layout(self, data)

    self:SetEventImage(data.image)
end

-----
-- Global XML Functions
-----

function ZO_CharacterSelect_EventTile_Keyboard_OnInitialized(control)
    ZO_CharacterSelect_EventTile_Keyboard:New(control)
end

function ZO_CharacterSelect_SmallEventTile_Keyboard_OnInitialized(control)
    ZO_CharacterSelect_SmallEventTile_Keyboard:New(control)
end