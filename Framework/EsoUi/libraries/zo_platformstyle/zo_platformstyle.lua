--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local ZO_PlatformStyleManager = ZO_Object:Subclass()

function ZO_PlatformStyleManager:New()
    local obj = ZO_Object.New(self)
    obj:Initialize()
    return obj
end

function ZO_PlatformStyleManager:Initialize()
    self.objects = {}
    EVENT_MANAGER:RegisterForEvent("ZO_PlatformStyleManager", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function() self:OnGamepadPreferredModeChanged() end)
end

function ZO_PlatformStyleManager:Add(object)
    table.insert(self.objects, object)
end

function ZO_PlatformStyleManager:OnGamepadPreferredModeChanged()
    for _, object in ipairs(self.objects) do
        object:Apply()
    end
end

local PLATFORM_STYLE_MANAGER = ZO_PlatformStyleManager:New()


ZO_PlatformStyle = ZO_Object:Subclass()

function ZO_PlatformStyle:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function ZO_PlatformStyle:Initialize(applyFunction, keyboardStyle, gamepadStyle)
    self.applyFunction = applyFunction
    self.keyboardStyle = keyboardStyle
    self.gamepadStyle = gamepadStyle
    self:Apply()
    PLATFORM_STYLE_MANAGER:Add(self)
end

function ZO_PlatformStyle:Apply()
    local style = self:GetStyle()    
    self.applyFunction(style)
end

function ZO_PlatformStyle:GetStyle()
    if IsInGamepadPreferredMode() then
        return self.gamepadStyle
    else
        return self.keyboardStyle
    end
end