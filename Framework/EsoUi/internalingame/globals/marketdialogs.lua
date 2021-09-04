--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local function LogPurchaseClose(dialog)
    if dialog.data then
        if not dialog.data.dontLogClose then
            if dialog.data.logPurchasedMarketId then
                OnMarketEndPurchase(dialog.data.marketProductData:GetId())
            else
                OnMarketEndPurchase()
            end
        end
        dialog.data.dontLogClose = false
        dialog.data.logPurchasedMarketId = false
    end
end

ESO_Dialogs["MARKET_CROWN_STORE_PURCHASE_ERROR_CONTINUE"] = 
{
    finishedCallback = LogPurchaseClose,
    canQueue = true,
    title =
    {
        text = SI_MARKET_PURCHASE_ERROR_TITLE_FORMATTER
    },
    mainText =
    {
        text = SI_MARKET_PURCHASE_ERROR_WITH_CONTINUE_TEXT_FORMATTER
    },
    buttons =
    {
        {
            text = SI_MARKET_PURCHASE_ERROR_CONTINUE,
            callback =  function(dialog)
                            dialog.data.dontLogClose = true
                            -- the MARKET_PURCHASE_CONFIRMATION dialog will be queued to show once this one is hidden
                            ZO_Dialogs_ShowDialog("MARKET_PURCHASE_CONFIRMATION", dialog.data)
                        end,
            keybind = "DIALOG_PRIMARY",
        },
        {
            text = SI_DIALOG_EXIT,
            keybind = "DIALOG_NEGATIVE",
        },
    },
}

ESO_Dialogs["MARKET_CROWN_STORE_PURCHASE_ERROR_PURCHASE_CROWNS"] =
{
    finishedCallback = LogPurchaseClose,
    canQueue = true,
    title =
    {
        text = SI_MARKET_PURCHASE_ERROR_TITLE_FORMATTER
    },
    mainText =
    {
        text = SI_MARKET_PURCHASE_ERROR_TEXT_FORMATTER
    },
    buttons =
    {
        {
            text = function()
                if DoesPlatformStoreUseExternalLinks() then
                    return GetString(SI_MARKET_INSUFFICIENT_FUNDS_CONFIRM_BUTTON_TEXT)
                else
                    return zo_strformat(SI_OPEN_FIRST_PARTY_STORE_KEYBIND, ZO_GetPlatformStoreName())
                end
            end,
            callback = function()
                ZO_ShowBuyCrownsPlatformUI()
            end,
            keybind = "DIALOG_PRIMARY",
        },
        {
            text = SI_DIALOG_EXIT,
            keybind = "DIALOG_NEGATIVE",
        },
    },
}

ESO_Dialogs["MARKET_CROWN_STORE_PURCHASE_ERROR_JOIN_ESO_PLUS"] =
{
    finishedCallback = LogPurchaseClose,
    canQueue = true,
    title =
    {
        text = SI_MARKET_PURCHASE_ERROR_TITLE_FORMATTER
    },
    mainText =
    {
        text = SI_MARKET_PURCHASE_ERROR_TEXT_FORMATTER
    },
    buttons =
    {
        {
            text = SI_MARKET_JOIN_ESO_PLUS_CONFIRM_BUTTON_TEXT,
            callback = function()
                ZO_ShowBuySubscriptionPlatformDialog()
            end,
            keybind = "DIALOG_PRIMARY",
        },
        {
            text = SI_DIALOG_EXIT,
            keybind = "DIALOG_NEGATIVE",
        },
    },
}

ESO_Dialogs["MARKET_CROWN_STORE_PURCHASE_ERROR_GIFTING_NOT_ALLOWED"] =
{
    finishedCallback = LogPurchaseClose,
    canQueue = true,
    title =
    {
        text = SI_MARKET_PURCHASE_ERROR_TITLE_FORMATTER
    },
    mainText =
    {
        text = SI_MARKET_PURCHASE_ERROR_TEXT_FORMATTER
    },
    buttons =
    {
        {
            text = SI_MARKET_GIFTING_LOCKED_HELP_KEYBIND,
            callback = function(dialog)
                ZO_MarketDialogs_Shared_OpenGiftingLockedHelp(dialog)
            end,
            keybind = "DIALOG_PRIMARY",
        },
        {
            text = SI_DIALOG_EXIT,
            keybind = "DIALOG_NEGATIVE",
        },
    },
}

ESO_Dialogs["MARKET_CROWN_STORE_PURCHASE_ERROR_GIFTING_GRACE_PERIOD"] =
{
    finishedCallback = LogPurchaseClose,
    updateFn = function(dialog)
        ZO_MarketDialogs_Shared_UpdateGiftingGracePeriodTimer(dialog)
    end,
    canQueue = true,
    title =
    {
        text = SI_MARKET_PURCHASE_ERROR_TITLE_FORMATTER
    },
    mainText =
    {
        text = SI_MARKET_GIFTING_GRACE_PERIOD_TEXT
    },
    buttons =
    {
        {
            text = SI_MARKET_GIFTING_LOCKED_HELP_KEYBIND,
            callback = function(dialog)
                ZO_MarketDialogs_Shared_OpenGiftingLockedHelp(dialog)
            end,
            keybind = "DIALOG_PRIMARY",
        },
        {
            text = SI_DIALOG_EXIT,
            keybind = "DIALOG_NEGATIVE",
        },
    },
}

ESO_Dialogs["MARKET_CROWN_STORE_PURCHASE_ERROR_ALREADY_HAVE_PRODUCT_IN_GIFT_INVENTORY"] =
{
    finishedCallback = LogPurchaseClose,
    canQueue = true,
    title =
    {
        text = SI_MARKET_PURCHASE_ERROR_TITLE_FORMATTER
    },
    mainText =
    {
        text = SI_MARKET_PURCHASE_ERROR_TEXT_FORMATTER
    },
    buttons =
    {
        {
            text = SI_MARKET_OPEN_GIFT_INVENTORY_KEYBIND_LABEL,
            callback = function(dialog)
                RequestShowGiftInventory()
            end,
            keybind = "DIALOG_PRIMARY",
        },
        {
            text = SI_DIALOG_EXIT,
            keybind = "DIALOG_NEGATIVE",
        },
    },
}

