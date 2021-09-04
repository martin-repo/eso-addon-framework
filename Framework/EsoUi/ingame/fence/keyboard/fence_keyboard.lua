--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

--[[
---- Lifecycle
--]]

ZO_Fence_Keyboard = ZO_Fence_Base:Subclass()

function ZO_Fence_Keyboard:New(...)
    return ZO_Fence_Base.New(self, ...)
end

function ZO_Fence_Keyboard:Initialize(control)
    local resetTimeControl = control:GetNamedChild("ResetTime")
    self.resetTimeControl = resetTimeControl
    self.resetTimeStatControl = resetTimeControl:GetNamedChild("Stat")
    self.resetTimeValueControl = resetTimeControl:GetNamedChild("Value")

    -- Call base initialize
    ZO_Fence_Base.Initialize(self, control)
    SYSTEMS:RegisterKeyboardObject("fence", self)

    -- Create scene
    FENCE_SCENE = ZO_InteractScene:New("fence_keyboard", SCENE_MANAGER, STORE_INTERACTION)
    FENCE_SCENE:RegisterCallback("StateChange",
        function(oldState, newState)
            if newState == SCENE_SHOWING then
                self.modeBar:SelectFragment(SI_STORE_MODE_SELL)
            elseif newState == SCENE_HIDDEN then
                self.mode = nil
                ZO_InventorySlot_RemoveMouseOverKeybinds()
                KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
                self.modeBar:Clear()
            end
        end)

    -- Initialize Mode Bar
    self:InitializeModeBar()

    local lastUpdateSeconds = 0
    local function OnUpdate(currentControl, currentFrameTimeSeconds)
        if currentFrameTimeSeconds - lastUpdateSeconds > 1 then
            self:RefreshFooter()
            lastUpdateSeconds = currentFrameTimeSeconds
        end
    end
    control:SetHandler("OnUpdate", OnUpdate)
end

function ZO_Fence_Keyboard:InitializeModeBar(enableSell, enableLaunder)
    if not self.modeBar then
        self.modeBar = ZO_SceneFragmentBar:New(ZO_Fence_Keyboard_WindowMenuBar)
    else
        self.modeBar:RemoveAll()
    end

    local function CreateButtonData(normal, pressed, highlight, clickSound, tutorialTrigger, additionalCallback)
        return {
            normal = normal,
            pressed = pressed,
            highlight = highlight,
            clickSound = clickSound,
            callback = function()
                TriggerTutorial(tutorialTrigger)
                if additionalCallback then
                    additionalCallback()
                end
            end
        }
    end

    local stackAllButton =
    {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        {
            name = GetString(SI_ITEM_ACTION_STACK_ALL),
            keybind = "UI_SHORTCUT_QUINARY",
            callback = function()
                StackBag(BAG_BACKPACK)
            end,
        }
    }

    --Sell Button
    if enableSell then
        local sellButtonData = CreateButtonData("EsoUI/Art/Vendor/vendor_tabIcon_sell_up.dds",
                                                "EsoUI/Art/Vendor/vendor_tabIcon_sell_down.dds",
                                                "EsoUI/Art/Vendor/vendor_tabIcon_sell_over.dds",
                                                SOUNDS.MENU_BAR_CLICK, 
                                                TUTORIAL_TRIGGER_FENCE_OPENED,
                                                function() FENCE_MANAGER:OnEnterSell() end)

        self.modeBar:Add(SI_STORE_MODE_SELL, { INVENTORY_FRAGMENT, BACKPACK_FENCE_LAYOUT_FRAGMENT }, sellButtonData, stackAllButton)
    end

    --Launder Button
    if enableLaunder then
        local launderButtonData = CreateButtonData("EsoUI/Art/Vendor/vendor_tabIcon_fence_up.dds",
                                                   "EsoUI/Art/Vendor/vendor_tabIcon_fence_down.dds",
                                                   "EsoUI/Art/Vendor/vendor_tabIcon_fence_over.dds",
                                                   SOUNDS.MENU_BAR_CLICK,
                                                   TUTORIAL_TRIGGER_LAUNDER_OPENED,
                                                   function() FENCE_MANAGER:OnEnterLaunder() end)

        self.modeBar:Add(SI_FENCE_LAUNDER_TAB, { INVENTORY_FRAGMENT, BACKPACK_LAUNDER_LAYOUT_FRAGMENT }, launderButtonData, stackAllButton)
    end
