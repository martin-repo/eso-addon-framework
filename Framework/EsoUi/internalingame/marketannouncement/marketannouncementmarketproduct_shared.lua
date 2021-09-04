--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_MARKET_ANNOUNCEMENT_MARKET_PRODUCT_WIDTH = 1024
ZO_MARKET_ANNOUNCEMENT_MARKET_PRODUCT_HEIGHT = 512

ZO_MARKET_ANNOUNCEMENT_MARKET_PRODUCT_INFO_WIDTH = 350
ZO_MARKET_ANNOUNCEMENT_MARKET_PRODUCT_INFO_OFFSET_X = 20

local DESCRIPTION_TEXT_COLORS = {
    SELECTED_TEXT_COLOR = ZO_NORMAL_TEXT,
    UNSELECTED_TEXT_COLOR = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_GAMEPAD_CATEGORY_HEADER))
}

----
-- ZO_MarketAnnouncementMarketProduct_Shared
----

ZO_MarketAnnouncementMarketProduct_Shared = ZO_LargeSingleMarketProduct_Base:Subclass()

function ZO_MarketAnnouncementMarketProduct_Shared:New(...)
    return ZO_LargeSingleMarketProduct_Base.New(self, ...)
end

function ZO_MarketAnnouncementMarketProduct_Shared:Initialize(...)
    ZO_LargeSingleMarketProduct_Base.Initialize(self, ...)
end

function ZO_MarketAnnouncementMarketProduct_Shared:Show(...)
    ZO_LargeSingleMarketProduct_Base.Show(self, ...)

    local descriptionText = ""
    local description = self.productData:GetMarketProductDescription()
    local itemLink = GetMarketProductItemLink(self:GetId())
    if itemLink ~= "" then
        local hasAbility, _, abilityDescription = GetItemLinkOnUseAbilityInfo(itemLink)

        if hasAbility then
            if description ~= "" then
                descriptionText = string.format("%s\n\n%s", abilityDescription, description)
            else
                descriptionText = abilityDescription
            end
        end
    end

    if descriptionText == "" then
        descriptionText = description
    end

    self.control.descriptionTextControl:SetText(zo_strformat(SI_MARKET_PRODUCT_DESCRIPTION_FORMATTER, descriptionText))
end

function ZO_MarketAnnouncementMarketProduct_Shared:SetOnInteractWithScrollCallback(onInteractWithScrollCallback)
    self.onInteractWithScrollCallback = onInteractWithScrollCallback
end

function ZO_MarketAnnouncementMarketProduct_Shared:CallOnInteractWithScrollCallback()
    if self.onInteractWithScrollCallback then
        self.onInteractWithScrollCallback()
    end
end

function ZO_MarketAnnouncementMarketProduct_Shared:UpdateProductStyle()
    ZO_LargeSingleMarketProduct_Base.UpdateProductStyle(self)

    local isFocused = self.isFocused
    if isFocused then
        self.control.descriptionTextControl:SetColor(DESCRIPTION_TEXT_COLORS.SELECTED_TEXT_COLOR:UnpackRGB())
        self.control.typeLabel:SetColor(DESCRIPTION_TEXT_COLORS.SELECTED_TEXT_COLOR:UnpackRGB())
    else
        self.control.descriptionTextControl:SetColor(DESCRIPTION_TEXT_COLORS.UNSELECTED_TEXT_COLOR:UnpackRGB())
        self.control.typeLabel:SetColor(DESCRIPTION_TEXT_COLORS.UNSELECTED_TEXT_COLOR:UnpackRGB())
    end
end

function ZO_MarketAnnouncementMarketProduct_Shared:GetBackground()
    return GetMarketProductAnnouncementBackground(self:GetId())
end

-- Market Announcements only show tiles in an available state, never as purchased or a "fail" condition
function ZO_MarketAnnouncementMarketProduct_Shared:IsPurchaseLocked()
    return false
end

function ZO_MarketAnnouncementMarketProduct_Shared:GetMarketProductDisplayState()
    return MARKET_PRODUCT_DISPLAY_STATE_NOT_PURCHASED
end

function ZO_MarketAnnouncementMarketProduct_Shared:GetMarketProductListingsForHouseTemplate(houseTemplateId, displayGroup)
    return { GetActiveAnnouncementMarketProductListingsForHouseTemplate(houseTemplateId) }
end