ESO_Dialogs["MARKET_CROWN_STORE_GIFT_PARTIALLY_OWNED_KEYBOARD"] =
{
    canQueue = true,
    title =
    {
        text = SI_MARKET_PURCHASE_ERROR_TITLE_FORMATTER
    },
    mainText =
    {
        text = SI_MARKET_GIFTING_BUNDLE_PARTS_OWNED_TEXT
    },
    buttons =
    {
        {
            text = SI_MARKET_PURCHASE_ERROR_CONTINUE,
            callback = function(dialog)
                RespondToSendPartiallyOwnedGift(true)

                local data = dialog.data
                ZO_Dialogs_ShowDialog("MARKET_PURCHASING", {itemName = data.itemName, marketProductData = data.marketProductData, recipientDisplayName = data.recipientDisplayName })
            end,
            keybind = "DIALOG_PRIMARY",
        },
        {
            text = SI_DIALOG_EXIT,
            callback = function(dialog)
                RespondToSendPartiallyOwnedGift(false)
            end,
            keybind = "DIALOG_NEGATIVE",
        },
    },
}

ESO_Dialogs["RESEND_GIFT_PARTIALLY_OWNED_KEYBOARD"] =
{
    canQueue = true,
    title =
    {
        text = SI_MARKET_PURCHASE_ERROR_TITLE_FORMATTER
    },
    mainText =
    {
        text = SI_MARKET_GIFTING_RESEND_BUNDLE_PARTS_OWNED_TEXT
    },
    buttons =
    {
        {
            text = SI_MARKET_PURCHASE_ERROR_CONTINUE,
            callback = function(dialog)
                RespondToSendPartiallyOwnedGift(true)

                local data = dialog.data
                ZO_Dialogs_ShowDialog("GIFT_SENDING_KEYBOARD", data)
            end,
            keybind = "DIALOG_PRIMARY",
        },
        {
            text = SI_DIALOG_EXIT,
            callback = function(dialog)
                RespondToSendPartiallyOwnedGift(false)
            end,
            keybind = "DIALOG_NEGATIVE",
        },
    },
}


ESO_Dialogs["MARKET_CROWN_STORE_PURCHASE_ERROR_EXIT"] =
{
    finishedCallback = LogPurchaseClose,
    canQueue = true,
    title =
    {
        text = SI_MARKET_PURCHASE_ERROR_TITLE_FORMATTER
    },
    mainText =
    {
        text = SI_MARKET_PURCHASE_ERROR_TEXT_FORMATTER
    },
    buttons =
    {
        {
            text = SI_DIALOG_EXIT,
        },
    },
}

ESO_Dialogs["MARKET_FREE_TRIAL_PURCHASE_CONFIRMATION"] =
{
    finishedCallback = LogPurchaseClose,
    title =
    {
        text = SI_MARKET_PURCHASE_FREE_TRIAL_TITLE
    },
    mainText =
    {
        text =  function(dialog)
                    local endTimeString = dialog.data.marketProductData:GetEndTimeString()
                    local currencyIcon = ZO_Currency_GetPlatformFormattedCurrencyIcon(CURT_CROWNS, 24)
                    return zo_strformat(SI_MARKET_PURCHASE_FREE_TRIAL_TEXT, endTimeString, currencyIcon)
                end,
    },
    canQueue = true,
    buttons =
    {
        {
            text = SI_MARKET_CONFIRM_PURCHASE_KEYBIND_TEXT,
            callback =  function(dialog)
                            dialog.data.logPurchasedMarketId = true
                            local marketProductData = dialog.data.marketProductData

                            -- set this up for the MARKET_PURCHASING dialog
                            local productName = marketProductData:GetColorizedDisplayName()
                            -- the MARKET_PURCHASING dialog will be queued to show once this one is hidden
                            ZO_Dialogs_ShowDialog("MARKET_PURCHASING", {itemName = productName, marketProductData = marketProductData})
                            marketProductData:RequestPurchase()
                        end,
        },

        {
            text = SI_DIALOG_DECLINE,
        },
    }
}

local function MarketPurchaseConfirmationDialogSetupGiftingControls(dialog, data)
    local giftRecipientContainer = dialog:GetNamedChild("GiftRecipient")
    giftRecipientContainer:SetHidden(not data.isGift)

    local noteLabel = dialog:GetNamedChild("NoteHeader")
    local noteControl = dialog:GetNamedChild("Note")
    local noteRandomTextButton = dialog:GetNamedChild("NoteRandomText")
    noteLabel:SetHidden(not data.isGift)
    noteControl:SetHidden(not data.isGift)
    noteRandomTextButton:SetHidden(not data.isGift)

    local itemContainerControl = dialog:GetNamedChild("ItemContainer")
    local itemContainerAnchorToControl = data.isGift and noteRandomTextButton or dialog.radioButtonContainer
    itemContainerControl:ClearAnchors()
    itemContainerControl:SetAnchor(TOPLEFT, itemContainerAnchorToControl, BOTTOMLEFT, 0, 10)
    itemContainerControl:SetAnchor(TOPRIGHT, itemContainerAnchorToControl, BOTTOMRIGHT, 0, 10)

    -- prefill fields if available
    dialog:GetNamedChild("GiftRecipientEditBox"):SetText(data.recipientDisplayName or "")
    dialog:GetNamedChild("NoteEdit"):SetText(data.note or "")
end