end

--[[
---- Callbacks
--]]

do
    local INVENTORY_TYPE_LIST = { INVENTORY_BACKPACK }
    function ZO_Fence_Keyboard:OnOpened(enableSell, enableLaunder)
        if not IsInGamepadPreferredMode() then
            PLAYER_INVENTORY:SetContextForInventories("fenceTextSearch", INVENTORY_TYPE_LIST)
            TEXT_SEARCH_MANAGER:ActivateTextSearch("fenceTextSearch")
            self:InitializeModeBar(enableSell, enableLaunder)
            self.mode = enableSell and ZO_MODE_STORE_SELL_STOLEN or ZO_MODE_STORE_LAUNDER
            SCENE_MANAGER:Show("fence_keyboard")
        end
    end

    function ZO_Fence_Keyboard:OnClosed()
        if TEXT_SEARCH_MANAGER:IsActiveTextSearch("fenceTextSearch") then
            TEXT_SEARCH_MANAGER:DeactivateTextSearch("fenceTextSearch")
            local REMOVE_CONTEXT = nil
            PLAYER_INVENTORY:SetContextForInventories(REMOVE_CONTEXT, INVENTORY_TYPE_LIST)
        end
        SCENE_MANAGER:Hide("fence_keyboard")
        ZO_Dialogs_ReleaseDialog("CANT_BUYBACK_FROM_FENCE")
        ZO_PlayerInventorySortByPriceName:SetText(GetString(SI_INVENTORY_SORT_TYPE_PRICE))
        ZO_PlayerInventoryInfoBarAltFreeSlots:SetHidden(true)
        ZO_PlayerInventoryInfoBarAltMoney:SetHidden(true)
    end
end

function ZO_Fence_Keyboard:OnFenceStateUpdated(totalSells, sellsUsed, totalLaunders, laundersUsed)
    if self:IsLaundering() then
        self:UpdateTransactionLabel(totalLaunders, laundersUsed, SI_FENCE_LAUNDER_LIMIT, SI_FENCE_LAUNDER_LIMIT_REACHED)
        PlaySound(SOUNDS.FENCE_ITEM_LAUNDERED)
    else
        self:UpdateTransactionLabel(totalSells, sellsUsed, SI_FENCE_SELL_LIMIT, SI_FENCE_SELL_LIMIT_REACHED)
        local hagglingSkillLevel = FENCE_MANAGER:GetHagglingBonus()
        self:UpdateHagglingLabel(hagglingSkillLevel)
    end
end

function ZO_Fence_Keyboard:OnEnterSell(totalSells, sellsUsed)
    self.mode = ZO_MODE_STORE_SELL_STOLEN
    ZO_PlayerInventoryInfoBarAltFreeSlots:SetHidden(false)
    ZO_PlayerInventoryInfoBarAltMoney:SetHidden(false)
    self:UpdateTransactionLabel(totalSells, sellsUsed, SI_FENCE_SELL_LIMIT, SI_FENCE_SELL_LIMIT_REACHED)
    local hagglingSkillLevel = FENCE_MANAGER:GetHagglingBonus()
    self:UpdateHagglingLabel(hagglingSkillLevel)
    PLAYER_INVENTORY:RefreshBackpackWithFenceData()
    ZO_PlayerInventorySortByPriceName:SetText(GetString(SI_INVENTORY_SORT_TYPE_PRICE))
    self:RefreshFooter()
end

