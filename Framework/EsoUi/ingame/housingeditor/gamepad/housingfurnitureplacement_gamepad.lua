--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_HousingFurniturePlacement_Gamepad = ZO_HousingFurnitureList_Gamepad:Subclass()

function ZO_HousingFurniturePlacement_Gamepad:New(...)
    return ZO_HousingFurnitureList_Gamepad.New(self, ...)
end

function ZO_HousingFurniturePlacement_Gamepad:Initialize(owner)
    ZO_HousingFurnitureList_Gamepad.Initialize(self, owner)

    SHARED_FURNITURE:RegisterCallback("PlaceableFurnitureChanged", function(fromSearch)
        if fromSearch then
            self:ResetSavedPositions()
        end
    end)
end

function ZO_HousingFurniturePlacement_Gamepad:InitializeKeybindStripDescriptors()
    ZO_HousingFurnitureList_Gamepad.InitializeKeybindStripDescriptors(self)

    self:AddFurnitureListKeybind(
        -- Primary
        {
            name =  GetString(SI_HOUSING_EDITOR_PLACE),
            keybind = "UI_SHORTCUT_PRIMARY",
            callback =  function()
                            local targetData = self.furnitureList.list:GetTargetData()
                            if targetData then
                                local furnitureObject = targetData.furnitureObject
                                ZO_HousingFurnitureBrowser_Base.SelectFurnitureForPlacement(furnitureObject)
                                SCENE_MANAGER:HideCurrentScene()
                            end
                        end,
        }
    )

end

function ZO_HousingFurniturePlacement_Gamepad:GetCategoryTreeDataRoot()
    return SHARED_FURNITURE:GetPlaceableFurnitureCategoryTreeData()
end

function ZO_HousingFurniturePlacement_Gamepad:OnFurnitureTargetChanged(list, targetData, oldTargetData)
    ZO_HousingFurnitureList_Gamepad.OnFurnitureTargetChanged(self, list, targetData, oldTargetData)

    if targetData.furnitureObject and targetData.furnitureObject.collectibleId then
        local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(targetData.furnitureObject.collectibleId)
        if collectibleData and collectibleData:IsBlacklisted() then
            ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, HOUSING_REQUEST_RESULT_BLOCKED_BY_BLACKLISTED_COLLECTIBLE)
            return
        end
    end

    ZO_HousingFurnitureBrowser_Base.PreviewFurniture(targetData.furnitureObject)
    self:UpdateCurrentKeybinds()
end

function ZO_HousingFurniturePlacement_Gamepad:GetNoItemText()
    if SHARED_FURNITURE:DoesPlayerHavePlaceableFurniture() then
        return GetString(SI_HOUSING_FURNITURE_NO_SEARCH_RESULTS)
    else
        return GetString(SI_HOUSING_FURNITURE_NO_PLACEABLE_FURNITURE)
    end
end