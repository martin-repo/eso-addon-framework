--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_RzChroma_Manager = ZO_CallbackObject:Subclass()

function ZO_RzChroma_Manager:New(...)
    local singleton = ZO_CallbackObject.New(self)
    singleton:Initialize(...)
    return singleton
end

function ZO_RzChroma_Manager:Initialize()
    self:RegisterForEvents()

    self.deviceClearFunctions =
    {
        [CHROMA_DEVICE_TYPE_HEADSET] = ChromaClearHeadsetEffect,
    }

    self.activeEffects = {}
    self.dirtyDevices = {}

    self:MarkAllDirty()
end

function ZO_RzChroma_Manager:RegisterForEvents()
    local function OnUpdate(timeMs)
        self:OnUpdate(timeMs)
    end

    EVENT_MANAGER:RegisterForUpdate("RzChromaManager", 15, OnUpdate)
end

function ZO_RzChroma_Manager:OnUpdate(timeMs)
    self:FireCallbacks("OnUpdate", timeMs, self)
    for deviceType, _ in pairs(self.dirtyDevices) do
        self.dirtyDevices[deviceType] = nil

        self:ResetEffectState(deviceType)
        self:ProcessActiveEffects(deviceType)
        self:ApplyEffectState(deviceType)
    end
end

function ZO_RzChroma_Manager:ResetEffectState(deviceType)
    ChromaResetCustomEffectObject(deviceType)
    if self.deviceClearFunctions[deviceType] then
        self.deviceClearFunctions[deviceType]()
    end
end

function ZO_RzChroma_Manager:ProcessActiveEffects(deviceType)
    local activeDeviceEffects = self.activeEffects[deviceType]
    if activeDeviceEffects then
        for i, activeEffect in ipairs(activeDeviceEffects) do
            if activeEffect:IsCustom() then
                ZO_CHROMA_RENDERER:RenderEffect(activeEffect)
            else
                activeEffect:FireCreateFunction()
            end
        end
    end
end

function ZO_RzChroma_Manager:ApplyEffectState(deviceType)
    ChromaFinalizeCustomEffect(deviceType)
end

local function EffectSort(effect1, effect2)
    return effect1:GetDrawLevel() < effect2:GetDrawLevel()
end

function ZO_RzChroma_Manager:AddEffect(effect)
    local deviceType = effect:GetDeviceType()
    local activeDeviceEffects = self.activeEffects[deviceType]
    if not activeDeviceEffects then
        activeDeviceEffects = {}
        self.activeEffects[deviceType] = activeDeviceEffects
    end
    table.insert(activeDeviceEffects, effect)
    table.sort(activeDeviceEffects, EffectSort)
    effect:HandleAddEffect(self)
    self:MarkDirty(deviceType)
end

function ZO_RzChroma_Manager:RemoveEffect(effect)
    local deviceType = effect:GetDeviceType()
    local activeDeviceEffects = self.activeEffects[deviceType]
    if activeDeviceEffects then
        for i, activeEffect in ipairs(activeDeviceEffects) do
            if activeEffect == effect then
                table.remove(activeDeviceEffects, i)
                effect:HandleRemoveEffect(self)
                self:MarkDirty(deviceType)
                break
            end
        end
    end
end

function ZO_RzChroma_Manager:MarkAllDirty()
    for deviceType = CHROMA_DEVICE_TYPE_ITERATION_BEGIN, CHROMA_DEVICE_TYPE_ITERATION_END do
        self:MarkDirty(deviceType)
    end
end

function ZO_RzChroma_Manager:MarkDirty(deviceType)
    self.dirtyDevices[deviceType] = true
end