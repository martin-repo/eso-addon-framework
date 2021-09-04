--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local BuyBack = ZO_InitializingObject:Subclass()

local DATA_TYPE_BUY_BACK_ITEM = 1

function BuyBack:Initialize(control)
    self.control = control
    control.owner = self

    BUY_BACK_FRAGMENT = ZO_FadeSceneFragment:New(control)

    self.list = self.control:GetNamedChild("List")
    self.activeTab = self.control:GetNamedChild("TabsActive")
    self.tabs = self.control:GetNamedChild("Tabs")

    self.freeSlotsLabel = self.control:GetNamedChild("InfoBarFreeSlots")
    self.money = self.control:GetNamedChild("InfoBarMoney")

    self:InitializeList()
    self:InitializeFilterBar()
    self:InitializeSortHeader()
    self:InitializeEvents()
end

function BuyBack:InitializeList()
    ZO_ScrollList_AddDataType(self.list, DATA_TYPE_BUY_BACK_ITEM, "ZO_PlayerInventorySlot", 52, function(control, data) self:SetupBuyBackSlot(control, data) end, nil, nil, ZO_InventorySlot_OnPoolReset)
end

function BuyBack:InitializeFilterBar()
    local menuBarData =
    {
        initialButtonAnchorPoint = RIGHT,
        buttonTemplate = "ZO_StoreTab",
        normalSize = 51,
        downSize = 64,
        buttonPadding = -15,
        animationDuration = 180,
    }

    ZO_MenuBar_SetData(self.tabs, menuBarData)

    local buyBackFilter =
    {
        tooltipText = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_BUYBACK),
        filterType = ITEMFILTERTYPE_BUYBACK,

        descriptor = ITEMFILTERTYPE_BUYBACK,
        normal = "EsoUI/Art/Vendor/vendor_tabIcon_buyback_up.dds", 
        pressed = "EsoUI/Art/Vendor/vendor_tabIcon_buyback_down.dds",
        highlight = "EsoUI/Art/Vendor/vendor_tabIcon_buyback_over.dds",
    }

    ZO_MenuBar_AddButton(self.tabs, buyBackFilter)
    ZO_MenuBar_SelectDescriptor(self.tabs, ITEMFILTERTYPE_BUYBACK)

    self.activeTab:SetText(GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_BUYBACK))
end

function BuyBack:InitializeSortHeader()
    self.sortHeaders = ZO_SortHeaderGroup:New(self.control:GetNamedChild("SortBy"), true)

    self.sortOrder = ZO_SORT_ORDER_UP
    self.sortKey = "name"

    local function OnSortHeaderClicked(key, order)
        self.sortKey = key
        self.sortOrder = order
        self:ApplySort()
    end

    self.sortHeaders:RegisterCallback(ZO_SortHeaderGroup.HEADER_CLICKED, OnSortHeaderClicked)
    self.sortHeaders:AddHeadersFromContainer()
    self.sortHeaders:SelectHeaderByKey("name", ZO_SortHeaderGroup.SUPPRESS_CALLBACKS)

    self.searchBox = self.control:GetNamedChild("SearchFiltersTextSearchBox")

    local function OnTextSearchTextChanged(editBox)
        ZO_EditDefaultText_OnTextChanged(editBox)
        TEXT_SEARCH_MANAGER:SetSearchText("storeTextSearch", editBox:GetText())
    end

    self.searchBox:SetHandler("OnTextChanged", OnTextSearchTextChanged)

    local SUPPRESS_TEXT_CHANGED_CALLBACK = true
    local function OnListTextFilterComplete()
        if BUY_BACK_FRAGMENT:IsShowing() then
            self.searchBox:SetText(TEXT_SEARCH_MANAGER:GetSearchText("storeTextSearch"), SUPPRESS_TEXT_CHANGED_CALLBACK)
            self:UpdateList()
        end
    end

    TEXT_SEARCH_MANAGER:RegisterCallback("UpdateSearchResults", OnListTextFilterComplete)
end

function BuyBack:InitializeEvents()
    local function RefreshFreeSlots()
        if not self.control:IsControlHidden() then
            self:UpdateFreeSlots()
        end
    end

    local function RefreshList()
        if not self.control:IsControlHidden() then
            self:UpdateList()
        end
    end

    local function OnMoneyUpdate()
        self:UpdateMoney()
        RefreshList()
    end

    self.control:RegisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, RefreshFreeSlots)
    self.control:RegisterForEvent(EVENT_INVENTORY_FULL_UPDATE, RefreshFreeSlots)
    self.control:RegisterForEvent(EVENT_MONEY_UPDATE, OnMoneyUpdate)
    self.control:RegisterForEvent(EVENT_UPDATE_BUYBACK, RefreshList)
    self.control:RegisterForEvent(EVENT_BUYBACK_RECEIPT, function(eventId, itemName, itemQuantity, money, itemSoundCategory)
        -- ESO-713597: Don't play sound if item has not monetary value.
        if money > 0 then
            if itemSoundCategory == ITEM_SOUND_CATEGORY_NONE then
                -- Fall back sound if there was no other sound to play
                PlaySound(SOUNDS.ITEM_MONEY_CHANGED)
            else
                PlayItemSound(itemSoundCategory, ITEM_SOUND_ACTION_ACQUIRE)
            end
        end
    end)
