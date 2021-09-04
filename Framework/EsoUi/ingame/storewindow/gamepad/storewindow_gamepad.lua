--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

GAMEPAD_STORE_SCENE_NAME = "gamepad_store"

ZO_GamepadStoreManager = ZO_Object.MultiSubclass(ZO_SharedStoreManager, ZO_Gamepad_ParametricList_BagsSearch_Screen)

function ZO_GamepadStoreManager:New(...)
    return ZO_SharedStoreManager.New(self, ...)
end

function ZO_GamepadStoreManager:Initialize(control)
    ZO_SharedStoreManager.Initialize(self, control)

    self.sceneName = GAMEPAD_STORE_SCENE_NAME

    GAMEPAD_VENDOR_SCENE = ZO_InteractScene:New(self.sceneName, SCENE_MANAGER, STORE_INTERACTION)

    local DONT_ACTIVATE_LIST_ON_SHOW = false
    ZO_Gamepad_ParametricList_BagsSearch_Screen.Initialize(self, control, ZO_GAMEPAD_HEADER_TABBAR_CREATE, DONT_ACTIVATE_LIST_ON_SHOW, GAMEPAD_VENDOR_SCENE)

    self.spinner = control:GetNamedChild("SpinnerContainer")
    self.spinner:InitializeSpinner()

    local function OnOpenStore()
        if IsInGamepadPreferredMode() then
            local componentTable = {}

            if not IsStoreEmpty() then
                table.insert(componentTable, ZO_MODE_STORE_BUY)
            end

            table.insert(componentTable, ZO_MODE_STORE_SELL)
            table.insert(componentTable, ZO_MODE_STORE_BUY_BACK)

            if CanStoreRepair() then
                table.insert(componentTable, ZO_MODE_STORE_REPAIR)
            end

            STORE_WINDOW_GAMEPAD:SetActiveComponents(componentTable, "storeTextSearch")
            SCENE_MANAGER:Show(GAMEPAD_STORE_SCENE_NAME)
        end
    end

    local function OnCloseStore()
        if IsInGamepadPreferredMode() then
            -- Ensure that all dialogs related to the store close on interaction end
            ZO_Dialogs_ReleaseDialog("REPAIR_ALL")

            self:DeactivateTextSearch()

            SCENE_MANAGER:Hide(GAMEPAD_STORE_SCENE_NAME)
        end
    end

    self.control:RegisterForEvent(EVENT_OPEN_STORE, OnOpenStore)
    self.control:RegisterForEvent(EVENT_CLOSE_STORE, OnCloseStore)

    local function UpdateActiveComponentKeybindButtonGroup()
        local activeComponent = self:GetActiveComponent()
        if activeComponent then
            KEYBIND_STRIP:UpdateKeybindButtonGroup(activeComponent.keybindStripDescriptor)
        end
    end

    local OnCurrencyChanged = function()
        if not self.control:IsControlHidden() then
            self:RefreshHeaderData()
        end
        UpdateActiveComponentKeybindButtonGroup()
    end

    local OnFailedRepair = function(eventId, reason)
        self:FailedRepairMessageBox(reason)
    end

    local OnBuySuccess = function(...)
        if not self.control:IsControlHidden() then
            ZO_StoreManager_OnPurchased(...)
        end
    end

    local OnSellSuccess = function(eventId, itemName, quantity, money)
        if not self.control:IsControlHidden() then
            PlaySound(SOUNDS.ITEM_MONEY_CHANGED)
        end
    end

    local function OnBuyBackSuccess(eventId, itemName, itemQuantity, money, itemSoundCategory)
        if not self.control:IsControlHidden() then
            -- ESO-713597: Don't play sound if item has no monetary value.
            if money > 0 then
                if itemSoundCategory == ITEM_SOUND_CATEGORY_NONE then
                    -- Fall back sound if there was no other sound to play
                    PlaySound(SOUNDS.ITEM_MONEY_CHANGED)
                else
                    PlayItemSound(itemSoundCategory, ITEM_SOUND_ACTION_ACQUIRE)
                end
            end
            UpdateActiveComponentKeybindButtonGroup()
        end
    end

    local OnInventoryUpdated = function()
        if not self.control:IsControlHidden() then
            self:RefreshHeaderData()
        end
    end

    local function RefreshActiveComponent()
        local activeComponent = self:GetActiveComponent()
        if activeComponent then
            activeComponent:Refresh()
        end
    end

    self.control:RegisterForEvent(EVENT_CURRENCY_UPDATE, OnCurrencyChanged)
    self.control:RegisterForEvent(EVENT_BUY_RECEIPT, OnBuySuccess)
    self.control:RegisterForEvent(EVENT_SELL_RECEIPT, OnSellSuccess)
    self.control:RegisterForEvent(EVENT_BUYBACK_RECEIPT, OnBuyBackSuccess)
    self.control:RegisterForEvent(EVENT_ITEM_REPAIR_FAILURE, OnFailedRepair)
    self.control:RegisterForEvent(EVENT_INVENTORY_FULL_UPDATE, OnInventoryUpdated)
    self.control:RegisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryUpdated)
    self.control:RegisterForEvent(EVENT_ANTIQUITY_LEAD_ACQUIRED, RefreshActiveComponent)
    ZO_COLLECTIBLE_DATA_MANAGER:RegisterCallback("OnCollectionUpdated", RefreshActiveComponent)

    self:InitializeKeybindStrip()
    self.components = {}

    local function OnItemRepaired(bagId, slotIndex)
        if self.isRepairingAll then
            if self.numberItemsRepairing > 0 then
                self.numberItemsRepairing = self.numberItemsRepairing - 1
                if self.numberItemsRepairing == 0 then
                    self:RepairMessageBox()
                    self.isRepairingAll = false
                end
            end
        else
            self:RepairMessageBox(bagId, slotIndex)
        end
        UpdateActiveComponentKeybindButtonGroup()
    end

    SHARED_INVENTORY:RegisterCallback("ItemRepaired", OnItemRepaired)
