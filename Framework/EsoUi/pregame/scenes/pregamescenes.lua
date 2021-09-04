--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-------------------
--Gamma Adjust
-------------------

local gammaAdjustScene = ZO_Scene:New("gammaAdjust", SCENE_MANAGER)
gammaAdjustScene:AddFragment(GAMMA_SCENE_FRAGMENT)
gammaAdjustScene:AddFragment(PREGAME_GAMMA_ADJUST_INTRO_ADVANCE_FRAGMENT)

------------------------
--Screen Adjust Scene
------------------------

local screenAdjustScene = ZO_Scene:New("screenAdjust", SCENE_MANAGER)
screenAdjustScene:AddFragment(SCREEN_ADJUST_SCENE_FRAGMENT)
screenAdjustScene:AddFragment(SCREEN_ADJUST_ACTION_LAYER_FRAGMENT)
screenAdjustScene:AddFragment(PREGAME_SCREEN_ADJUST_INTRO_ADVANCE_FRAGMENT)

SCENE_MANAGER:OnScenesLoaded()
