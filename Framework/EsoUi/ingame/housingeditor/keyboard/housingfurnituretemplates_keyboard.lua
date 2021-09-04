--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_HOUSING_FURNITURE_LIST_ENTRY_HEIGHT = 52
ZO_HOUSING_FURNITURE_BROWSER_CATEGORY_LIST_WIDTH = 310
local scrollBarOffset = 16
-- 55 is the inset from the left side of the header to the left side of the text in ZO_IconHeader
ZO_HOUSING_FURNITURE_BROWSER_CATEGORY_LABEL_WIDTH = ZO_HOUSING_FURNITURE_BROWSER_CATEGORY_LIST_WIDTH - 55 - scrollBarOffset
ZO_HOUSING_FURNITURE_BROWSER_SUBCATEGORY_INDENT = 60
ZO_HOUSING_FURNITURE_BROWSER_SUBCATEGORY_LABEL_WIDTH = ZO_HOUSING_FURNITURE_BROWSER_CATEGORY_LIST_WIDTH - ZO_HOUSING_FURNITURE_BROWSER_SUBCATEGORY_INDENT - scrollBarOffset

-------------------
-- XML Functions
-------------------

function ZO_HousingFurnitureTemplates_Keyboard_OnInitialized(control)
    control.name = control:GetNamedChild("Name")
    control.statusIcon = control:GetNamedChild("StatusIcon")
    control.icon = control:GetNamedChild("Icon")
    control.stackCount = control.icon:GetNamedChild("StackCount")
    control.highlight = control:GetNamedChild("Highlight")
end

function ZO_HousingFurnitureTemplates_Keyboard_OnMouseClick(control, buttonIndex, upInside)
    if control.OnMouseClickCallback then
        control.OnMouseClickCallback(control, buttonIndex, upInside)
        local furnitureObject = control.furnitureObject
        if furnitureObject then
            if furnitureObject:IsBeingPreviewed() then
                WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
            end
        end
    end
end

function ZO_HousingFurnitureTemplates_Keyboard_OnMouseDoubleClick(control, buttonIndex)
    if control.OnMouseDoubleClickCallback then
        control.OnMouseDoubleClickCallback(control, buttonIndex)
    end
end

function ZO_HousingFurnitureTemplates_Keyboard_SetListHighlightHidden(control, hidden, instant)
    local highlight = control.highlight
    if not highlight.animation then
        highlight.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", highlight)
    end
    if hidden then
        ZO_Animation_PlayBackwardOrInstantlyToStart(highlight.animation, instant)
    else
        ZO_Animation_PlayFromStartOrInstantlyToEnd(highlight.animation, instant)
    end
end

function ZO_HousingFurnitureTemplates_Keyboard_OnMouseEnter(control)
    local ANIMATED = false
    ZO_HousingFurnitureTemplates_Keyboard_SetListHighlightHidden(control, false, ANIMATED)

    local icon = control.icon
    if not icon.animation then
        icon.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("IconSlotMouseOverAnimation", icon)
    end

    icon.animation:PlayForward()

    local furnitureObject = control.furnitureObject
    if furnitureObject then
        if IsCharacterPreviewingAvailable() and furnitureObject:IsPreviewable() and not furnitureObject:IsBeingPreviewed() then
            WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_PREVIEW)
        end

        if furnitureObject:GetDataType() == ZO_HOUSING_PATH_NODE_DATA_TYPE then
            return -- TODO: for now?
        end

        InitializeTooltip(ItemTooltip, control, RIGHT, -15, 0, LEFT)
        if furnitureObject.bagId and furnitureObject.slotIndex then
            ItemTooltip:SetBagItem(furnitureObject.bagId, furnitureObject.slotIndex)
        elseif furnitureObject.marketProductId then
            ItemTooltip:SetMarketProductListing(furnitureObject.marketProductId, furnitureObject.presentationIndex)
        elseif furnitureObject.collectibleId then
            local SHOW_NICKNAME = true
            ItemTooltip:SetCollectible(furnitureObject.collectibleId, SHOW_NICKNAME)
        elseif furnitureObject.retrievableFurnitureId then
            ItemTooltip:SetPlacedFurniture(furnitureObject.retrievableFurnitureId)
        end
    end
end

function ZO_HousingFurnitureTemplates_Keyboard_OnMouseExit(control)
    local ANIMATED = false
    ZO_HousingFurnitureTemplates_Keyboard_SetListHighlightHidden(control, true, ANIMATED)

    local icon = control.icon
    if icon.animation then
        icon.animation:PlayBackward()
    end

    WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)

    ClearTooltip(ItemTooltip)
end

function ZO_MarketProductHousingFurnitureTemplates_Keyboard_OnInitialized(control)
    ZO_HousingFurnitureTemplates_Keyboard_OnInitialized(control)
    control.cost = control:GetNamedChild("Cost")
    control.previousCost = control:GetNamedChild("PreviousCost")
    control.textCallout = control:GetNamedChild("TextCallout")
    control.textCalloutBackground = control.textCallout:GetNamedChild("Background")
    control.textCalloutLeftBackground = control.textCalloutBackground:GetNamedChild("Left")
    control.textCalloutRightBackground = control.textCalloutBackground:GetNamedChild("Right")
    control.textCalloutCenterBackground = control.textCalloutBackground:GetNamedChild("Center")
end

function ZO_HousingSettingsTemplates_Keyboard_OnMouseEnter(control)
    local data = control.data
    local tooltipFunction = data.tooltipFunction
    tooltipFunction(control)
end

function ZO_HousingSettingsTemplates_Keyboard_OnMouseExit(control)
    ClearTooltip(InformationTooltip)
end