local TEXT_CALLOUT_BACKGROUND_ALPHA = 0.9
local function MarketPurchaseConfirmationDialogSetupPricingControls(dialog, data)
    local marketPurchaseData
    if data.marketProductData then
        local marketCurrencyType, cost, costAfterDiscount, discountPercent, esoPlusCost = data.marketProductData:GetMarketProductPricingByPresentation()
        marketPurchaseData =
        {
            marketCurrencyType = marketCurrencyType,
            cost = cost,
            costAfterDiscount = costAfterDiscount,
            discountPercent = discountPercent,
            esoPlusCost = esoPlusCost,
        }
    elseif data.marketPurchaseOptions then
        local currencyType, options = next(data.marketPurchaseOptions)
        marketPurchaseData = options
        marketPurchaseData.marketCurrencyType = currencyType
    end

    local currencyType = GetCurrencyTypeFromMarketCurrencyType(marketPurchaseData.marketCurrencyType)

    local hasCost = marketPurchaseData.cost ~= nil
    local hasEsoPlusCost
    if data.isGift then
        hasEsoPlusCost = false -- gifts aren't eligible for ESO Plus pricing
    else
        hasEsoPlusCost = marketPurchaseData.esoPlusCost ~= nil and IsEligibleForEsoPlusPricing()
    end

    if hasCost then
        local extraOptions = nil
        local currencyFormat
        local costAmountLabel = dialog.costContainer.currencyAmount
        local previousCostLabel = dialog.costContainer.previousCost
        local textCalloutLabel = dialog.costContainer.textCallout

        -- layout the previous cost
        if not hasEsoPlusCost and marketPurchaseData.discountPercent > 0 and marketPurchaseData.costAfterDiscount ~= 0 then
            local formattedAmount = zo_strformat(SI_NUMBER_FORMAT, marketPurchaseData.cost)
            local strikethroughAmountString = zo_strikethroughTextFormat(formattedAmount)
            previousCostLabel:SetText(strikethroughAmountString)
            previousCostLabel:SetHidden(false)

            local discountPercentText = zo_strformat(SI_MARKET_DISCOUNT_PRICE_PERCENT_FORMAT, marketPurchaseData.discountPercent)
            textCalloutLabel:SetText(discountPercentText)
            textCalloutLabel:SetHidden(false)
        else
            previousCostLabel:SetHidden(true)
            textCalloutLabel:SetHidden(true)
        end

        if hasEsoPlusCost then
            extraOptions =
            {
                color = ZO_DEFAULT_TEXT,
                iconInheritColor = true,
            }

            costAmountLabel:SetColor(ZO_DEFAULT_TEXT:UnpackRGB())
            currencyFormat = ZO_CURRENCY_FORMAT_STRIKETHROUGH_AMOUNT_ICON
        else
            costAmountLabel:SetColor(ZO_HIGHLIGHT_TEXT:UnpackRGB())
            currencyFormat = ZO_CURRENCY_FORMAT_AMOUNT_ICON
        end
        local currencyString = ZO_Currency_FormatKeyboard(currencyType, marketPurchaseData.costAfterDiscount, currencyFormat, extraOptions)
        costAmountLabel:SetText(currencyString)

        local labelString
        if hasEsoPlusCost then
            labelString = SI_MARKET_CONFIRM_PURCHASE_NORMAL_COST_LABEL
        else
            labelString = SI_MARKET_CONFIRM_PURCHASE_COST_LABEL
        end
        local costLabel = dialog.costContainer.currencyLabel
        costLabel:SetText(GetString(labelString))
    end
    dialog.costContainer:SetHidden(not hasCost)

    if hasEsoPlusCost then
        local extraOptions =
        {
            color = ZO_MARKET_PRODUCT_ESO_PLUS_COLOR,
            iconInheritColor = marketCurrencyType ~= MKCT_CROWN_GEMS,
        }
        local currencyString = ZO_Currency_FormatKeyboard(currencyType, marketPurchaseData.esoPlusCost, ZO_CURRENCY_FORMAT_AMOUNT_ICON, extraOptions)

        local costAmountLabel = dialog.esoPlusCostContainer.currencyAmount
        costAmountLabel:SetText(currencyString)

        dialog.esoPlusCostContainer:ClearAnchors()
        local controlToAnchorCostContainerTo = hasCost and dialog.costContainer or dialog.balanceContainer
        dialog.esoPlusCostContainer:SetAnchor(TOPLEFT, controlToAnchorCostContainerTo, BOTTOMLEFT, 0, 30)
        dialog.esoPlusCostContainer:SetAnchor(TOPRIGHT, controlToAnchorCostContainerTo, BOTTOMRIGHT, 0, 30)
    end
    dialog.esoPlusCostContainer:SetHidden(not hasEsoPlusCost)

    local currencyString = ZO_Currency_FormatKeyboard(currencyType, GetPlayerMarketCurrency(marketPurchaseData.marketCurrencyType), ZO_CURRENCY_FORMAT_AMOUNT_ICON)
    local currentBalanceAmountLabel = dialog.balanceContainer.currencyAmount
    currentBalanceAmountLabel:SetText(currencyString)
end

local function MarketPurchaseSelectTemplateDialogSetupHouseInfoControls(dialog, data)
    local index, templateData = next(data.marketPurchaseOptions)
    if templateData then
        local houseZoneId = GetHouseFoundInZoneId(templateData.houseId)
        local houseZoneName = GetZoneNameById(houseZoneId)
        local houseCategory = GetHouseCategoryType(templateData.houseId)
        local houseCategoryName = GetString("SI_HOUSECATEGORYTYPE", houseCategory)

        local hasEsoPlusCost
        if data.isGift then
            hasEsoPlusCost = false -- gifts aren't eligible for ESO Plus pricing
        else
            hasEsoPlusCost = templateData.esoPlusCost ~= nil and IsEligibleForEsoPlusPricing()
        end

        dialog.locationContainer:ClearAnchors()
        local controlToAnchorCostContainerTo
        if hasEsoPlusCost then
            controlToAnchorCostContainerTo = dialog.esoPlusCostContainer
        else
            controlToAnchorCostContainerTo = templateData.cost ~= nil and dialog.costContainer or dialog.balanceContainer
        end

        dialog.locationContainer:SetAnchor(TOPLEFT, controlToAnchorCostContainerTo, BOTTOMLEFT, 0, 50)
        dialog.locationContainer:SetAnchor(TOPRIGHT, controlToAnchorCostContainerTo, BOTTOMRIGHT, 0, 50)

        local locationValueLabel = dialog.locationContainer.valueControl
        locationValueLabel:SetText(zo_strformat(SI_ZONE_NAME, houseZoneName))

        local houseTypeValueLabel = dialog.houseTypeContainer.valueControl
        houseTypeValueLabel:SetText(zo_strformat(SI_HOUSE_TYPE_FORMATTER, houseCategoryName))

        for furnishingLimitType = HOUSING_FURNISHING_LIMIT_TYPE_ITERATION_BEGIN, HOUSING_FURNISHING_LIMIT_TYPE_ITERATION_END do
            local initialFurnishingCount, furnishingLimit = GetHouseTemplateBaseFurnishingCountInfo(templateData.houseTemplateId, furnishingLimitType)
            dialog:GetNamedChild("HouseInfo" .. furnishingLimitType).labelControl:SetText(zo_strformat(SI_MARKET_SELECT_HOUSE_TEMPLATE_INFO_FORMATTER, GetString("SI_HOUSINGFURNISHINGLIMITTYPE", furnishingLimitType)))
            dialog:GetNamedChild("HouseInfo" .. furnishingLimitType).valueControl:SetText(zo_strformat(SI_HOUSE_INFORMATION_COUNT_FORMAT, initialFurnishingCount, furnishingLimit))
        end
    end