end

function BuyBack:UpdateMoney()
    if not self.control:IsControlHidden() then
        self.currentMoney = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
        ZO_CurrencyControl_SetSimpleCurrency(self.money, CURT_MONEY, self.currentMoney, ZO_KEYBOARD_CURRENCY_OPTIONS)
    end
end

function BuyBack:UpdateFreeSlots()
    if not self.control:IsControlHidden() then
        local numUsedSlots, numSlots = PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
        if numUsedSlots < numSlots then
            self.freeSlotsLabel:SetText(zo_strformat(SI_INVENTORY_BACKPACK_REMAINING_SPACES, numUsedSlots, numSlots))
        else
            self.freeSlotsLabel:SetText(zo_strformat(SI_INVENTORY_BACKPACK_COMPLETELY_FULL, numUsedSlots, numSlots))
        end
    end
end

function BuyBack:UpdateList()
    if not self.control:IsControlHidden() then
        ZO_ScrollList_Clear(self.list)
        ZO_ScrollList_ResetToTop(self.list)

        local scrollData = ZO_ScrollList_GetDataList(self.list)

        for entryIndex = 1, GetNumBuybackItems() do
            if TEXT_SEARCH_MANAGER:IsItemInSearchTextResults("storeTextSearch", BACKGROUND_LIST_FILTER_TARGET_BAG_SLOT, BAG_BUYBACK, entryIndex) then
                local icon, name, stack, price, functionalQuality, meetsRequirements, displayQuality = GetBuybackItemInfo(entryIndex)
                if stack > 0 then
                    local buybackData =
                    {
                        slotIndex = entryIndex,
                        icon = icon,
                        name = name,
                        stack = stack,
                        price = price,
                        functionalQuality = functionalQuality,
                        displayQuality = displayQuality,
                        -- quality is deprecated, included here for addon backwards compatibility
                        quality = displayQuality,
                        meetsRequirements = meetsRequirements,
                        stackBuyPrice = stack * price,
                    }

                    scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_BUY_BACK_ITEM, buybackData)
                end
            end
        end

        self:ApplySort()
    end
end

local ITEM_BUY_CURRENCY_OPTIONS =
{
    showTooltips = false,
    font = "ZoFontGameShadow",
    iconSide = RIGHT,
}

function BuyBack:SetupBuyBackSlot(control, data)
    local statusControl = GetControl(control, "Status")
    local slotControl = GetControl(control, "Button")
    local nameControl = GetControl(control, "Name")
    local priceControl = GetControl(control, "SellPrice")

    statusControl:SetHidden(true)

    -- Set info about what slot this is, on the top level slot control
    ZO_InventorySlot_SetType(slotControl, SLOT_TYPE_STORE_BUYBACK)
    slotControl.index = data.slotIndex
    slotControl.moneyCost = data.stackBuyPrice

    ZO_InventorySlot_SetType(control, SLOT_TYPE_STORE_BUYBACK)
    control.index = data.slotIndex
    control.moneyCost = data.stackBuyPrice

    -- Fill in the rest of the controls.
    ZO_ItemSlot_SetupSlotBase(slotControl, data.stack, data.icon, data.meetsRequirements)
    ZO_PlayerInventorySlot_SetupUsableAndLockedColor(control, data.meetsRequirements)
    nameControl:SetText(zo_strformat(SI_TOOLTIP_ITEM_NAME, data.name))
    -- data.quality is deprecated, included here for addon backwards compatibility
    nameControl:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, data.displayQuality or data.quality))

    -- Setup the currency fields for the price.
    local notEnough = self.currentMoney < data.stackBuyPrice
    ZO_CurrencyControl_SetSimpleCurrency(priceControl, CURT_MONEY, data.stackBuyPrice, ITEM_BUY_CURRENCY_OPTIONS, CURRENCY_DONT_SHOW_ALL, notEnough)
end

do
    local sortKeys =
    {
        name = {},
        stackBuyPrice = { tiebreaker = "name", isNumeric = true },
    }
    function BuyBack:ApplySort()
        local function Comparator(left, right)
            return ZO_TableOrderingFunction(left.data, right.data, self.sortKey, sortKeys, self.sortOrder)
        end

        local scrollData = ZO_ScrollList_GetDataList(self.list)
        table.sort(scrollData, Comparator)
        ZO_ScrollList_Commit(self.list)
    end
end

function BuyBack:OnShown()
    self.searchBox:SetText(TEXT_SEARCH_MANAGER:GetSearchText("storeTextSearch"))
    self:UpdateMoney()
    self:UpdateList()
    self:UpdateFreeSlots()
end

function ZO_BuyBack_OnInitialize(control)
    BUY_BACK_WINDOW = BuyBack:New(control)
end
