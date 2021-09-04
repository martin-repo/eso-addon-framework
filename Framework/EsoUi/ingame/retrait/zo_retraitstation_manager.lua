--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local RetraitStationManager = ZO_CallbackObject:Subclass()

function RetraitStationManager:New(...)
    local obj = ZO_CallbackObject.New(self)
    obj:Initialize(...)
    return obj
end

function RetraitStationManager:Initialize()
    self:RegisterForEvents()
    self:InitializeTraitData()
end

function RetraitStationManager:InitializeTraitData()
    self.traitInfo = {
        [ITEM_TRAIT_TYPE_CATEGORY_WEAPON] = {},
        [ITEM_TRAIT_TYPE_CATEGORY_ARMOR] = {},
        [ITEM_TRAIT_TYPE_CATEGORY_JEWELRY] = {},
    }

    local traitItems = ZO_CraftingUtils_GetSmithingTraitItemInfo()
    for _, traitItemInfo in ipairs(traitItems) do
        local traitCategory = GetItemTraitTypeCategory(traitItemInfo.type)
        local traitName = GetString("SI_ITEMTRAITTYPE", traitItemInfo.type)
        if self.traitInfo[traitCategory] then
            table.insert(self.traitInfo[traitCategory], {
                traitType = traitItemInfo.type,
                traitItemIcon = traitItemInfo.icon,
                traitName = zo_strformat(SI_SMITHING_RESEARCH_TRAIT_NAME_FORMAT, traitName)
            })
        end
    end
end

function RetraitStationManager:RegisterForEvents()
    EVENT_MANAGER:RegisterForEvent("RetraitStationManager", EVENT_RETRAIT_STATION_INTERACT_START, function(eventCode) SYSTEMS:ShowScene("retrait") end)
    EVENT_MANAGER:RegisterForEvent("RetraitStationManager", EVENT_RETRAIT_RESPONSE, function(eventCode, result) SYSTEMS:GetObject("retrait"):OnRetraitResult(result) end)

    local function HandleDirtyEvent()
        self:FireCallbacks("OnRetraitDirtyEvent")
    end

    EVENT_MANAGER:RegisterForEvent("RetraitStationManager", EVENT_INVENTORY_FULL_UPDATE, HandleDirtyEvent)
    EVENT_MANAGER:RegisterForEvent("RetraitStationManager", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, HandleDirtyEvent)
    EVENT_MANAGER:RegisterForEvent("RetraitStationManager", EVENT_SMITHING_TRAIT_RESEARCH_STARTED, HandleDirtyEvent)
    EVENT_MANAGER:RegisterForEvent("RetraitStationManager", EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, HandleDirtyEvent)
end

do
    local retraitScenes = {}
    function RetraitStationManager:RegisterRetraitScene(retraitSceneName)
        retraitScenes[retraitSceneName] = true
    end

    function RetraitStationManager:IsRetraitSceneShowing()
        local showingSceneName = SCENE_MANAGER:GetCurrentSceneName()
        if showingSceneName then
            return retraitScenes[showingSceneName] == true
        end

        return false
    end

    function RetraitStationManager:IsRetraitFragmentShowing()
        if IsInGamepadPreferredMode() then
            return GAMEPAD_RETRAIT_FRAGMENT:IsShowing()
        else
            return RETRAIT_STATION_RETRAIT_FRAGMENT:IsShowing()
        end
    end

    function RetraitStationManager:IsReconstructFragmentShowing()
        if IsInGamepadPreferredMode() then
            return GAMEPAD_RECONSTRUCT_FRAGMENT:IsShowing()
        else
            return RETRAIT_STATION_RECONSTRUCT_FRAGMENT:IsShowing()
        end
    end
end

function RetraitStationManager:GetTraitInfo()
    return self.traitInfo
end

function RetraitStationManager:GetTraitInfoForCategory(itemTraitTypeCategory)
    return self.traitInfo[itemTraitTypeCategory]
end

ZO_RETRAIT_STATION_MANAGER = RetraitStationManager:New()