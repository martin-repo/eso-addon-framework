--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:23' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local LoadingScreen_Keyboard = {}

function LoadingScreen_Keyboard:InitializeAnimations()
    self.spinnerFadeAnimation = GetAnimationManager():CreateTimelineFromVirtual("SpinnerFadeAnimation", LoadingScreenSpinner)

    self.animations = GetAnimationManager():CreateTimelineFromVirtual("LoadingCompleteAnimation")
    self.animations:GetAnimation(1):SetAnimatedControl(LoadingScreenArt)
    self.animations:GetAnimation(2):SetAnimatedControl(LoadingScreenTopMunge)
    self.animations:GetAnimation(3):SetAnimatedControl(LoadingScreenTopMunge)
    self.animations:GetAnimation(4):SetAnimatedControl(LoadingScreenBottomMunge)
    self.animations:GetAnimation(5):SetAnimatedControl(LoadingScreenBottomMunge)
    self.animations.control = self
    self.animations:SetHandler("OnStop", function(timeline) self:LoadingCompleteAnimation_OnStop(timeline) end)
end

function LoadingScreen_Keyboard:IsPreferredScreen()
    return not IsInGamepadPreferredMode()
end

function LoadingScreen_Keyboard:GetSystemName()
    return "LoadingScreen"
end

function ZO_InitKeyboardLoadScreen(control)
    zo_mixin(control, LoadingScreen_Base, LoadingScreen_Keyboard)
    control:Initialize(control)
end