end

function ZO_GamepadStoreManager:SetDeferredStartingMode(mode)
    self.deferredStartingMode = mode
end

function ZO_GamepadStoreManager:GetActiveComponent()
    return self.activeComponent
end

function ZO_GamepadStoreManager:GetCurrentMode()
    return self.activeComponent and self.activeComponent:GetStoreMode() or nil
end

function ZO_GamepadStoreManager:ActivateActiveComponent()
    if self.activeComponent then
        self.activeComponent:AddKeybinds()
        self:ActivateCurrentList()
    end
end

function ZO_GamepadStoreManager:DeactivateActiveComponent()
    if self.activeComponent then
        self:DeactivateCurrentList()
        self.activeComponent:RemoveKeybinds()
    end
end

function ZO_GamepadStoreManager:RequestEnterHeader()
    if not self.headerFocus or self.headerFocus:IsActive() then
        return
    end

    if self.textSearchHeaderFocus and self:IsTextSearchEntryHidden() then
        return
    end

    if self:CanEnterHeader() then
        self:DeactivateActiveComponent()
        self.headerFocus:Activate()
        self:RefreshKeybinds()
        self:OnEnterHeader()
    end
end

function ZO_GamepadStoreManager:RequestLeaveHeader()
    if not self.headerFocus or not self.headerFocus:IsActive() then
        return
    end

    if self:CanLeaveHeader() then
        self.headerFocus:Deactivate()
        self:OnLeaveHeader()
        self:RefreshKeybinds()
        self:ActivateActiveComponent()
    end
end

function ZO_GamepadStoreManager:SetActiveComponents(componentTable, searchContext)
    self.activeComponents = {}
    self.searchContext = searchContext
    self:ActivateTextSearch()
    for _, componentMode in ipairs(componentTable) do
        local component = self.components[componentMode]
        component:SetSearchContext(searchContext)
        component:Refresh()
        if ZO_STORE_MODE_HAS_TEXT_SEARCH[component:GetStoreMode()] then
            component.list:SetOnHitBeginningOfListCallback(function()
                self:RequestEnterHeader(self)
            end)
        end
        table.insert(self.activeComponents, component)
    end
    self:RebuildHeaderTabs()
end

function ZO_GamepadStoreManager:AddComponent(component)
    self.components[component:GetStoreMode()] = component
end

function ZO_GamepadStoreManager:OnUpdatedSearchResults()
    local activeComponent = self:GetActiveComponent()
    if activeComponent and ZO_STORE_MODE_HAS_TEXT_SEARCH[activeComponent:GetStoreMode()] then
        activeComponent:Refresh()
    end
end