end

local function UpdateConfirmRestrictions(dialogControl)
    local nameEditControl = dialogControl:GetNamedChild("GiftRecipientEditBox")
    local confirmButton = dialogControl:GetNamedChild("Confirm")
    local confirmButtonState, confirmButtonStateLocked = BSTATE_NORMAL, false

    local data = dialogControl.data
    if data.isGift then
        local recipientDisplayName = nameEditControl:GetText()
        local result = IsGiftRecipientNameValid(recipientDisplayName)
        local errorText
        if result ~= GIFT_ACTION_RESULT_SUCCESS then
            confirmButtonState, confirmButtonStateLocked = BSTATE_DISABLED, true
            if result ~= GIFT_ACTION_RESULT_RECIPIENT_EMPTY then
                errorText = zo_strformat(GetString("SI_GIFTBOXACTIONRESULT", result), recipientDisplayName)
            end
        end
        if errorText then
            InitializeTooltip(InformationTooltip, nameEditControl, RIGHT, -35, 0)
            SetTooltipText(InformationTooltip, errorText, ZO_ERROR_COLOR:UnpackRGB())
        else
            ClearTooltip(InformationTooltip)
        end
    else
        ClearTooltipImmediately(InformationTooltip)
    end

    confirmButton:SetState(confirmButtonState, confirmButtonStateLocked)
end

local ENABLE_BUTTON = true
local DISABLE_BUTTON = false

local function SetupRadioButton(radioButtonGroup, radioButton, isButtonEnabled, onMouseEnter, onMouseExit, onUpdate)
    radioButtonGroup:SetButtonIsValidOption(radioButton, isButtonEnabled)
    radioButton.label:SetHandler("OnMouseEnter", onMouseEnter)
    radioButton.label:SetHandler("OnUpdate", onUpdate)
    radioButton.label:SetHandler("OnMouseExit", onMouseExit)
end

local function SetupRadioButtonWithBasicTextTooltip(radioButtonGroup, radioButton, isButtonEnabled, anchorToControl, anchorDirection, tooltipText)
    local function OnMouseEnter()
        ZO_Tooltips_ShowTextTooltip(anchorToControl, anchorDirection, tooltipText)
    end

    local function OnMouseExit()
        ZO_Tooltips_HideTextTooltip()
    end

    SetupRadioButton(radioButtonGroup, radioButton, isButtonEnabled, OnMouseEnter, OnMouseExit)
end

