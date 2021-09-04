--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local g_soundHandlers = {
    [EVENT_JUSTICE_GOLD_REMOVED] = function()
        return SOUNDS.JUSTICE_GOLD_REMOVED
    end,

    [EVENT_JUSTICE_STOLEN_ITEMS_REMOVED] = function()
        return SOUNDS.JUSTICE_ITEM_REMOVED
    end,

    [EVENT_MEDAL_AWARDED] = function()
        return SOUNDS.BATTLEGROUND_MEDAL_RECEIVED
    end,
}

function ZO_SoundEvents_GetHandlers()
    return g_soundHandlers
end

local function OnSoundEvent(eventId, ...)
    if g_soundHandlers[eventId] then
        local soundId = g_soundHandlers[eventId](...)
        if soundId then
            PlaySound(soundId)
        end
    end
end

function ZO_SoundEvent(eventId, ...)
    OnSoundEvent(eventId, ...)
end

function ZO_SoundEvents_OnInitialized()
    for event in pairs(g_soundHandlers) do
        EVENT_MANAGER:RegisterForEvent("ZO_SoundEvents", event, OnSoundEvent)
    end
end

ZO_SoundEvents_OnInitialized()
