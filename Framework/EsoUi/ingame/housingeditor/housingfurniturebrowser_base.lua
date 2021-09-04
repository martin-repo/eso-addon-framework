--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

HOUSING_BROWSER_MODE =
{
    NONE = 0,
    PLACEMENT = 1,
    PRODUCTS = 2,
    RETRIEVAL = 3,
    SETTINGS = 4,
}

ZO_HousingFurnitureBrowser_Base = ZO_Object:Subclass()

function ZO_HousingFurnitureBrowser_Base:New(...)
    local browserBase = ZO_Object.New(self)
    browserBase:Initialize(...)
    return browserBase
end

function ZO_HousingFurnitureBrowser_Base:Initialize(control, sceneName)
    self.control = control

    self.placeableListDirty = true
    self.productListDirty = true
    self.retrievableListDistancesDirty = true
    self.retrievableListHeadingsDirty = true

    SHARED_FURNITURE:RegisterCallback("PlaceableFurnitureChanged", function()
        if SCENE_MANAGER:IsShowing(sceneName) then
            self:UpdatePlaceablePanel()
        else
            self.placeableListDirty = true
        end
    end)

    SHARED_FURNITURE:RegisterCallback("RetrievableFurnitureChanged", function()
        if SCENE_MANAGER:IsShowing(sceneName) then
            self:UpdateRetrievablePanel()
        else
            self.retrievableListDirty = true
        end
    end)

    SHARED_FURNITURE:RegisterCallback("RetrievableFurnitureDistanceAndHeadingChanged", function()
        if SCENE_MANAGER:IsShowing(sceneName) then
            self:UpdateRetrievablePanelDistancesAndHeadings()
        else
            self.retrievableListDistancesDirty = true
            self.retrievableListHeadingsDirty = true
        end
    end)

    SHARED_FURNITURE:RegisterCallback("RetrievableFurnitureHeadingChanged", function()
        if SCENE_MANAGER:IsShowing(sceneName) then
            self:UpdateRetrievablePanelHeadings()
        else
            self.retrievableListHeadingsDirty = true
        end
    end)

    SHARED_FURNITURE:RegisterCallback("MarketProductsChanged", function()
        if SCENE_MANAGER:IsShowing(sceneName) then
            self:UpdateProductsPanel()
        else
            self.productListDirty = true
        end
    end)

end

function ZO_HousingFurnitureBrowser_Base:UpdatePlaceablePanel()
    --Override
end

function ZO_HousingFurnitureBrowser_Base:UpdateRetrievablePanel()
    --Override
end

function ZO_HousingFurnitureBrowser_Base:UpdateRetrievablePanelDistancesAndHeadings()
    --Override
end

function ZO_HousingFurnitureBrowser_Base:UpdateRetrievablePanelHeadings()
    --Override
end

function ZO_HousingFurnitureBrowser_Base:UpdateProductPanel()
    --Override
end

function ZO_HousingFurnitureBrowser_Base:IsShowing()
    -- To be overridden
    assert(false)
end

function ZO_HousingFurnitureBrowser_Base:OnShowing()
    PlaySound(SOUNDS.HOUSING_EDITOR_OPEN_BROWSER) 
    if self.placeableListDirty then
        self:UpdatePlaceablePanel()
        self.placeableListDirty = false
    end

    if self.retrievableListDirty then
        self:UpdateRetrievablePanel()
    else
        if self.retrievableListHeadingsDirty then
            if self.retrievableListDistancesDirty then
                self:UpdateRetrievablePanelDistancesAndHeadings()
            else
                self:UpdateRetrievablePanelHeadings()
            end
        end
    end
    self.retrievableListDirty = false
    self.retrievableListDistancesDirty = false
    self.retrievableListHeadingsDirty = false

    if self.productListDirty then
        self:UpdateProductsPanel()
        self.productListDirty = false
    end
end

function ZO_HousingFurnitureBrowser_Base:OnHiding()
    PlaySound(SOUNDS.HOUSING_EDITOR_CLOSE_BROWSER) 
end

function ZO_HousingFurnitureBrowser_Base.PreviewFurniture(placeableData)
    if placeableData and IsCharacterPreviewingAvailable() then
        placeableData:Preview()
    end
end

function ZO_HousingFurnitureBrowser_Base.SelectFurnitureForPlacement(placeableData)
    if placeableData then
        placeableData:SelectForPlacement()
        PlaySound(SOUNDS.DEFAULT_CLICK) 
    end
end

function ZO_HousingFurnitureBrowser_Base.SelectFurnitureForReplacement(data)
    local result = HousingEditorSelectFurnitureById(data.retrievableFurnitureId)
    ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
    PlaySound(SOUNDS.DEFAULT_CLICK)
end

function ZO_HousingFurnitureBrowser_Base.SelectNodeForReplacement(data)
    local result = HousingEditorSelectPathNodeByIndex(data.furnitureId, data.pathIndex)
    ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
    PlaySound(SOUNDS.DEFAULT_CLICK)
end

function ZO_HousingFurnitureBrowser_Base.SelectFurnitureForPrecisionEdit(data)
    HousingEditorSetPlacementType(HOUSING_EDITOR_PLACEMENT_TYPE_PRECISION)
    local result = HousingEditorSelectFurnitureById(data.retrievableFurnitureId)
    ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
    PlaySound(SOUNDS.DEFAULT_CLICK)
end

function ZO_HousingFurnitureBrowser_Base.SelectNodeForPrecisionEdit(data)
    HousingEditorSetPlacementType(HOUSING_EDITOR_PLACEMENT_TYPE_PRECISION)
    local result = HousingEditorSelectPathNodeByIndex(data.furnitureId, data.pathIndex)
    ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
    PlaySound(SOUNDS.DEFAULT_CLICK)
end

function ZO_HousingFurnitureBrowser_Base.PutAwayFurniture(data)
    local result = HousingEditorRequestRemoveFurniture(data.retrievableFurnitureId)
    ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
    PlaySound(SOUNDS.DEFAULT_CLICK)
end

function ZO_HousingFurnitureBrowser_Base.PutAwayNode(data)
    local result = HousingEditorRequestRemovePathNode(data.furnitureId, data.pathIndex)
    ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
    PlaySound(SOUNDS.DEFAULT_CLICK)
end

function ZO_HousingFurnitureBrowser_Base.SetAsStartingNode(data)
    local result = HousingEditorRequestSetStartingNodeIndex(data.furnitureId, data.pathIndex)
    ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
    PlaySound(SOUNDS.DEFAULT_CLICK)
end

function ZO_HousingFurnitureBrowser_Base:GetMode()
    return self.mode
end

function ZO_HousingFurnitureBrowser_Base:SetMode(mode)
    if self.mode ~= mode then
        self.mode = mode
    end
end