local function MarketPurchaseConfirmationDialogSetup(dialog, data)
    local marketProductData = data.marketProductData

    local selectedRadioButton, otherRadioButtonResult, otherRadioButton, anchorToControl, anchorDirection
    local selectedRadioButtonWarningStrings = {}
    local otherRadioButtonWarningStrings = {}
    if data.isGift then
        selectedRadioButton = dialog.asGiftRadioButton
        otherRadioButton = dialog.forMeRadioButton
        otherRadioButtonResult = marketProductData:CouldPurchase()
        ZO_MARKET_MANAGER:AddMarketProductPurchaseWarningStringsToTable(marketProductData, otherRadioButtonWarningStrings)
        -- draw tooltip to the left of the buttons
        anchorToControl = otherRadioButton
        anchorDirection = LEFT
    else
        selectedRadioButton = dialog.forMeRadioButton
        otherRadioButton = dialog.asGiftRadioButton
        otherRadioButtonResult = marketProductData:CouldGift()
        ZO_MARKET_MANAGER:AddMarketProductPurchaseWarningStringsToTable(marketProductData, selectedRadioButtonWarningStrings)
        -- draw tooltip to the right of the buttons
        anchorToControl = otherRadioButton.label
        anchorDirection = RIGHT
    end

    if #selectedRadioButtonWarningStrings == 0 then
        SetupRadioButton(dialog.radioButtonGroup, selectedRadioButton, ENABLE_BUTTON)
    else
        local tooltipText = table.concat(selectedRadioButtonWarningStrings, "\n\n")
        SetupRadioButtonWithBasicTextTooltip(dialog.radioButtonGroup, selectedRadioButton, ENABLE_BUTTON, anchorToControl, anchorDirection, tooltipText)
    end

    dialog.radioButtonGroup:SetClickedButton(selectedRadioButton)

    if otherRadioButtonResult == MARKET_PURCHASE_RESULT_SUCCESS then
        if #otherRadioButtonWarningStrings == 0 then
            SetupRadioButton(dialog.radioButtonGroup, otherRadioButton, ENABLE_BUTTON)
        else
            local tooltipText = table.concat(otherRadioButtonWarningStrings, "\n\n")
            SetupRadioButtonWithBasicTextTooltip(dialog.radioButtonGroup, otherRadioButton, ENABLE_BUTTON, anchorToControl, anchorDirection, tooltipText)
        end
    elseif otherRadioButtonResult == MARKET_PURCHASE_RESULT_GIFTING_GRACE_PERIOD_ACTIVE then
        local lastTimeLeftS = nil
        local isTooltipShowing = false
        local FORCE_UPDATE = true
        local function updateTooltipText(forceUpdate)
            local timeLeftS = GetGiftingGracePeriodTime()
            if forceUpdate or timeLeftS ~= lastTimeLeftS then
                lastTimeLeftS = timeLeftS
                InformationTooltip:ClearLines()
                local timeLeftString = ZO_FormatTime(lastTimeLeftS, TIME_FORMAT_STYLE_SHOW_LARGEST_TWO_UNITS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
                SetTooltipText(InformationTooltip, zo_strformat(SI_MARKET_GIFTING_GRACE_PERIOD_TOOLTIP, timeLeftString))
            end
        end

        local function OnMouseEnter()
            ZO_Tooltips_ShowTextTooltip(anchorToControl, anchorDirection)
            updateTooltipText(FORCE_UPDATE)
            isTooltipShowing = true
        end

        local function OnUpdate()
            if isTooltipShowing then
                updateTooltipText()
            end
        end

        local function OnMouseExit()
            ClearTooltip(InformationTooltip)
            isTooltipShowing = false
        end

        SetupRadioButton(dialog.radioButtonGroup, otherRadioButton, DISABLE_BUTTON, OnMouseEnter, OnMouseExit, OnUpdate)
    else -- generic error
        local tooltipText = GetString("SI_MARKETPURCHASABLERESULT", otherRadioButtonResult)
        SetupRadioButtonWithBasicTextTooltip(dialog.radioButtonGroup, otherRadioButton, DISABLE_BUTTON, anchorToControl, anchorDirection, tooltipText)
    end

    MarketPurchaseConfirmationDialogSetupGiftingControls(dialog, data)

    -- set this up for the MARKET_PURCHASING dialog
    data.itemName = marketProductData:GetColorizedDisplayName()

    local itemContainerControl = dialog:GetNamedChild("ItemContainer")
    local itemContainerTextContainer = itemContainerControl:GetNamedChild("ItemText")

    local houseId = GetMarketProductHouseId(data.marketProductData.marketProductId)
    if houseId > 0 then
        local houseCollectibleId = GetCollectibleIdForHouse(houseId)
        local houseDisplayName = GetCollectibleName(houseCollectibleId)
        itemContainerTextContainer:GetNamedChild("ItemName"):SetText(zo_strformat(SI_MARKET_PRODUCT_NAME_FORMATTER, houseDisplayName))
        itemContainerTextContainer:GetNamedChild("ItemDetail"):SetText(zo_strformat(SI_MARKET_PRODUCT_NAME_FORMATTER, data.itemName))
    else
        itemContainerTextContainer:GetNamedChild("ItemName"):SetText(zo_strformat(SI_MARKET_PRODUCT_NAME_FORMATTER, data.itemName))
        itemContainerTextContainer:GetNamedChild("ItemDetail"):SetText("")
    end

    local iconTextureControl = itemContainerControl:GetNamedChild("Icon")
    local icon = marketProductData:GetIcon()
    iconTextureControl:SetTexture(icon)

    local stackSize = marketProductData:GetStackCount()

    local stackCountControl = iconTextureControl:GetNamedChild("StackCount")
    stackCountControl:SetText(stackSize)
    stackCountControl:SetHidden(stackSize < 2)

    MarketPurchaseConfirmationDialogSetupPricingControls(dialog, data)

    UpdateConfirmRestrictions(dialog)
end

function ZO_MarketPurchaseConfirmationDialog_OnInitialized(control)
    -- Radio buttons
    local radioButtonContainer = control:GetNamedChild("RadioButtons")
    local forMeRadioButton = radioButtonContainer:GetNamedChild("ForMe")
    forMeRadioButton.label = forMeRadioButton:GetNamedChild("Label")
    local asGiftRadioButton = radioButtonContainer:GetNamedChild("AsGift")
    asGiftRadioButton.label = asGiftRadioButton:GetNamedChild("Label")
    local radioButtonGroup = ZO_RadioButtonGroup:New()
    radioButtonGroup:Add(forMeRadioButton)
    radioButtonGroup:Add(asGiftRadioButton)
    radioButtonGroup:SetClickedButton(control.forMeRadioButton)

    control.radioButtonContainer = radioButtonContainer
    control.radioButtonGroup = radioButtonGroup
    control.forMeRadioButton = forMeRadioButton
    control.asGiftRadioButton = asGiftRadioButton

    control.balanceContainer = control:GetNamedChild("BalanceContainer")
    control.costContainer = control:GetNamedChild("CostContainer")
    control.costContainer.previousCost = control.costContainer:GetNamedChild("PreviousCost")
    control.costContainer.textCallout = control.costContainer:GetNamedChild("TextCallout")
    control.esoPlusCostContainer = control:GetNamedChild("EsoPlusCostContainer")

    local function OnRadioButtonSelectionChanged(buttonGroup, selectedButton, previousButton)
        local data = control.data
        if selectedButton == forMeRadioButton then
            data.isGift = false
        else
            data.isGift = true
        end

        UpdateConfirmRestrictions(control)
        MarketPurchaseConfirmationDialogSetupGiftingControls(control, data)
        MarketPurchaseConfirmationDialogSetupPricingControls(control, data)
    end

    radioButtonGroup:SetSelectionChangedCallback(OnRadioButtonSelectionChanged)
    
    -- Name edit
    local nameEdit = control:GetNamedChild("GiftRecipientEditBox")
    ZO_PreHookHandler(nameEdit, "OnTextChanged", function(editControl)
        UpdateConfirmRestrictions(control)
    end)

    ZO_AutoComplete:New(nameEdit, { AUTO_COMPLETE_FLAG_FRIEND, AUTO_COMPLETE_FLAG_GUILD }, nil, AUTO_COMPLETION_ONLINE_OR_OFFLINE, 5, AUTO_COMPLETION_AUTOMATIC_MODE)

    -- Note edit
    local noteEdit = control:GetNamedChild("NoteEdit")
    local randomNoteButton = control:GetNamedChild("NoteRandomText"):GetNamedChild("Button")
    randomNoteButton:SetText(zo_iconFormat("EsoUI/Art/Market/Keyboard/giftMessageIcon_up.dds", "100%", "100%"))
    randomNoteButton:SetHandler("OnClicked", function()
        noteEdit:SetText(GetRandomGiftSendNoteText())
    end)

    ZO_Dialogs_RegisterCustomDialog(
        "MARKET_PURCHASE_CONFIRMATION",
        {
            customControl = control,
            setup = MarketPurchaseConfirmationDialogSetup,
            title =
            {
                text = SI_MARKET_CONFIRM_PURCHASE_TITLE,
            },
            canQueue = true,
            buttons =
            {
                {
                    control = control:GetNamedChild("Confirm"),
                    text = SI_MARKET_CONFIRM_PURCHASE_KEYBIND_TEXT,
                    callback =  function(dialog)
                                    local data = dialog.data
                                    data.logPurchasedMarketId = true
                                    local marketProductData = data.marketProductData
                                    local recipientDisplayName
                                    local note
                                    if data.isGift then
                                        recipientDisplayName = dialog:GetNamedChild("GiftRecipientEditBox"):GetText()
                                        note = dialog:GetNamedChild("NoteEdit"):GetText()
                                    end
                                    -- the MARKET_PURCHASING dialog will be queued to show once this one is hidden
                                    ZO_Dialogs_ShowDialog("MARKET_PURCHASING", {itemName = data.itemName, marketProductData = marketProductData, recipientDisplayName = recipientDisplayName, note = note})

                                    if data.isGift then
                                        marketProductData:RequestPurchaseAsGift(note, recipientDisplayName)
                                    else
                                        marketProductData:RequestPurchase()
                                    end
                                end,
                },

                {
                    control = control:GetNamedChild("Cancel"),
                    text = SI_DIALOG_DECLINE,
                    callback = LogPurchaseClose,
                },
            },
            noChoiceCallback = LogPurchaseClose,
            finishedCallback = function(dialog)
                ClearTooltipImmediately(InformationTooltip)
            end,
        }
    )
end

local function MarketPurchaseHouseTemplateSelectDialogSetup(dialog, data)
    local marketProductData = data.marketProductData
    local marketProductId = marketProductData:GetId()
    local isHouseMarketProduct, houseTemplateDataList, defaultHouseTemplateIndex = ZO_MarketProduct_GetMarketProductHouseTemplateDataList(marketProductId, function(...) return { GetActiveMarketProductListingsForHouseTemplate(...) } end)

    -- Setup House Collectible Name
    local itemContainerControl = dialog:GetNamedChild("ItemContainer")
    local itemContainerTextContainer = itemContainerControl:GetNamedChild("ItemText")
    local itemNameLabel = itemContainerTextContainer:GetNamedChild("ItemName")

    if isHouseMarketProduct then
        local houseId = GetMarketProductHouseId(marketProductId)
        local houseCollectibleId = GetCollectibleIdForHouse(houseId)
        local houseDisplayName = GetCollectibleName(houseCollectibleId)
        itemNameLabel:SetText(zo_strformat(SI_MARKET_PRODUCT_NAME_FORMATTER, houseDisplayName))
    else
        internalassert(false, "Market Product is not a house")
    end

    -- Setup House Collectible Icon
    local iconTextureControl = itemContainerControl:GetNamedChild("Icon")
    local icon = marketProductData:GetIcon()
    iconTextureControl:SetTexture(icon)

    -- Populate House Template Dropdown
    local function OnTemplateChanged(comboBox, entryText, entry)
        local currencyType
        local marketCurrencyType
        if entry and entry.data then
            local key, value = next(entry.data.marketPurchaseOptions)
            currencyType = GetCurrencyTypeFromMarketCurrencyType(key)
            marketCurrencyType = key

            local currencyString = ZO_Currency_FormatKeyboard(currencyType, GetPlayerMarketCurrency(marketCurrencyType), ZO_CURRENCY_FORMAT_AMOUNT_ICON)
            local currentBalanceAmountLabel = dialog.balanceContainer.currencyAmount
            currentBalanceAmountLabel:SetText(currencyString)

            MarketPurchaseConfirmationDialogSetupPricingControls(dialog, comboBox:GetSelectedItemData().data)
            MarketPurchaseSelectTemplateDialogSetupHouseInfoControls(dialog, comboBox:GetSelectedItemData().data)
        end
    end

    local comboBox = dialog.comboBox

    comboBox:ClearItems()

    local defaultTemplateListIndex
    for index, houseTemplateData in pairs(houseTemplateDataList) do
        local currencyType, marketData = next(houseTemplateData.marketPurchaseOptions)
        if houseTemplateData.name and marketData and ((data.isGift and marketData.isGiftable) or (not data.isGift and not marketData.isHouseOwned)) then
            local formattedName = zo_strformat(SI_MARKET_PRODUCT_HOUSE_TEMPLATE_NAME_FORMAT, houseTemplateData.name)
            local entry = comboBox:CreateItemEntry(formattedName, OnTemplateChanged)
            entry.data = houseTemplateData
            comboBox:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)

            if index == defaultHouseTemplateIndex then
                defaultTemplateListIndex = comboBox:GetNumItems()
            end
        end
    end

    if comboBox:GetNumItems() > 0 then
        if defaultTemplateListIndex then
            comboBox:SelectItemByIndex(defaultTemplateListIndex)
        else
            comboBox:SelectFirstItem()
        end

        MarketPurchaseConfirmationDialogSetupPricingControls(dialog, comboBox:GetSelectedItemData().data)
        MarketPurchaseSelectTemplateDialogSetupHouseInfoControls(dialog, comboBox:GetSelectedItemData().data)
    end
