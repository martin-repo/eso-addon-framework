--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_ScreenshotMode_Gamepad = ZO_InitializingObject:Subclass()

local HIDE_DURATION_S = 3
local FADE_DURATION_S = 1.5

function ZO_ScreenshotMode_Gamepad:Initialize(control)
    self.control = control

    self.exitButton = control:GetNamedChild("ExitButton")
    self.toggleNameplatesButton = control:GetNamedChild("ToggleNameplatesButton")
    ApplyTemplateToControl(self.exitButton, "ZO_KeybindButton_Gamepad_Template")
    ApplyTemplateToControl(self.toggleNameplatesButton, "ZO_KeybindButton_Gamepad_Template")
    self.exitButton:SetText(GetString(SI_DIALOG_EXIT))
    self.toggleNameplatesButton:SetText(GetString(SI_TOGGLE_NAMEPLATES))
    self.exitButton:SetKeybind("SCREENSHOT_MODE_EXIT")
    self.toggleNameplatesButton:SetKeybind("SCREENSHOT_MODE_TOGGLE_NAMEPLATES")

    GAMEPAD_SCREENSHOT_MODE_SCENE = ZO_Scene:New("gamepadScreenshotMode", SCENE_MANAGER)
    GAMEPAD_SCREENSHOT_MODE_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            self.hideKeybindsAtS = GetGameTimeSeconds() + HIDE_DURATION_S

            self.previousNameplateSetting = GetSetting_Bool(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_NAMEPLATES)
            self.previousHealthBarSetting = GetSetting_Bool(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_HEALTHBARS)
            self.previousGroupIndicatorSetting = GetSetting_Bool(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_INDICATORS)
            SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_HEALTHBARS, "false")
            SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_INDICATORS, "false")
        elseif newState == SCENE_HIDDEN then
            SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_NAMEPLATES, self.previousNameplateSetting and "true" or "false")
            SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_HEALTHBARS, self.previousHealthBarSetting and "true" or "false")
            SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_INDICATORS, self.previousGroupIndicatorSetting and "true" or "false")
            SetGuiHidden("ingame", false)
            self.control:SetAlpha(1)
        end
    end)

    control:SetHandler("OnUpdate", function(_, timeS)
        if self.hideKeybindsAtS then
            if timeS >= self.hideKeybindsAtS then
                self.hideKeybindsAtS = nil
                SetGuiHidden("ingame", true)
            else
                local timeUntilHideS = self.hideKeybindsAtS - timeS
                if timeUntilHideS < FADE_DURATION_S then
                    self.control:SetAlpha(timeUntilHideS / FADE_DURATION_S)
                end
            end
        end
    end)

    self.fragment = ZO_SimpleSceneFragment:New(control)
    GAMEPAD_SCREENSHOT_MODE_SCENE:AddFragment(self.fragment)

    control:RegisterForEvent(EVENT_CONTROLLER_DISCONNECTED, function() self:OnControllerDisconnected() end)
end

function ZO_ScreenshotMode_Gamepad:OnControllerDisconnected()
    self:Hide()
end

function ZO_ScreenshotMode_Gamepad:Show()
    if SCENE_MANAGER:SetInUIMode(false) then
        SCENE_MANAGER:SetHUDScene("gamepadScreenshotMode")
    end
end

function ZO_ScreenshotMode_Gamepad:Hide()
    if self:IsShowing() then
        SCENE_MANAGER:RestoreHUDScene()
    end
end

function ZO_ScreenshotMode_Gamepad:IsShowing()
    return SCENE_MANAGER:GetHUDSceneName() == "gamepadScreenshotMode"
end

function ZO_ScreenshotMode_Gamepad:ExitKeybind()
    if not self.hideKeybindsAtS then
        SetGuiHidden("ingame", false)
        self.hideKeybindsAtS = GetGameTimeSeconds() + HIDE_DURATION_S
        self.control:SetAlpha(1)
    else
        self:Hide()
    end
end

function ZO_ScreenshotMode_Gamepad:ShowUIKeybind()
    if not self.hideKeybindsAtS then
        SetGuiHidden("ingame", false)
    end
    self.hideKeybindsAtS = GetGameTimeSeconds() + HIDE_DURATION_S
    self.control:SetAlpha(1)
end

function ZO_ScreenshotMode_Gamepad:ToggleNameplatesKeybind()
    local currentNameplateVisibility = GetSetting_Bool(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_NAMEPLATES)
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_NAMEPLATES, currentNameplateVisibility and "false" or "true")
end

function ZO_ScreenshotMode_GamepadTopLevel_OnInitialized(self)
    SCREENSHOT_MODE_GAMEPAD = ZO_ScreenshotMode_Gamepad:New(self)
end