function ZO_GamepadStoreManager:OnStateChanged(oldState, newState)
    if newState == SCENE_SHOWING then
        self:OnShowing(self)
        self:InitializeStore()
    elseif newState == SCENE_SHOWN then
        self:SetMode(self.deferredStartingMode or self.activeComponents[1]:GetStoreMode())
        self.deferredStartingMode = nil
        ZO_GamepadGenericHeader_Activate(self.header)
    elseif newState == SCENE_HIDING then
        self:OnHiding()
        self.spinner:DetachFromListEntry()
        GAMEPAD_TOOLTIPS:ClearLines(GAMEPAD_LEFT_TOOLTIP)
    elseif newState == SCENE_HIDDEN then
        GAMEPAD_TOOLTIPS:Reset(GAMEPAD_RIGHT_TOOLTIP)
        GAMEPAD_TOOLTIPS:Reset(GAMEPAD_LEFT_TOOLTIP)
        self:OnHide()
        ZO_GamepadGenericHeader_Deactivate(self.header)
    end
end

function ZO_GamepadStoreManager:GetSpinnerValue()
    return self.spinner:GetValue()
end

function ZO_GamepadStoreManager:SetupSpinner(max, value, unitPrice, currencyType)
    self.spinner:SetMinMax(1, zo_min(max, MAX_STORE_WINDOW_STACK_QUANTITY))
    self.spinner:SetValue(value)
    self.spinner:SetupCurrency(unitPrice, currencyType)
end

function ZO_GamepadStoreManager:SetQuantitySpinnerActive(activate, list, ignoreInvalidCost)
    if activate then
        ZO_GamepadGenericHeader_Deactivate(self.header)

        list:RefreshVisible()
        DIRECTIONAL_INPUT:Deactivate(self)
        self.spinner:AttachToTargetListEntry(list)
        self.spinner:SetIgnoreInvalidCost(ignoreInvalidCost)
    else
        self.spinner:DetachFromListEntry()
        ZO_GamepadGenericHeader_Activate(self.header)

        list:RefreshVisible()
        DIRECTIONAL_INPUT:Activate(self, self.control)
    end
end

function ZO_GamepadStoreManager:GetRepairAllKeybind()
    return self.repairAllKeybind
end

function ZO_GamepadStoreManager:InitializeKeybindStrip()
    self.repairAllKeybind =
    {
        name = function()
            local cost = GetRepairAllCost()
            if GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) >= cost then
                return zo_strformat(SI_REPAIR_ALL_KEYBIND_TEXT, ZO_Currency_FormatGamepad(CURT_MONEY, cost, ZO_CURRENCY_FORMAT_WHITE_AMOUNT_ICON))
            end
            return zo_strformat(SI_REPAIR_ALL_KEYBIND_TEXT, ZO_Currency_FormatGamepad(CURT_MONEY, cost, ZO_CURRENCY_FORMAT_ERROR_AMOUNT_ICON))
        end,
        keybind = "UI_SHORTCUT_SECONDARY",
        visible = function() return CanStoreRepair() and GetRepairAllCost() > 0 end,
        enabled = function()
            if GetRepairAllCost() <= GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) then
                return true
            else
                return false, GetString(SI_REPAIR_ALL_CANNOT_AFFORD)
            end
        end,
        callback = function()
            local cost = GetRepairAllCost()
            if cost > GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) then
                self:FailedRepairMessageBox()
            else
                local dialogData =
                {
                    cost = cost,
                    declineCallback = function()
                        self.numberItemsRepairing = 0
                        self.isRepairingAll = false
                    end,
                }

                self.isRepairingAll = true
                self.numberItemsRepairing = self.components[ZO_MODE_STORE_REPAIR]:GetNumRepairItems()
                ZO_Dialogs_ShowGamepadDialog("REPAIR_ALL", dialogData)
            end
        end,
    }
end

function ZO_GamepadStoreManager:RebuildHeaderTabs()
    local function OnCategoryChanged(component)
        if self.activeComponent ~= component then
            self:ShowComponent(component)
        end
    end

    local function OnActivatedChanged(list, activated)
        if activated then
            local component = self.activeComponents[list:GetSelectedIndex()]
            if not self.activeComponent or self.activeComponent ~= component then
                self:ShowComponent(component)
            end
        else
            if not SCENE_MANAGER:IsShowing(self.sceneName) then
                self:HideActiveComponent()
            end
        end
        ZO_GamepadOnDefaultScrollListActivatedChanged(list, activated)
    end

    local tabsTable = {}
    for _, component in ipairs(self.activeComponents) do
        table.insert(tabsTable, {
            text = component:GetTabText(),
            callback = function() OnCategoryChanged(component) end,
        })
    end

    self.headerData =
    {
        tabBarEntries = tabsTable,
        activatedCallback = function(...) OnActivatedChanged(...) end,
    }
    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)