end

function ZO_MarketPurchaseHouseTemplateSelectDialog_OnInitialized(control)
    control.templateComboBoxControl = control:GetNamedChild("ComboBox")
    control.comboBox = ZO_ComboBox:New(control.templateComboBoxControl)

    control.balanceContainer = control:GetNamedChild("BalanceContainer")
    control.costContainer = control:GetNamedChild("CostContainer")
    control.costContainer.previousCost = control.costContainer:GetNamedChild("PreviousCost")
    control.costContainer.textCallout = control.costContainer:GetNamedChild("TextCallout")
    control.esoPlusCostContainer = control:GetNamedChild("EsoPlusCostContainer")

    control.locationContainer = control:GetNamedChild("LocationContainer")
    control.houseTypeContainer = control:GetNamedChild("HouseTypeContainer")

    local locationLabel = control.locationContainer:GetNamedChild("Label")
    locationLabel:SetText(zo_strformat(SI_MARKET_SELECT_HOUSE_TEMPLATE_INFO_FORMATTER, GetString(SI_MARKET_PRODUCT_HOUSING_LOCATION_LABEL)))

    local houseTypeLabel = control.houseTypeContainer:GetNamedChild("Label")
    houseTypeLabel:SetText(zo_strformat(SI_MARKET_SELECT_HOUSE_TEMPLATE_INFO_FORMATTER, GetString(SI_MARKET_PRODUCT_HOUSING_HOUSE_TYPE_LABEL)))

    local anchorControl = control.houseTypeContainer
    local offsetY = 50
    for furnishingLimitType = HOUSING_FURNISHING_LIMIT_TYPE_ITERATION_BEGIN, HOUSING_FURNISHING_LIMIT_TYPE_ITERATION_END do
        local infoControl = CreateControlFromVirtual("$(parent)HouseInfo", control, "ZO_DialogLabelValueContainer_Keyboard", furnishingLimitType)

        infoControl:ClearAnchors()
        infoControl:SetAnchor(TOPLEFT, anchorControl, BOTTOMLEFT, 0, offsetY)
        infoControl:SetAnchor(TOPRIGHT, anchorControl, BOTTOMRIGHT, 0, offsetY)

        anchorControl = infoControl
        offsetY = 30
    end

    local esoPlusNoteLabel = control:GetNamedChild("EsoPlusNote")
    esoPlusNoteLabel:ClearAnchors()
    esoPlusNoteLabel:SetAnchor(TOP, anchorControl, BOTTOM, 0, offsetY)

    ZO_Dialogs_RegisterCustomDialog(
        "MARKET_PURCHASE_HOUSE_TEMPLATE_SELECTION",
        {
            customControl = control,
            setup = MarketPurchaseHouseTemplateSelectDialogSetup,
            title =
            {
                text = SI_MARKET_SELECT_HOUSE_TEMPLATE_TITLE,
            },
            canQueue = true,
            buttons =
            {
                {
                    control = control:GetNamedChild("Confirm"),
                    text = SI_MARKET_SELECT_HOUSE_TEMPLATE_REVIEW_PURCHASE,
                    callback =  function(dialog, data)
                        local selectedData = dialog.comboBox:GetSelectedItemData().data
                        local currencyType, marketData = next(selectedData.marketPurchaseOptions)
                        if marketData then
                            local marketProductData = ZO_MarketProductData:New(marketData.marketProductId)
                            if dialog.data.isGift then
                                ZO_Market_Keyboard:GiftMarketProduct(marketProductData)
                            else
                                ZO_Market_Keyboard:PurchaseMarketProduct(marketProductData)
                            end
                        end
                    end,
                },
                {
                    control = control:GetNamedChild("Cancel"),
                    text = SI_DIALOG_EXIT,
                },
            },
            finishedCallback = function(dialog)
                ClearTooltipImmediately(InformationTooltip)
            end,
        }
    )
