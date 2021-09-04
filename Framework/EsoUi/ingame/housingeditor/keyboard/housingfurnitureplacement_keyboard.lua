--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_HousingFurniturePlacement_Keyboard = ZO_HousingFurnitureList:Subclass()

function ZO_HousingFurniturePlacement_Keyboard:New(...)
    return ZO_HousingFurnitureList.New(self, ...)
end

function ZO_HousingFurniturePlacement_Keyboard:OnShowing()
    ZO_HousingFurnitureList.OnShowing(self)

    self.searchEditBox:SetText(SHARED_FURNITURE:GetPlaceableTextFilter())
end

function ZO_HousingFurniturePlacement_Keyboard:InitializeKeybindStrip()
    self.keybindStripDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        {
            name = GetString(SI_HOUSING_EDITOR_PLACE),
            keybind = "UI_SHORTCUT_PRIMARY",
            callback = function()
                local mostRecentlySelectedData = self:GetMostRecentlySelectedData()
                self:SelectForPlacement(mostRecentlySelectedData)
            end,
            enabled = function()
                local hasSelection = self:GetMostRecentlySelectedData() ~= nil
                if not hasSelection then
                    return false, GetString(SI_HOUSING_BROWSER_MUST_CHOOSE_TO_PLACE)
                end
                return true
            end,
        },
        {
            name = GetString(SI_CRAFTING_EXIT_PREVIEW_MODE),
            keybind = "UI_SHORTCUT_NEGATIVE",
            callback = function()
                self:ClearSelection()
            end,
            visible = function()
                local hasSelection = self:GetMostRecentlySelectedData() ~= nil and IsCurrentlyPreviewing()
                return hasSelection
            end,
        },
    }
end

function ZO_HousingFurniturePlacement_Keyboard:InitializeThemeSelector()
    self.placementThemeDropdown = self.contents:GetNamedChild("Dropdown")

    local function OnThemeChanged(comboBox, entryText, entry)
        SHARED_FURNITURE:SetPlacementFurnitureTheme(entry.furnitureTheme)
    end

    ZO_HousingSettingsTheme_SetupDropdown(self.placementThemeDropdown, OnThemeChanged)
end

function ZO_HousingFurniturePlacement_Keyboard:OnSearchTextChanged(editBox)
    ZO_HousingFurnitureList.OnSearchTextChanged(self, editBox)
    SHARED_FURNITURE:SetPlaceableTextFilter(editBox:GetText())
end

function ZO_HousingFurniturePlacement_Keyboard:AddListDataTypes()

    local function IsFurnitureCollectibleBlacklisted(collectibleId)
        if collectibleId then
            local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
            return collectibleData and collectibleData:IsBlacklisted()
        end
        return false
    end

    self.PlaceableFurnitureOnMouseClickCallback = function(control, buttonIndex, upInside)
        if buttonIndex == MOUSE_BUTTON_INDEX_LEFT and upInside then
            if control.furnitureObject and IsFurnitureCollectibleBlacklisted(control.furnitureObject.collectibleId) then
                ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, HOUSING_REQUEST_RESULT_BLOCKED_BY_BLACKLISTED_COLLECTIBLE)
            else
                ZO_ScrollList_MouseClick(self:GetList(), control)
            end
        end
    end

    self.PlaceableFurnitureOnMouseDoubleClickCallback = function(control, buttonIndex)
        if buttonIndex == MOUSE_BUTTON_INDEX_LEFT then
            if control.furnitureObject and IsFurnitureCollectibleBlacklisted(control.furnitureObject.collectibleId) then
                ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, HOUSING_REQUEST_RESULT_BLOCKED_BY_BLACKLISTED_COLLECTIBLE)
            else
                local data = ZO_ScrollList_GetData(control)
                self:SelectForPlacement(data)
            end
        end
    end

    self:AddDataType(ZO_PLACEABLE_HOUSING_DATA_TYPE, "ZO_PlayerFurnitureSlot", ZO_HOUSING_FURNITURE_LIST_ENTRY_HEIGHT, function(...) self:SetupFurnitureRow(...) end, ZO_HousingFurnitureBrowser_Keyboard.OnHideFurnitureRow)
end

function ZO_HousingFurniturePlacement_Keyboard:SelectForPlacement(data)
    ZO_HousingFurnitureBrowser_Base.SelectFurnitureForPlacement(data)
    SCENE_MANAGER:HideCurrentScene()
end

function ZO_HousingFurniturePlacement_Keyboard:SetupFurnitureRow(control, data)
    ZO_HousingFurnitureBrowser_Keyboard.SetupFurnitureRow(control, data, self.PlaceableFurnitureOnMouseClickCallback, self.PlaceableFurnitureOnMouseDoubleClickCallback)
end

function ZO_HousingFurniturePlacement_Keyboard:GetCategoryTreeData()
    return SHARED_FURNITURE:GetPlaceableFurnitureCategoryTreeData()
end

function ZO_HousingFurniturePlacement_Keyboard:GetNoItemText()
    if SHARED_FURNITURE:DoesPlayerHavePlaceableFurniture() then
        return GetString(SI_HOUSING_FURNITURE_NO_SEARCH_RESULTS)
    else
        return GetString(SI_HOUSING_FURNITURE_NO_PLACEABLE_FURNITURE)
    end
end