end

function ZO_GamepadStoreManager:ShowComponent(component)
    if SCENE_MANAGER:IsShowing(self.sceneName) then
        self:HideActiveComponent()
        self.activeComponent = component
        self:SetCurrentList(self.activeComponent.list)

        local hasTextSearchHeader = ZO_STORE_MODE_HAS_TEXT_SEARCH[self.activeComponent:GetStoreMode()]
        self:SetTextSearchEntryHidden(not hasTextSearchHeader)
        if hasTextSearchHeader and self.activeComponent.list and self.activeComponent.list:GetNumItems() == 0 then
            self:RequestEnterHeader()
        end

        component:Show()
        self:RefreshHeaderData()
    end
end

function ZO_GamepadStoreManager:HideActiveComponent()
    if self.activeComponent then
        self.activeComponent:Hide()
        self.activeComponent = nil
    end
end

do
    local function UpdateCapacityString()
        local mode = STORE_WINDOW_GAMEPAD:GetCurrentMode()
        if GetNumBagFreeSlots(BAG_BACKPACK) == 0 and (mode == ZO_MODE_STORE_BUY or mode == ZO_MODE_STORE_BUY_BACK) then
            return ZO_ERROR_COLOR:Colorize(zo_strformat(SI_GAMEPAD_INVENTORY_CAPACITY_FORMAT, GetNumBagUsedSlots(BAG_BACKPACK), GetBagSize(BAG_BACKPACK)))
        else
            return zo_strformat(SI_GAMEPAD_INVENTORY_CAPACITY_FORMAT, GetNumBagUsedSlots(BAG_BACKPACK), GetBagSize(BAG_BACKPACK))
        end
    end

    local STORE_CURRENCY_LABEL_OPTIONS = ZO_ShallowTableCopy(ZO_GAMEPAD_CURRENCY_OPTIONS_LONG_FORMAT)

    local function UpdateGold(control)
        local mode = STORE_WINDOW_GAMEPAD:GetCurrentMode()
        if mode == ZO_MODE_STORE_SELL and GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) == GetMaxPossibleCurrency(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) then
            STORE_CURRENCY_LABEL_OPTIONS.color = ZO_ERROR_COLOR
        else
            STORE_CURRENCY_LABEL_OPTIONS.color = nil
        end
        ZO_CurrencyControl_SetSimpleCurrency(control, CURT_MONEY, GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER), STORE_CURRENCY_LABEL_OPTIONS)
        return true
    end

    local function UpdateRidingTrainingCost(control)
        ZO_CurrencyControl_SetSimpleCurrency(control, CURT_MONEY, STABLE_MANAGER.trainingCost, ZO_GAMEPAD_CURRENCY_OPTIONS_LONG_FORMAT, nil, not STABLE_MANAGER:CanAffordTraining())
        return true
    end

    local function GetTransactionLabelString() 
        return GetString(FENCE_GAMEPAD:IsLaundering() and SI_GAMEPAD_FENCE_LAUNDER_LIMIT or SI_GAMEPAD_FENCE_SELL_LIMIT)
    end

    local function GetTransactionValueString()
        local mode = STORE_WINDOW_GAMEPAD:GetCurrentMode()
        local usedTransactions = FENCE_MANAGER:GetNumTransactionsUsed(mode)
        local totalTransactions = FENCE_MANAGER:GetNumTotalTransactions(mode)
        if usedTransactions == totalTransactions then
            return ZO_ERROR_COLOR:Colorize(zo_strformat(SI_GAMEPAD_FENCE_TRANSACTION_COUNT, usedTransactions, totalTransactions))
        else
            return zo_strformat(SI_GAMEPAD_FENCE_TRANSACTION_COUNT, usedTransactions, totalTransactions)
        end
    end

    local function CreateCurrencyHeaderData(currencyType)
        local currencyHeaderData =
        {
            headerText = ZO_Currency_GetAmountLabel(currencyType),
            text = function(control)
                ZO_CurrencyControl_SetSimpleCurrency(control, currencyType, GetCurrencyAmount(currencyType, GetCurrencyPlayerStoredLocation(currencyType)), ZO_GAMEPAD_CURRENCY_OPTIONS_LONG_FORMAT)
                return true
            end,
        }
        return currencyHeaderData
    end

    local CAPACITY_HEADER_DATA =
    {
        headerText = GetString(SI_GAMEPAD_INVENTORY_CAPACITY),
        text = UpdateCapacityString,
    }

    local GOLD_HEADER_DATA =
    {
        headerText = ZO_Currency_GetAmountLabel(CURT_MONEY),
        text = UpdateGold,
    }

    local RIDING_TRAINING_COST_HEADER_DATA =
    {
        headerText = GetString(SI_GAMEPAD_STABLE_TRAINING_COST_HEADER),
        text = UpdateRidingTrainingCost,
    }

    local LAUNDER_TRANSACTION_HEADER_DATA =
    {
        headerText = GetTransactionLabelString,
        text = GetTransactionValueString,
    }

    local g_pendingHeaderData = {}
    function ZO_GamepadStoreManager:RefreshHeaderData()
        if not self.activeComponent then
            return
        end

        ZO_ClearTable(g_pendingHeaderData)
        local mode = self:GetCurrentMode()

        local isStable = mode == ZO_MODE_STORE_STABLE
        local showCapacity = not isStable
        
        if mode == ZO_MODE_STORE_BUY then
            local usedFilterTypes = ZO_StoreManager_GetStoreFilterTypes()
            if usedFilterTypes[ITEMFILTERTYPE_COLLECTIBLE] and NonContiguousCount(usedFilterTypes) == 1 then
                showCapacity = false
            end
        end

        if showCapacity then
            table.insert(g_pendingHeaderData, CAPACITY_HEADER_DATA)
        end

        if mode == ZO_MODE_STORE_BUY then
            if ZO_IsElementInNumericallyIndexedTable(self.storeUsedCurrencies, CURT_MONEY) then
                table.insert(g_pendingHeaderData, GOLD_HEADER_DATA)
            end

            -- We only have space to display the first 2 alternate currencies this store uses. 
            -- According to our design standards, no store should ever use more than gold + 2 alternate currencies anyway.
            local MAX_ALTERNATE_CURRENCIES = 2
            local alternateCurrenciesUsed = 0

            for _, currencyType in ipairs(self.storeUsedCurrencies) do
                if currencyType ~= CURT_MONEY then
                    local headerData = CreateCurrencyHeaderData(currencyType)
                    table.insert(g_pendingHeaderData, headerData)
                    alternateCurrenciesUsed = alternateCurrenciesUsed + 1
                    if alternateCurrenciesUsed >= MAX_ALTERNATE_CURRENCIES then
                        break
                    end
                end
            end
        else
            -- This is for selling, fencing, and the stable
            table.insert(g_pendingHeaderData, GOLD_HEADER_DATA)
        end

        if isStable then
            table.insert(g_pendingHeaderData, RIDING_TRAINING_COST_HEADER_DATA)
        end

        if mode == ZO_MODE_STORE_SELL_STOLEN or mode == ZO_MODE_STORE_LAUNDER then
            table.insert(g_pendingHeaderData, LAUNDER_TRANSACTION_HEADER_DATA)
        end

        local data1 = g_pendingHeaderData[1]
        self.headerData.data1HeaderText = data1 and data1.headerText or nil
        self.headerData.data1Text = data1 and data1.text or nil
        local data2 = g_pendingHeaderData[2]
        self.headerData.data2HeaderText = data2 and data2.headerText or nil
        self.headerData.data2Text = data2 and data2.text or nil
        local data3 = g_pendingHeaderData[3]
        self.headerData.data3HeaderText = data3 and data3.headerText or nil
        self.headerData.data3Text = data3 and data3.text or nil
        local data4 = g_pendingHeaderData[4]
        self.headerData.data4HeaderText = data4 and data4.headerText or nil
        self.headerData.data4Text = data4 and data4.text or nil

        ZO_GamepadGenericHeader_RefreshData(self.header, self.headerData)
    end