end

local function OnMarketPurchaseResult(data, result, tutorialTrigger, wasGift)
    EVENT_MANAGER:UnregisterForEvent("MARKET_PURCHASING", EVENT_MARKET_PURCHASE_RESULT)
    data.result = result
    data.wasGift = wasGift

    if result == MARKET_PURCHASE_RESULT_GIFT_COLLECTIBLE_PARTIALLY_OWNED then
        local displayName = data.marketProductData:GetDisplayName()
        local dialogParams =
        {
            titleParams = { displayName },
        }
        ZO_Dialogs_ReleaseAllDialogsOfName("MARKET_PURCHASING")
        ZO_Dialogs_ShowDialog("MARKET_CROWN_STORE_GIFT_PARTIALLY_OWNED_KEYBOARD", data, dialogParams)
    end

    if not wasGift then
        if tutorialTrigger ~= TUTORIAL_TRIGGER_NONE then
            data.tutorialTrigger = tutorialTrigger
        end
    end
end

local LOADING_DELAY_MS = 500
local SHOW_LOADING_ICON = true
local HIDE_LOADING_ICON = false

local MARKET_PURCHASING_STATE_DELAY = 1
local MARKET_PURCHASING_STATE_WAITING = 2
local MARKET_PURCHASING_STATE_RESULT = 3

