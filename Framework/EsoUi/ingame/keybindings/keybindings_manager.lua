--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local KeybindingsManager = ZO_Object:Subclass()

function KeybindingsManager:New()
    local obj = ZO_Object.New(self)
    obj:Initialize()
    return obj
end

function KeybindingsManager:Initialize()
    local function OnAddOnLoaded(event, name)
        if name == "ZO_Ingame" then
            PushActionLayerByName(GetString(SI_KEYBINDINGS_LAYER_GENERAL))
            EVENT_MANAGER:UnregisterForEvent("KeybindingsManager", EVENT_ADD_ON_LOADED)
        end
    end

    EVENT_MANAGER:RegisterForEvent("KeybindingsManager", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end

KEYBINDINGS_MANAGER = KeybindingsManager:New()