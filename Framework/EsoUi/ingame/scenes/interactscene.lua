--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_InteractScene_Mixin = {}

function ZO_InteractScene_Mixin:InitializeInteractInfo(interactionInfo)
    if not interactionInfo.OnInteractionCanceled then
        -- If the interact ended for reasons outside of our control (i.e.: combat), this scenes state is essentially no longer valid so we need to abort and come back in anyway
        if not interactionInfo.registeredScenes then
            interactionInfo.registeredScenes = {}
        end

        interactionInfo.OnInteractionCanceled = function()
            local currentScene = SCENE_MANAGER:GetCurrentScene()
            if currentScene and currentScene:IsShowing() and interactionInfo.registeredScenes[currentScene] then
                self.sceneManager:RequestShowLeaderBaseScene(ZO_BHSCR_INTERACT_ENDED)
            end
        end
    end

    if interactionInfo.registeredScenes then
        interactionInfo.registeredScenes[self] = true
    end

    self.interactionInfo = interactionInfo
end

function ZO_InteractScene_Mixin:GetInteractionInfo()
    return self.interactionInfo
end

function ZO_InteractScene_Mixin:SetInteractionInfo(interactionInfo)
    self.interactionInfo = interactionInfo
end

function ZO_InteractScene_Mixin:OnRemovedFromQueue(newNextScene)
    if not INTERACT_WINDOW:IsInteracting(self.interactionInfo) then
        RemoveActionLayerByName("SceneChangeInterceptLayer")
        if not (newNextScene and newNextScene.GetInteractionInfo and newNextScene:GetInteractionInfo() == self.interactionInfo) then
            INTERACT_WINDOW:TerminateClientInteraction(self.interactionInfo)
        end
    end
end

function ZO_InteractScene_Mixin:OnSceneShowing()
    INTERACT_WINDOW:OnBeginInteraction(self.interactionInfo)
end

function ZO_InteractScene_Mixin:OnSceneHidden()
    local endInteraction = true

    local nextScene = self.sceneManager:GetNextScene()
    if nextScene then
        if nextScene.GetInteractionInfo ~= nil then
            local nextSceneInteractionInfo = nextScene:GetInteractionInfo()
            local nextSceneInteractTypes = nextSceneInteractionInfo.interactTypes

            -- see if ALL of my scene's interact types will be satisfied by the next scene
            local allTypesMatched = true
            local mySceneInteractTypes = self.interactionInfo.interactTypes
            for i = 1, #mySceneInteractTypes do
                local typeMatch = false
                for j = 1, #nextSceneInteractTypes do
                    if mySceneInteractTypes[i] == nextSceneInteractTypes[j] then
                        typeMatch = true
                        break
                    end
                end

                if not typeMatch then
                    allTypesMatched = false
                    break
                end
            end

            if allTypesMatched then
                endInteraction = false
            end
        end
    end

    if endInteraction then
        INTERACT_WINDOW:EndInteraction(self.interactionInfo)
    end
end

-- Interact Scene --

ZO_InteractScene = ZO_Scene:Subclass()
zo_mixin(ZO_InteractScene, ZO_InteractScene_Mixin)

function ZO_InteractScene:New(...)
    return ZO_Scene.New(self, ...)
end

function ZO_InteractScene:Initialize(name, sceneManager, interactionInfo)
    ZO_Scene.Initialize(self, name, sceneManager)

    self:InitializeInteractInfo(interactionInfo)
end

function ZO_InteractScene:SetState(newState)
    if newState == SCENE_SHOWING then
        self:OnSceneShowing()
    elseif newState == SCENE_HIDDEN then
        self:OnSceneHidden()
    end

    ZO_Scene.SetState(self, newState)
end

-- Remote Interact Scene --

ZO_RemoteInteractScene = ZO_RemoteScene:Subclass()
zo_mixin(ZO_RemoteInteractScene, ZO_InteractScene_Mixin)

function ZO_RemoteInteractScene:New(...)
    return ZO_RemoteScene.New(self, ...)
end

function ZO_RemoteInteractScene:Initialize(name, sceneManager, interactionInfo)
    ZO_RemoteScene.Initialize(self, name, sceneManager)

    self:InitializeInteractInfo(interactionInfo)
end

function ZO_RemoteInteractScene:SetState(newState)
    if newState == SCENE_SHOWING then
        self:OnSceneShowing()
    elseif newState == SCENE_HIDDEN then
        self:OnSceneHidden()
    end

    ZO_RemoteScene.SetState(self, newState)
end