local function OnMarketPurchasingUpdate(dialog, currentTimeInSeconds)
    local timeInMilliseconds = currentTimeInSeconds * 1000
    local data = dialog.data
    local result = data.result

    if data.loadingDelayTimeMS == nil then
        data.loadingDelayTimeMS = timeInMilliseconds + LOADING_DELAY_MS
    end

    if result ~= nil and data.currentState ~= MARKET_PURCHASING_STATE_RESULT then
        data.currentState = MARKET_PURCHASING_STATE_RESULT

        local titleText
        local mainText
        if result == MARKET_PURCHASE_RESULT_SUCCESS then
            titleText = GetString(SI_TRANSACTION_COMPLETE_TITLE)

            local marketProductData = data.marketProductData
            local marketProductId = marketProductData:GetId()
            local stackCount = marketProductData:GetStackCount()
            local itemName = data.itemName
            local color = GetItemQualityColor(GetMarketProductDisplayQuality(marketProductId))
            local houseId = GetMarketProductHouseId(marketProductId)
            if houseId > 0 then
                local houseCollectibleId = GetCollectibleIdForHouse(houseId)
                local houseDisplayName = GetCollectibleName(houseCollectibleId)
                itemName = zo_strformat(SI_MARKET_PRODUCT_HOUSE_NAME_GRAMMARLESS_FORMATTER, houseDisplayName, data.itemName)
            end

            if data.wasGift then
                if stackCount > 1 then
                    mainText = zo_strformat(SI_MARKET_GIFTING_SUCCESS_TEXT_WITH_QUANTITY, color:Colorize(itemName), stackCount, ZO_SELECTED_TEXT:Colorize(data.recipientDisplayName))
                else
                    mainText = zo_strformat(SI_MARKET_GIFTING_SUCCESS_TEXT, color:Colorize(itemName), ZO_SELECTED_TEXT:Colorize(data.recipientDisplayName))
                end
            else
                local useProductInfo = ZO_Market_Shared.GetUseProductInfo(marketProductData)
                if useProductInfo then
                    if useProductInfo.transactionCompleteTitleText then
                        titleText = useProductInfo.transactionCompleteTitleText
                    end
                    mainText = zo_strformat(useProductInfo.transactionCompleteText, color:Colorize(itemName), stackCount)

                    local useProductControl = dialog:GetNamedChild("UseProduct")
                    useProductControl:SetHidden(useProductInfo.visible and not useProductInfo.visible())
                    useProductControl:SetEnabled(not useProductInfo.enabled or useProductInfo.enabled())
                    useProductControl:SetText(useProductInfo.buttonText)
                else
                    if stackCount > 1 then
                        mainText = zo_strformat(SI_MARKET_PURCHASE_SUCCESS_TEXT_WITH_QUANTITY, color:Colorize(itemName), stackCount)
                    elseif marketProductData:GetNumAttachedCollectibles() > 0 then
                        mainText = zo_strformat(SI_MARKET_PURCHASE_SUCCESS_TEXT_WITH_COLLECTIBLE, color:Colorize(itemName))
                    else
                        mainText = zo_strformat(SI_MARKET_PURCHASE_SUCCESS_TEXT, color:Colorize(itemName))
                    end
                end

                -- append ESO Plus savings, if any
                local esoPlusSavingsString = ZO_MarketDialogs_Shared_GetEsoPlusSavingsString(data.marketProductData)
                if esoPlusSavingsString then
                    mainText = string.format("%s\n\n%s", mainText, esoPlusSavingsString)
                end
            end
        else
            titleText = GetString(SI_TRANSACTION_FAILED_TITLE)
            mainText = GetString("SI_MARKETPURCHASABLERESULT", result)
        end

        local confirmText
        if ZO_MarketDialogs_Shared_ShouldRestartGiftFlow(data.result) then
            confirmText = GetString(SI_MARKET_CONFIRM_PURCHASE_RESTART_KEYBIND_LABEL)
        else
            confirmText = GetString(SI_MARKET_CONFIRM_PURCHASE_BACK_KEYBIND_LABEL)
        end

        ZO_Dialogs_UpdateDialogTitleText(dialog, { text = titleText })
        ZO_Dialogs_UpdateDialogMainText(dialog, { text = mainText, align = TEXT_ALIGN_CENTER })

        local confirmButtonControl = dialog:GetNamedChild("Confirm")
        confirmButtonControl:SetText(confirmText)
        confirmButtonControl:SetHidden(false)

        ZO_Dialogs_SetDialogLoadingIcon(dialog:GetNamedChild("Loading"), dialog:GetNamedChild("Text"), HIDE_LOADING_ICON)
    elseif data.currentState == MARKET_PURCHASING_STATE_DELAY and timeInMilliseconds > data.loadingDelayTimeMS then
        data.currentState = MARKET_PURCHASING_STATE_WAITING

        ZO_Dialogs_UpdateDialogMainText(dialog, { text = zo_strformat(SI_MARKET_PURCHASING_TEXT, data.itemName), TEXT_ALIGN_CENTER })
        ZO_Dialogs_SetDialogLoadingIcon(dialog:GetNamedChild("Loading"), dialog:GetNamedChild("Text"), SHOW_LOADING_ICON)
    end
end

local function MarketPurchasingDialogSetup(dialog, data)
    data.result = nil
    data.loadingDelayTimeMS = nil
    data.currentState = MARKET_PURCHASING_STATE_DELAY
    EVENT_MANAGER:RegisterForEvent("MARKET_PURCHASING", EVENT_MARKET_PURCHASE_RESULT, function(eventId, ...) OnMarketPurchaseResult(data, ...) end)

    dialog:GetNamedChild("Confirm"):SetHidden(true)
    dialog:GetNamedChild("UseProduct"):SetHidden(true)
    dialog:GetNamedChild("UseProduct"):SetEnabled(false)
end

function ZO_MarketPurchasingDialog_OnInitialized(self)
    ZO_Dialogs_RegisterCustomDialog(
        "MARKET_PURCHASING",
        {
            customControl = self,
            setup = MarketPurchasingDialogSetup,
            updateFn = OnMarketPurchasingUpdate,
            title =
            {
                text = SI_MARKET_PURCHASING_TITLE,
            },
            mainText =
            {
                text = "",
                align = TEXT_ALIGN_CENTER,
            },
            canQueue = true,
            mustChoose = true,
            buttons =
            {
                -- Use Product
                {
                    control = self:GetNamedChild("UseProduct"),
                    keybind = "DIALOG_RESET",
                    callback = function(dialog)
                        ZO_Market_Shared.GoToUseProductLocation(dialog.data.marketProductData)
                    end,
                },
                {
                    control = self:GetNamedChild("Confirm"),
                    text = SI_MARKET_CONFIRM_PURCHASE_BACK_KEYBIND_LABEL,
                    keybind = "DIALOG_PRIMARY",
                    callback = function(dialog)
                        local data = dialog.data
                        if ZO_MarketDialogs_Shared_ShouldRestartGiftFlow(data.result) then
                            local restartData =
                            {
                                isGift = true,
                                marketProductData = data.marketProductData,
                                recipientDisplayName = data.recipientDisplayName,
                                note = data.note,
                            }
                            ZO_Dialogs_ShowDialog("MARKET_PURCHASE_CONFIRMATION", restartData)
                            return
                        end
                        LogPurchaseClose(dialog)
                        if data.wasGift == false then
                            local activeMarket = ZO_MARKET_MANAGER:GetActiveMarket()

                            -- Show tutorials from a purchased item first before showing the consumable tutorial
                            if data.tutorialTrigger then
                                activeMarket:ShowTutorial(data.tutorialTrigger)
                            end

                            if data.result == MARKET_PURCHASE_RESULT_SUCCESS and data.marketProductData:ContainsConsumables() then
                                activeMarket:ShowTutorial(TUTORIAL_TRIGGER_CROWN_CONSUMABLE_PURCHASED)
                            end
                        end
                    end,
                },
            },
        }
    )
end