end

function ZO_GamepadStoreManager:UpdateRightTooltip(list, mode)
    local selectedData = list:GetTargetData()

    local itemLink = nil
    if selectedData then
        if mode == ZO_MODE_STORE_BUY and selectedData.entryType ~= STORE_ENTRY_TYPE_COLLECTIBLE then
            itemLink = selectedData.itemLink
        elseif mode == ZO_MODE_STORE_BUY_BACK then
            itemLink = selectedData.itemLink
        elseif mode == ZO_MODE_STORE_SELL then
            itemLink = GetItemLink(selectedData.bagId, selectedData.slotIndex)
        end
    end

    if not (itemLink and ZO_LayoutItemLinkEquippedComparison(GAMEPAD_RIGHT_TOOLTIP, itemLink)) then
        GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
    end
end

function ZO_GamepadStoreManager:SetMode(mode)
    for i, component in ipairs(self.activeComponents) do
        if component:GetStoreMode() == mode then
            ZO_GamepadGenericHeader_SetActiveTabIndex(self.header, i)
            break
        end
    end
end

function ZO_GamepadStoreManager:RepairMessageBox(bagId, slotId)
    if not bagId then
        local message = zo_strformat(SI_GAMEPAD_REPAIR_ALL_SUCCESS)
        ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, message)
    else
        local name = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(bagId, slotId))
        local message = zo_strformat(SI_GAMEPAD_REPAIR_ITEM_SUCCESS, name)
        if message then
            ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, message)
        end
    end
