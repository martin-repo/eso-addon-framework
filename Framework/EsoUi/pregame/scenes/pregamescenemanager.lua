--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_REMOTE_SCENE_CHANGE_ORIGIN = SCENE_MANAGER_MESSAGE_ORIGIN_PREGAME

local ZO_PregameSceneManager = ZO_SceneManager_Leader:Subclass()

function ZO_PregameSceneManager:New(...)
    return ZO_SceneManager_Leader.New(self, ...)
end

function ZO_PregameSceneManager:OnScenesLoaded()
    self:SetBaseScene("empty")
    self:Show("empty")
end

function ZO_PregameSceneManager:HideTopLevel(top)
    top:SetHidden(true)
end

SCENE_MANAGER = ZO_PregameSceneManager:New()
