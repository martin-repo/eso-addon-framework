--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-----------------------------
--Fullscreen Effect Fragment
-----------------------------

ZO_FullscreenEffectFragment = ZO_SceneFragment:Subclass()

function ZO_FullscreenEffectFragment:New(effectType, ...)
    local fragment = ZO_SceneFragment.New(self)
    fragment:SetCategory(FRAGMENT_CATEGORY_FULLSCREEN_EFFECT)
    fragment.effectType = effectType
    fragment.params = {...}
    fragment:SetHideOnSceneHidden(true)
    return fragment
end

function ZO_FullscreenEffectFragment:Show()
    SetFullscreenEffect(self.effectType, unpack(self.params))
    self:OnShown()
end

function ZO_FullscreenEffectFragment:Hide()
    SetFullscreenEffect(FULLSCREEN_EFFECT_NONE)
    self:OnHidden()
end

UNIFORM_BLUR_FRAGMENT = ZO_FullscreenEffectFragment:New(FULLSCREEN_EFFECT_UNIFORM_BLUR)