end

function ZO_GamepadStoreManager:FailedRepairMessageBox(reason)
    local message = ""
    if reason == ITEM_REPAIR_ALREADY_REPAIRED then
        message = zo_strformat(SI_ITEMREPAIRREASON1)
    elseif reason == ITEM_REPAIR_CANT_AFFORD_REPAIR then
        message = zo_strformat(SI_ITEMREPAIRREASON2)
    elseif reason == nil then
        message = zo_strformat(SI_REPAIR_ALL_CANNOT_AFFORD)
    end
    if message ~= "" then
        ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, message)
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    end
end

do
    internalassert(CURT_MAX_VALUE == 11, "Check if new currency has a store failure")
    local STORE_FAILURE_FOR_CURRENCY_TYPE =
    {
        [CURT_ALLIANCE_POINTS] = STORE_FAILURE_NOT_ENOUGH_ALLIANCE_POINTS,
        [CURT_TELVAR_STONES] = STORE_FAILURE_NOT_ENOUGH_TELVAR_STONES,
        [CURT_WRIT_VOUCHERS] = STORE_FAILURE_NOT_ENOUGH_WRIT_VOUCHERS,
        [CURT_EVENT_TICKETS] = STORE_FAILURE_NOT_ENOUGH_EVENT_TICKETS,
        [CURT_UNDAUNTED_KEYS] = STORE_FAILURE_NOT_ENOUGH_UNDAUNTED_KEYS,
    }
    function ZO_GamepadStoreManager:CanAfford(selectedData)
        local currencyType = selectedData.currencyType1
        local currencyQuantity1 = selectedData.currencyQuantity1
        local playerCurrencyAmount = GetCurrencyAmount(currencyType, GetCurrencyPlayerStoredLocation(currencyType))

        if currencyType and currencyQuantity1 and currencyQuantity1 > 0 and currencyQuantity1 > playerCurrencyAmount then
            if currencyType == CURT_MONEY then
                return false, GetString(SI_NOT_ENOUGH_MONEY)
            end
            return false, GetString("SI_STOREFAILURE", STORE_FAILURE_FOR_CURRENCY_TYPE[currencyType])
        elseif selectedData.price > 0 and selectedData.price > GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) then
            return false, GetString(SI_NOT_ENOUGH_MONEY)
        else
            return true
        end
    end

    function ZO_GamepadStoreManager:CanCarry(selectedData)
        if not (CanItemLinkBeVirtual(selectedData.itemLink) and HasCraftBagAccess()) and not DoesBagHaveSpaceForItemLink(BAG_BACKPACK, selectedData.itemLink) then
            return false, GetString(SI_INVENTORY_ERROR_INVENTORY_FULL)
        else
            return true
        end
    end
end

function ZO_GamepadStoreManager:Show()
    SCENE_MANAGER:Show(self.sceneName)
end

function ZO_GamepadStoreManager:Hide()
    ZO_Gamepad_ParametricList_BagsSearch_Screen.OnHide()
    SCENE_MANAGER:Hide(self.sceneName)
end

-------------------
-- Global functions
-------------------

function ZO_Store_OnInitialize_Gamepad(control)
    STORE_WINDOW_GAMEPAD = ZO_GamepadStoreManager:New(control)
    STORE_WINDOW_GAMEPAD:AddComponent(ZO_GamepadStoreBuy:New(STORE_WINDOW_GAMEPAD))
    STORE_WINDOW_GAMEPAD:AddComponent(ZO_GamepadStoreBuyback:New(STORE_WINDOW_GAMEPAD))
    STORE_WINDOW_GAMEPAD:AddComponent(ZO_GamepadStoreSell:New(STORE_WINDOW_GAMEPAD))
    STORE_WINDOW_GAMEPAD:AddComponent(ZO_GamepadStoreRepair:New(STORE_WINDOW_GAMEPAD))
end