-- override of ZO_MarketProductBase:LayoutCostAndText
function ZO_MarketAnnouncementMarketProduct_Shared:LayoutCostAndText()
    self:SetupCalloutsDisplay()

    -- layout the price labels
    self:SetupPricingDisplay()

    self:SetupTextCalloutAnchors()

    self:SetupBundleDisplay()

    self:SetupEsoPlusDealLabelDisplay()

    local FOCUSED = true
    ZO_MarketClasses_Shared_ApplyTextColorToLabelByState(self.control.title, FOCUSED, self.displayState)
end

function ZO_MarketAnnouncementMarketProduct_Shared:SetupTextCalloutAnchors()
    local control = self.control
    control.previousCost:ClearAnchors()
    control.cost:ClearAnchors()
    control.esoPlusCost:ClearAnchors()
    control.descriptionControl:ClearAnchors()

    local hasNormalCost = self:HasCost()
    if hasNormalCost then
        if self:IsOnSale() and not self:IsFree() then
            control.previousCost:SetAnchor(TOPLEFT, control.textCallout, BOTTOMLEFT)
            control.cost:SetAnchor(LEFT, control.previousCost, RIGHT, 10)
            control.descriptionControl:SetAnchor(TOPLEFT, control.previousCost, BOTTOMLEFT)
        elseif control.textCallout:IsControlHidden() then
            local VERTICAL_SPACING = 5
            if control.cost:IsControlHidden() then
                control.descriptionControl:SetAnchor(TOPLEFT, control.title, BOTTOMLEFT, ZO_MARKET_PRODUCT_CALLOUT_X_OFFSET, VERTICAL_SPACING) 
            else
                control.cost:SetAnchor(TOPLEFT, control.title, BOTTOMLEFT, ZO_MARKET_PRODUCT_CALLOUT_X_OFFSET, VERTICAL_SPACING)
                control.descriptionControl:SetAnchor(TOPLEFT, control.cost, BOTTOMLEFT)
            end
        else
            control.cost:SetAnchor(TOPLEFT, control.textCallout, BOTTOMLEFT)
            control.descriptionControl:SetAnchor(TOPLEFT, control.cost, BOTTOMLEFT)
        end
    end

    local hasEsoPlusCost = self:HasEsoPlusCost()
    if hasEsoPlusCost then
        if hasNormalCost then
            control.esoPlusCost:SetAnchor(BOTTOMLEFT, control.cost, BOTTOMRIGHT, 10)
        else
            if control.textCallout:IsControlHidden() then
                control.esoPlusCost:SetAnchor(TOPLEFT, control.title, BOTTOMLEFT, ZO_MARKET_PRODUCT_CALLOUT_X_OFFSET, VERTICAL_SPACING)
            else
                control.esoPlusCost:SetAnchor(TOPLEFT, control.textCallout, BOTTOMLEFT)
            end
            control.descriptionControl:SetAnchor(TOPLEFT, control.esoPlusCost, BOTTOMLEFT)
        end
    end
end

-- override of ZO_MarketProductBase:AnchorEsoPlusDealLabel()
function ZO_MarketAnnouncementMarketProduct_Shared:AnchorEsoPlusDealLabel()
    local control = self.control
    local esoPlusDealLabelControl = control.esoPlusDealLabelControl
    esoPlusDealLabelControl:ClearAnchors()

    -- anchor the left side to the right-most cost label
    -- AnchorEsoPlusDealLabel is only called if HasEsoPlusCost is true
    -- and the esoPlusCost is always the right-most label
    esoPlusDealLabelControl:SetAnchor(BOTTOMLEFT, control.esoPlusCost, BOTTOMRIGHT, 10, 0)
end

function ZO_MarketAnnouncementMarketProduct_Shared:GetDescriptionControl()
    return self.control.descriptionControl
end

function ZO_MarketAnnouncementMarketProduct_Shared:GetDescriptionTextControl()
    return self.control.descriptionTextControl
end

function ZO_MarketAnnouncementMarketProduct_Shared_OnInitialized(control)
    ZO_MarketProductBase_OnInitialized(control)

    control.typeLabel = control:GetNamedChild("Type")
    control.descriptionControl = control:GetNamedChild("ProductDescription")
    local scrollChild = control.descriptionControl:GetNamedChild("ScrollChild")
    control.descriptionTextControl = scrollChild:GetNamedChild("ProductDescriptionText")
end
