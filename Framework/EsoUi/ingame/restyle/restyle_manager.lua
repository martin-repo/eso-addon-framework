--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local Restyle_Manager = ZO_CallbackObject:Subclass()

function Restyle_Manager:New(...)
    local singleton = ZO_CallbackObject.New(self)
    singleton:Initialize(...)
    return singleton
end

function Restyle_Manager:Initialize()
    local function CreateRestyleSlotData(objectPool)
        return ZO_RestyleSlotData:New()
    end

    local function ResetRestyleSlotData(restyleSlotData)
        restyleSlotData:SetRestyleMode(RESTYLE_MODE_NONE)
        restyleSlotData:SetRestyleSetIndex(ZO_RESTYLE_DEFAULT_SET_INDEX)
        restyleSlotData:SetRestyleSlotType(0)
    end

    self.restyleSlotDataPool = ZO_ObjectPool:New(CreateRestyleSlotData, ResetRestyleSlotData)
end

function Restyle_Manager:GetRestyleSlotDataMetaPool()
    return ZO_MetaPool:New(self.restyleSlotDataPool)
end

ZO_RESTYLE_MANAGER = Restyle_Manager:New()