function ZO_Fence_Keyboard:OnEnterLaunder(totalLaunders, laundersUsed)
    self.mode = ZO_MODE_STORE_LAUNDER
    ZO_PlayerInventoryInfoBarAltFreeSlots:SetHidden(false)
    ZO_PlayerInventoryInfoBarAltMoney:SetHidden(true)
    self:UpdateTransactionLabel(totalLaunders, laundersUsed, SI_FENCE_LAUNDER_LIMIT, SI_FENCE_LAUNDER_LIMIT_REACHED)

    local function ColorCost(control, data, scrollList)
        local priceControl = control:GetNamedChild("SellPrice")
        ZO_CurrencyControl_SetCurrencyData(priceControl, CURT_MONEY, data.stackLaunderPrice, CURRENCY_DONT_SHOW_ALL, (GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) < data.stackLaunderPrice))
        ZO_CurrencyControl_SetCurrency(priceControl, ZO_KEYBOARD_CURRENCY_OPTIONS)
    end

    PLAYER_INVENTORY:RefreshBackpackWithFenceData(ColorCost)
    ZO_PlayerInventorySortByPriceName:SetText(GetString(SI_LAUNDER_SORT_TYPE_COST))
    self:RefreshFooter()
end

--[[
---- Helper functions
--]]

function ZO_Fence_Keyboard:UpdateTransactionLabel(totalTransactions, usedTransactions, transactionsRemainingString, transactionsFullString)
    local transactionString = (usedTransactions >= totalTransactions) and transactionsFullString or transactionsRemainingString
    ZO_PlayerInventoryInfoBarAltFreeSlots:SetText(zo_strformat(transactionString, usedTransactions, totalTransactions))
end

function ZO_Fence_Keyboard:UpdateHagglingLabel(skillLevel)
    if skillLevel > 0 then
        ZO_PlayerInventoryInfoBarAltMoney:SetText(zo_strformat(SI_FENCE_HAGGLING_SKILL_BONUS_LABEL, skillLevel))
        ZO_PlayerInventoryInfoBarAltMoney:SetHidden(false)
    else
        ZO_PlayerInventoryInfoBarAltMoney:SetHidden(true)
    end
end

function ZO_Fence_Keyboard:IsLaundering()
    return self.mode == ZO_MODE_STORE_LAUNDER
end

function ZO_Fence_Keyboard:IsSellingStolenItems()
    return self.mode == ZO_MODE_STORE_SELL_STOLEN
end

function ZO_Fence_Keyboard:RefreshFooter()
    if self.mode == ZO_MODE_STORE_SELL_STOLEN then
        local totalSells, sellsUsed, resetTimeSeconds = GetFenceSellTransactionInfo()
        if totalSells - sellsUsed <= 0 then
            self.resetTimeStatControl:SetText(GetString(SI_FENCE_SELL_LIMIT_RESET))

            local timeText = ZO_FormatTimeMilliseconds(resetTimeSeconds * 1000, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
            self.resetTimeValueControl:SetText(timeText)
            self.resetTimeControl:SetHidden(false)
        else
            self.resetTimeControl:SetHidden(true)
        end
    elseif self.mode == ZO_MODE_STORE_LAUNDER then
        local totalLaunders, laundersUsed, resetTimeSeconds = GetFenceLaunderTransactionInfo()
        if totalLaunders - laundersUsed <= 0 then
            self.resetTimeStatControl:SetText(GetString(SI_FENCE_LAUNDER_LIMIT_RESET))

            local timeText = ZO_FormatTimeMilliseconds(resetTimeSeconds * 1000, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
            self.resetTimeValueControl:SetText(timeText)
            self.resetTimeControl:SetHidden(false)
        else
            self.resetTimeControl:SetHidden(true)
        end
    end
end


--[[
----  Global Functions
--]]

function ZO_Fence_Keyboard_Initialize(control)
    FENCE_KEYBOARD = ZO_Fence_Keyboard:New(control)
end
