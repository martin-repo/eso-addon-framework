--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local DATA_TYPE_QUICKSLOT_ITEM = 1
local DATA_TYPE_COLLECTIBLE_ITEM = 2
local DATA_TYPE_QUICKSLOT_QUEST_ITEM = 3

local PLAY_ANIMATION = true

local STOLEN_ICON_TEXTURE = "EsoUI/Art/Inventory/inventory_stolenItem_icon.dds"

local LIST_ENTRY_HEIGHT = 52

-------------------
--Quickslot Manager
-------------------

ZO_QuickslotManager = ZO_InitializingObject:Subclass()

function ZO_QuickslotManager:Initialize(container)
    self.container = container
    self.money = container:GetNamedChild("InfoBarMoney")

    self.activeTab = container:GetNamedChild("TabsActive")
    self.freeSlotsLabel = container:GetNamedChild("InfoBarFreeSlots")

    self.list = container:GetNamedChild("List")
    ZO_ScrollList_AddDataType(self.list, DATA_TYPE_QUICKSLOT_ITEM, "ZO_PlayerInventorySlot", LIST_ENTRY_HEIGHT, function(control, data) self:SetUpQuickSlot(control, data) end, nil, nil, ZO_InventorySlot_OnPoolReset)
    ZO_ScrollList_AddDataType(self.list, DATA_TYPE_COLLECTIBLE_ITEM, "ZO_CollectionsSlot", LIST_ENTRY_HEIGHT, function(control, data) self:SetUpCollectionSlot(control, data) end, nil, nil, ZO_InventorySlot_OnPoolReset)
    ZO_ScrollList_AddDataType(self.list, DATA_TYPE_QUICKSLOT_QUEST_ITEM, "ZO_PlayerInventorySlot", LIST_ENTRY_HEIGHT, function(control, data) self:SetUpQuestItemSlot(control, data) end, nil, nil, ZO_InventorySlot_OnPoolReset)

    local quickslotFilterTargetDescriptor =
    {
        [BACKGROUND_LIST_FILTER_TARGET_BAG_SLOT] =
        {
            searchFilterList =
            {
                BACKGROUND_LIST_FILTER_TYPE_NAME,
            },
            primaryKeys =
            {
                BAG_BACKPACK,
            }
        },
        [BACKGROUND_LIST_FILTER_TARGET_QUEST_ITEM_ID] =
        {
            searchFilterList =
            {
                BACKGROUND_LIST_FILTER_TYPE_NAME,
            },
            primaryKeys = ZO_FilterTargetDescriptor_GetQuestItemIdList,
        },
        [BACKGROUND_LIST_FILTER_TARGET_COLLECTIBLE_ID] =
        {
            searchFilterList =
            {
                BACKGROUND_LIST_FILTER_TYPE_NAME,
            },
            primaryKeys = function()
                local collectibleIdList = {}
                local NO_CATEGORY_FILTERS = nil
                local dataList = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects(NO_CATEGORY_FILTERS, { ZO_CollectibleData.IsUnlocked, ZO_CollectibleData.IsValidForPlayer, ZO_CollectibleData.IsSlottable })
                for _, data in ipairs(dataList) do
                    table.insert(collectibleIdList, data.collectibleId)
                end
                return collectibleIdList
            end,
        },
    }
    TEXT_SEARCH_MANAGER:SetupContextTextSearch("quickslotTextSearch", quickslotFilterTargetDescriptor)

    self.searchBox = container:GetNamedChild("SearchFiltersTextSearchBox");

    local function OnTextSearchTextChanged(editBox)
        ZO_EditDefaultText_OnTextChanged(editBox)
        TEXT_SEARCH_MANAGER:SetSearchText("quickslotTextSearch", editBox:GetText())
    end

    self.searchBox:SetHandler("OnTextChanged", OnTextSearchTextChanged)

    local SUPPRESS_TEXT_CHANGED_CALLBACK = true
    local function OnListTextFilterComplete()
        if QUICKSLOT_FRAGMENT:IsShowing() then
            self.searchBox:SetText(TEXT_SEARCH_MANAGER:GetSearchText("quickslotTextSearch"), SUPPRESS_TEXT_CHANGED_CALLBACK)
            self:UpdateList()
        end
    end

    TEXT_SEARCH_MANAGER:RegisterCallback("UpdateSearchResults", OnListTextFilterComplete)

    self.sortHeadersControl = container:GetNamedChild("SortBy")
    self.sortHeaders = ZO_SortHeaderGroup:New(self.sortHeadersControl, true)

    self.circle = ZO_QuickSlotCircle
    self.quickSlots = {}

    self.tabs = container:GetNamedChild("Tabs")

    self.quickslotFilters = {}

    self:InsertCollectibleCategories()

    table.insert(self.quickslotFilters, self:CreateNewTabFilterData(ITEMFILTERTYPE_QUEST_QUICKSLOT,
                          GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_QUEST_QUICKSLOT),
                          "EsoUI/Art/Inventory/inventory_tabIcon_quest_up.dds",
                          "EsoUI/Art/Inventory/inventory_tabIcon_quest_down.dds",
                          "EsoUI/Art/Inventory/inventory_tabIcon_quest_over.dds"))

    table.insert(self.quickslotFilters, self:CreateNewTabFilterData(ITEMFILTERTYPE_QUICKSLOT,
                          GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_QUICKSLOT),
                          "EsoUI/Art/Inventory/inventory_tabIcon_items_up.dds",
                          "EsoUI/Art/Inventory/inventory_tabIcon_items_down.dds",
                          "EsoUI/Art/Inventory/inventory_tabIcon_items_over.dds"))

    table.insert(self.quickslotFilters, self:CreateNewTabFilterData(ITEMFILTERTYPE_ALL,
                          GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ALL),
                          "EsoUI/Art/Inventory/inventory_tabIcon_all_up.dds",
                          "EsoUI/Art/Inventory/inventory_tabIcon_all_down.dds",
                          "EsoUI/Art/Inventory/inventory_tabIcon_all_over.dds"))

    local menuBarData =
    {
        initialButtonAnchorPoint = RIGHT,
        buttonTemplate = "ZO_QuickSlotTab",
        normalSize = 51,
        downSize = 64,
        buttonPadding = -15,
        animationDuration = 180,
    }

    ZO_MenuBar_SetData(self.tabs, menuBarData)

    for _, data in ipairs(self.quickslotFilters) do
        ZO_MenuBar_AddButton(self.tabs, data)
    end

    ZO_MenuBar_SelectDescriptor(self.tabs, ITEMFILTERTYPE_QUICKSLOT)

    local function OnSortHeaderClicked(key, order)
        self.currentFilter.sortKey = key
        self.currentFilter.sortOrder = order
        self:ApplySort()
    end

    self.sortHeaders:RegisterCallback(ZO_SortHeaderGroup.HEADER_CLICKED, OnSortHeaderClicked)
    self.sortHeaders:AddHeadersFromContainer()
    self.sortHeaders:SelectHeaderByKey("name")

    local function RefreshQuickslotWindow()
        if not container:IsHidden() then
            self:UpdateList()
            self:UpdateFreeSlots()
        end
    end

    local function OnMoneyUpdated(eventCode, newMoney, oldMoney, reason)
        self:RefreshCurrency(newMoney)
    end

    local function OnQuickSlotUpdated(eventCode, physicalSlot)
        self:DoQuickSlotUpdate(physicalSlot, PLAY_ANIMATION)
    end

    local function UpdateAllQuickSlots(eventCode)
        for physicalSlot in pairs(self.quickSlots) do
            self:DoQuickSlotUpdate(physicalSlot)
        end
    end

    local function HandleInventorySlotPickup(bagId, slotId)
        self:ShowAppropriateQuickSlotDropCallouts(bagId, slotId)
    end

    local function HandleActionSlotPickup(slotType, sourceSlot, itemId, itemQualityId, itemRequiredLevel, itemInstanceData)
        local metEquipRequirements = true -- This was already in a slot, chances are you're not going to fail equip requirements...
        local isItem = slotType == ACTION_TYPE_ITEM

        if isItem then
            for slotNum, quickSlot in pairs(self.quickSlots) do
                local validInSlot = IsValidItemForSlotByItemInfo(itemId, itemQualityId, itemRequiredLevel, itemInstanceData, slotNum)
                if validInSlot then
                    self:ShowSlotDropCallout(quickSlot:GetNamedChild("DropCallout"), metEquipRequirements)
                end
            end
        end
    end

    local function HandleCollectibleSlotPickup(collectibleId)
        for slotNum, quickSlot in pairs(self.quickSlots) do
            local validInSlot = IsValidCollectibleForSlot(collectibleId, slotNum)
            if validInSlot then
                self:ShowSlotDropCallout(quickSlot:GetNamedChild("DropCallout"), true)
            end
        end
    end

    local function HandleQuestItemSlotPickup(questItemId)
        for actionSlotIndex, quickSlot in pairs(self.quickSlots) do
            local validInSlot = IsValidQuestItemForSlot(questItemId, actionSlotIndex)
            if validInSlot then
                self:ShowSlotDropCallout(quickSlot:GetNamedChild("DropCallout"), true)
            end
        end
    end

    local function HandleCursorPickup(eventCode, cursorType, ...)
        if cursorType == MOUSE_CONTENT_INVENTORY_ITEM then
            HandleInventorySlotPickup(...)
        elseif cursorType == MOUSE_CONTENT_ACTION then
            HandleActionSlotPickup(...)
        elseif cursorType == MOUSE_CONTENT_COLLECTIBLE then
            HandleCollectibleSlotPickup(...)
        elseif cursorType == MOUSE_CONTENT_QUEST_ITEM then
            HandleQuestItemSlotPickup(...)
        end
    end

    local function HandleCursorCleared()
        self:HideAllQuickSlotDropCallouts()
    end

    self:RefreshCurrency(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER))

    self:CreateQuickSlots()
    UpdateAllQuickSlots()

    local function HandleInventoryChanged()
        if QUICKSLOT_FRAGMENT:IsShowing() then
            for slotNum, quickslot in pairs(self.quickSlots) do
                local slotType = GetSlotType(slotNum)
                if slotType == ACTION_TYPE_ITEM then
                    local itemCount = GetSlotItemCount(slotNum)
                    self:SetupQuickslotCount(quickslot, itemCount)
                end
            end

            RefreshQuickslotWindow()
        end
    end

    local function RefreshSlotLocked(slotIndex, locked)
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        for i = 1, #scrollData do
            local dataEntry = scrollData[i]
            local data = dataEntry.data
            if data.slotIndex == slotIndex then
                data.locked = locked
                ZO_ScrollList_RefreshVisible(self.list)
                break
            end
        end
    end

    local function HandleInventorySlotLocked(_, bagId, slotIndex)
        if bagId == BAG_BACKPACK then
            RefreshSlotLocked(slotIndex, true)
        end
    end

    local function HandleInventorySlotUnlocked(_, bagId, slotIndex)
        if bagId == BAG_BACKPACK then
            RefreshSlotLocked(slotIndex, false)
        end
    end

    local function HandleCooldownUpdates()
        ZO_ScrollList_RefreshVisible(self.list, nil, ZO_InventorySlot_UpdateCooldowns)
    end

    ZO_QuickSlot:RegisterForEvent(EVENT_MONEY_UPDATE, OnMoneyUpdated)
    ZO_QuickSlot:RegisterForEvent(EVENT_INVENTORY_FULL_UPDATE, HandleInventoryChanged)
    ZO_QuickSlot:RegisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, HandleInventoryChanged)
    ZO_QuickSlot:RegisterForEvent(EVENT_LEVEL_UPDATE, function(eventCode, unitTag) if unitTag == "player" then HandleInventoryChanged() end end)
    ZO_QuickSlot:RegisterForEvent(EVENT_ACTION_SLOT_UPDATED, OnQuickSlotUpdated)
    ZO_QuickSlot:RegisterForEvent(EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, UpdateAllQuickSlots)
    ZO_QuickSlot:RegisterForEvent(EVENT_CURSOR_PICKUP, HandleCursorPickup)
    ZO_QuickSlot:RegisterForEvent(EVENT_CURSOR_DROPPED, HandleCursorCleared)
    ZO_QuickSlot:RegisterForEvent(EVENT_INVENTORY_SLOT_LOCKED, HandleInventorySlotLocked)
    ZO_QuickSlot:RegisterForEvent(EVENT_INVENTORY_SLOT_UNLOCKED, HandleInventorySlotUnlocked)
    ZO_QuickSlot:RegisterForEvent(EVENT_ACTION_UPDATE_COOLDOWNS, HandleCooldownUpdates)

    self:InitializeKeybindDescriptor()

    self.quickSlotState = false

    QUICKSLOT_FRAGMENT = ZO_FadeSceneFragment:New(ZO_QuickSlot)
    QUICKSLOT_FRAGMENT:RegisterCallback("StateChange",  function(oldState, newState)
                                                            if newState == SCENE_FRAGMENT_SHOWN then
                                                                TEXT_SEARCH_MANAGER:ActivateTextSearch("quickslotTextSearch")
                                                                self:UpdateList()
                                                                self:UpdateFreeSlots()
                                                            elseif newState == SCENE_FRAGMENT_HIDDEN then
                                                                TEXT_SEARCH_MANAGER:DeactivateTextSearch("quickslotTextSearch")
                                                            end
                                                        end)

    QUICKSLOT_CIRCLE_FRAGMENT = ZO_FadeSceneFragment:New(ZO_QuickSlotCircle)
    QUICKSLOT_CIRCLE_FRAGMENT:RegisterCallback("StateChange",  function(oldState, newState)
                                                            if newState == SCENE_FRAGMENT_SHOWN then
                                                                self.quickSlotState = true
                                                            elseif newState == SCENE_FRAGMENT_HIDDEN then
                                                                self.quickSlotState = false
                                                                -- ensure our keybinds are removed since OnMouseExitQuickSlot may come late
                                                                KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
                                                            end
                                                        end)

    ZO_COLLECTIBLE_DATA_MANAGER:RegisterCallback("OnCollectionUpdated", RefreshQuickslotWindow)
    ZO_COLLECTIBLE_DATA_MANAGER:RegisterCallback("OnCollectibleUpdated", RefreshQuickslotWindow)

    SHARED_INVENTORY:RegisterCallback("FullQuestUpdate", RefreshQuickslotWindow)
    SHARED_INVENTORY:RegisterCallback("SingleQuestUpdate", RefreshQuickslotWindow)
end

function ZO_QuickslotManager:AreQuickSlotsShowing()
    return self.quickSlotState
end

function ZO_QuickslotManager:InitializeKeybindDescriptor()
    self.keybindStripDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_RIGHT,

        -- Remove
        {
            name = GetString(SI_ABILITY_ACTION_CLEAR_SLOT),
            keybind = "UI_SHORTCUT_PRIMARY",

            callback = function()
                local slotId = self.mouseOverSlot.slotNum
                ClearSlot(slotId)
                PlaySound(SOUNDS.QUICKSLOT_CLEAR)
            end,
        },
    }
end

local EMPTY_QUICKSLOT_TEXTURE = "EsoUI/Art/Quickslots/quickslot_emptySlot.dds"

local INITIAL_ROTATION = 0
local TWO_PI = math.pi * 2

function ZO_QuickslotManager:PerformQuickSlotLayout()
    local width, height = self.circle:GetDimensions()
    local scale = self.circle:GetScale()
    local halfWidth, halfHeight = width * scale * 0.5, height * scale * 0.5
    local numQuickSlots = ACTION_BAR_UTILITY_BAR_SIZE

    for i = 1, numQuickSlots do
        local control = self.quickSlots[i + ACTION_BAR_FIRST_UTILITY_BAR_SLOT]
        local centerAngle = INITIAL_ROTATION + i / numQuickSlots * TWO_PI
        local x = math.sin(centerAngle)
        local y = math.cos(centerAngle)

        control:SetAnchor(CENTER, nil, CENTER, x * halfWidth, y * halfHeight)
        control:SetHidden(false)
    end
end

function ZO_QuickslotManager:SetupQuickslotCount(quickslot, count)
    if count then
        quickslot.icon:SetDesaturation(count == 0 and 1 or 0)
        quickslot.countText:SetText(count)
        quickslot.countText:SetHidden(false)
    else
        quickslot.icon:SetDesaturation(0)
        quickslot.countText:SetHidden(true)
    end
end

function ZO_QuickslotManager:CreateQuickSlots()
    for i = ACTION_BAR_FIRST_UTILITY_BAR_SLOT + 1, ACTION_BAR_FIRST_UTILITY_BAR_SLOT + ACTION_BAR_UTILITY_BAR_SIZE do
        local quickSlot = CreateControlFromVirtual("ZO_QuickSlot"..i, self.circle, "ZO_QuickSlotTemplate")

        self.quickSlots[i] = quickSlot
        quickSlot.button = quickSlot:GetNamedChild("Button")
        quickSlot.button.slotNum = i
        quickSlot.icon = quickSlot:GetNamedChild("Icon")
        quickSlot.countText = quickSlot:GetNamedChild("CountText")

        ZO_ActionSlot_SetupSlot(quickSlot.icon, quickSlot.button, EMPTY_QUICKSLOT_TEXTURE)
        ZO_CreateSparkleAnimation(quickSlot)
    end

    self:PerformQuickSlotLayout()
end

function ZO_QuickslotManager:DoQuickSlotUpdate(physicalSlot, animationOption)
    local quickSlot = self.quickSlots[physicalSlot]
    if quickSlot then
        local physicalSlotType = GetSlotType(physicalSlot)

        if physicalSlotType == ACTION_TYPE_NOTHING then
            ZO_ActionSlot_SetupSlot(quickSlot.icon, quickSlot.button, EMPTY_QUICKSLOT_TEXTURE)
            self:SetupQuickslotCount(quickSlot)
        else
            local slotIcon = GetSlotTexture(physicalSlot)
            local itemCount = GetSlotItemCount(physicalSlot)

            ZO_ActionSlot_SetupSlot(quickSlot.icon, quickSlot.button, slotIcon)
            self:SetupQuickslotCount(quickSlot, itemCount)

            -- TODO: There's not a lot to go off of to determine if this quick slot was changing contents
            -- or being used, or anything else.  Probably going to need to add additional event info for
            -- something being placed here instead of just doing a full slot update.
            if animationOption == PLAY_ANIMATION and not quickSlot:IsHidden() then
                ZO_PlaySparkleAnimation(quickSlot)
            end

            local numSlotted = 0
            for i = ACTION_BAR_FIRST_UTILITY_BAR_SLOT + 1, ACTION_BAR_FIRST_UTILITY_BAR_SLOT + ACTION_BAR_UTILITY_BAR_SIZE do
                local slotType = GetSlotType(i)
                if slotType ~= ACTION_TYPE_NOTHING then
                    numSlotted = numSlotted + 1
                end
            end

            if numSlotted == 1 then
                SetCurrentQuickslot(physicalSlot)
            end
        end

        local mouseOverControl = WINDOW_MANAGER:GetMouseOverControl()
        if mouseOverControl == quickSlot.button then
            ZO_AbilitySlot_OnMouseEnter(quickSlot.button)
        end
    end
end

function ZO_QuickslotManager:HideAllQuickSlotDropCallouts()
    for _, quickSlot in pairs(self.quickSlots) do
        quickSlot:GetNamedChild("DropCallout"):SetHidden(true)
    end
end

function ZO_QuickslotManager:ShowSlotDropCallout(calloutControl, meetsUsageRequirement)
    calloutControl:SetHidden(false)

    if meetsUsageRequirement then
        calloutControl:SetColor(1, 1, 1, 1)
    else
        calloutControl:SetColor(1, 0, 0, 1)
    end
end

function ZO_QuickslotManager:ShowAppropriateQuickSlotDropCallouts(bagId, slotIndex)
    local _, _, _, meetsUsageRequirement = GetItemInfo(bagId, slotIndex)

    for slotNum, quickSlot in pairs(self.quickSlots) do
        local validInSlot = IsValidItemForSlot(bagId, slotIndex, slotNum)
        if validInSlot
        then
            self:ShowSlotDropCallout(quickSlot:GetNamedChild("DropCallout"), meetsUsageRequirement)
        end
    end
end

function ZO_QuickslotManager:ChangeFilter(filterData)
    self.currentFilter = filterData
    self.activeTab:SetText(filterData.activeTabText)
    self:UpdateList()
    
    self.sortHeaders:SelectAndResetSortForKey(filterData.sortKey)

    local isNotItemFilter = self.currentFilter.descriptor ~= ITEMFILTERTYPE_QUICKSLOT
    self.sortHeaders:SetHeaderHiddenForKey("stackSellPrice", isNotItemFilter)
    self.sortHeaders:SetHeaderHiddenForKey("age", isNotItemFilter)
end

function ZO_QuickslotManager:ShouldAddItemToList(itemData)
    return ZO_IsElementInNumericallyIndexedTable(itemData.filterData, ITEMFILTERTYPE_QUICKSLOT) and TEXT_SEARCH_MANAGER:IsItemInSearchTextResults("quickslotTextSearch", BACKGROUND_LIST_FILTER_TARGET_BAG_SLOT, itemData.bagId, itemData.slotIndex)
end

function ZO_QuickslotManager:ShouldAddQuestItemToList(questItemData)
    return ZO_IsElementInNumericallyIndexedTable(questItemData.filterData, ITEMFILTERTYPE_QUEST_QUICKSLOT) and TEXT_SEARCH_MANAGER:IsItemInSearchTextResults("quickslotTextSearch", BACKGROUND_LIST_FILTER_TARGET_QUEST_ITEM_ID, questItemData.questItemId)
end

local sortKeys =
{
    name = { },
    age = { tiebreaker = "name", isNumeric = true },
    stackSellPrice = { tiebreaker = "name", isNumeric = true },
}

function ZO_QuickslotManager:SortData()
    local scrollData = ZO_ScrollList_GetDataList(self.list)

    self.sortFunction = self.sortFunction or function(entry1, entry2)
        local sortKey = self.currentFilter.sortKey
        local sortOrder = self.currentFilter.sortOrder

        return ZO_TableOrderingFunction(entry1.data, entry2.data, sortKey, sortKeys, sortOrder)
    end
    table.sort(scrollData, self.sortFunction)
end

function ZO_QuickslotManager:ApplySort()
    self:SortData()
    ZO_ScrollList_Commit(self.list)
end

function ZO_QuickslotManager:RefreshCurrency(value)
    ZO_CurrencyControl_SetSimpleCurrency(self.money, CURT_MONEY, value, ZO_KEYBOARD_CURRENCY_OPTIONS)
end

function ZO_QuickslotManager:ValidateOrClearAllQuickslots()
    for i = ACTION_BAR_FIRST_UTILITY_BAR_SLOT + 1, ACTION_BAR_FIRST_UTILITY_BAR_SLOT + ACTION_BAR_UTILITY_BAR_SIZE do
        ZO_QuickslotRadialManager:ValidateOrClearQuickslot(i)
        self:DoQuickSlotUpdate(i)
    end
end

function ZO_QuickslotManager:UpdateList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ScrollList_Clear(self.list)
    ZO_ScrollList_ResetToTop(self.list)

    local currentFilterType = self.currentFilter.descriptor
    if currentFilterType == ITEMFILTERTYPE_ALL then
        self:AppendItemData(scrollData)
        self:AppendCollectiblesData(scrollData)
        self:AppendQuestItemData(scrollData)
    elseif currentFilterType == ITEMFILTERTYPE_QUICKSLOT then
        self:AppendItemData(scrollData)
    elseif currentFilterType == ITEMFILTERTYPE_COLLECTIBLE then
        local collectibleCategoryData = self.currentFilter.extraInfo
        self:AppendCollectiblesData(scrollData, collectibleCategoryData)
    elseif currentFilterType == ITEMFILTERTYPE_QUEST_QUICKSLOT then
        self:AppendQuestItemData(scrollData)
    end

    self.cachedSearchText = nil

    self:ApplySort()
    self:ValidateOrClearAllQuickslots()
    self.sortHeadersControl:SetHidden(#scrollData == 0)
end

function ZO_QuickslotManager:AppendItemData(scrollData)
    local bagSlots = GetBagSize(BAG_BACKPACK)
    for slotIndex = 0, bagSlots - 1 do
        local slotData = SHARED_INVENTORY:GenerateSingleSlotData(BAG_BACKPACK, slotIndex)
        if slotData and slotData.stackCount > 0 then
            local itemData =
            {
                iconFile = slotData.iconFile,
                stackCount = slotData.stackCount,
                sellPrice = slotData.sellPrice,
                stackSellPrice = slotData.stackCount * slotData.sellPrice,
                bagId = BAG_BACKPACK,
                slotIndex = slotIndex,
                meetsUsageRequirement = slotData.meetsUsageRequirement,
                locked = slotData.locked,
                functionalQuality = slotData.functionalQuality,
                displayQuality = slotData.displayQuality,
                -- slotData.quality is deprecated, included here for addon backwards compatibility
                quality = slotData.displayQuality,
                slotType = SLOT_TYPE_ITEM,
                filterData = { GetItemFilterTypeInfo(BAG_BACKPACK, slotIndex) },
                age = slotData.age,
                stolen = IsItemStolen(BAG_BACKPACK, slotIndex),
                name = slotData.name or zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(BAG_BACKPACK, slotIndex)),
                isGemmable = slotData.isGemmable,
                searchData =
                {
                    type = ZO_TEXT_SEARCH_TYPE_INVENTORY,
                    bagId = BAG_BACKPACK,
                    slotIndex = slotIndex,
                },
            }

            if self:ShouldAddItemToList(itemData) then
                table.insert(scrollData, ZO_ScrollList_CreateDataEntry(DATA_TYPE_QUICKSLOT_ITEM, itemData))
            end
        end
    end
end

function ZO_QuickslotManager:AppendCollectiblesData(scrollData, collectibleCategoryData)
    local dataObjects
    if collectibleCategoryData then
        dataObjects = collectibleCategoryData:GetAllCollectibleDataObjects({ ZO_CollectibleData.IsUnlocked, ZO_CollectibleData.IsValidForPlayer, ZO_CollectibleData.IsSlottable })
    else
        dataObjects = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects({ ZO_CollectibleCategoryData.IsStandardCategory }, { ZO_CollectibleData.IsUnlocked, ZO_CollectibleData.IsValidForPlayer, ZO_CollectibleData.IsSlottable })
    end

    for _, collectibleData in ipairs(dataObjects) do
        collectibleData.searchData =
        {
            type = ZO_TEXT_SEARCH_TYPE_COLLECTIBLE,
            collectibleId = collectibleData.collectibleId,
        }

        if TEXT_SEARCH_MANAGER:IsItemInSearchTextResults("quickslotTextSearch", BACKGROUND_LIST_FILTER_TARGET_COLLECTIBLE_ID, collectibleData.collectibleId) then
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(DATA_TYPE_COLLECTIBLE_ITEM, collectibleData))
        end
    end
end

function ZO_QuickslotManager:AppendQuestItemData(scrollData)
    local questCache = SHARED_INVENTORY:GenerateFullQuestCache()
    for _, questItems in pairs(questCache) do
        for _, questItemData in pairs(questItems) do
            if questItemData.toolIndex then
                questItemData.searchData =
                {
                    type = ZO_TEXT_SEARCH_TYPE_QUEST_TOOL,
                    questIndex = questItemData.questIndex,
                    toolIndex = questItemData.toolIndex,
                    index = questItemData.slotIndex,
                }
            else
                questItemData.searchData =
                {
                    type = ZO_TEXT_SEARCH_TYPE_QUEST_ITEM,
                    questIndex = questItemData.questIndex,
                    stepIndex = questItemData.stepIndex,
                    conditionIndex = questItemData.conditionIndex,
                    toolIndex = questItemData.toolIndex,
                    index = questItemData.slotIndex,
                }
            end

            if self:ShouldAddQuestItemToList(questItemData) then
                table.insert(scrollData, ZO_ScrollList_CreateDataEntry(DATA_TYPE_QUICKSLOT_QUEST_ITEM, questItemData))
            end
        end
    end
end

local function UpdateNewStatusControl(control, data)
    PLAYER_INVENTORY:UpdateNewStatus(INVENTORY_BACKPACK, data.slotIndex, data.bagId)
end

function ZO_QuickslotManager:SetUpQuickSlot(control, data)
    -- data.quality is deprecated, included here for addon backwards compatibility
    local displayQuality = data.displayQuality or data.quality
    local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, displayQuality)
    local nameControl = GetControl(control, "Name")
    nameControl:SetText(data.name)
    nameControl:SetColor(r, g, b, 1)

    local sellPriceControl = GetControl(control, "SellPrice")
    sellPriceControl:SetHidden(false)
    ZO_CurrencyControl_SetSimpleCurrency(sellPriceControl, CURT_MONEY, data.stackSellPrice, ITEM_SLOT_CURRENCY_OPTIONS)

    local inventorySlot = GetControl(control, "Button")
    ZO_Inventory_BindSlot(inventorySlot, data.slotType, data.slotIndex, data.bagId)
    ZO_PlayerInventorySlot_SetupSlot(control, data.stackCount, data.iconFile, data.meetsUsageRequirement, data.locked)

    local statusControl = GetControl(control, "StatusTexture")
    statusControl:ClearIcons()
    if data.stolen then
        statusControl:AddIcon(STOLEN_ICON_TEXTURE)
    end
    if data.isGemmable then
        statusControl:AddIcon(ZO_Currency_GetPlatformCurrencyIcon(CURT_CROWN_GEMS))
    end
    statusControl:Show()

    UpdateNewStatusControl(control, data)
end

function ZO_QuickslotManager:SetUpCollectionSlot(control, data)
    control:GetNamedChild("Name"):SetText(data:GetNameWithNickname())
    control:GetNamedChild("ActiveIcon"):SetHidden(not data:IsActive())

    local slot = GetControl(control, "Button")
    slot.collectibleId = data:GetId()
    slot.active = data:IsActive()
    slot.categoryType = data:GetCategoryType()
    slot.inCooldown = false
    slot.cooldown = GetControl(slot, "Cooldown")
    slot.cooldown:SetTexture(data:GetIcon())
    ZO_InventorySlot_SetType(slot, SLOT_TYPE_COLLECTIONS_INVENTORY)
    ZO_ItemSlot_SetupSlotBase(slot, 1, data:GetIcon())
end

function ZO_QuickslotManager:SetUpQuestItemSlot(rowControl, questItem)
    local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_TOOLTIP, ITEM_TOOLTIP_COLOR_QUEST_ITEM_NAME)
    local nameControl = GetControl(rowControl, "Name")
    nameControl:SetText(questItem.name) -- already formatted
    nameControl:SetColor(r, g, b, 1)

    GetControl(rowControl, "SellPrice"):SetHidden(true)

    local inventorySlot = GetControl(rowControl, "Button")
    ZO_InventorySlot_SetType(inventorySlot, SLOT_TYPE_QUEST_ITEM)

    questItem.slotControl = rowControl

    ZO_Inventory_SetupSlot(inventorySlot, questItem.stackCount, questItem.iconFile)
    ZO_Inventory_SetupQuestSlot(inventorySlot, questItem.questIndex, questItem.toolIndex, questItem.stepIndex, questItem.conditionIndex)

    ZO_UpdateStatusControlIcons(rowControl, questItem)
end

function ZO_QuickslotManager:UpdateFreeSlots()
    local numUsedSlots, numSlots = PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
    if numUsedSlots < numSlots then
        self.freeSlotsLabel:SetText(zo_strformat(SI_INVENTORY_BACKPACK_REMAINING_SPACES, numUsedSlots, numSlots))
    else
        self.freeSlotsLabel:SetText(zo_strformat(SI_INVENTORY_BACKPACK_COMPLETELY_FULL, numUsedSlots, numSlots))
    end
end

function ZO_QuickslotManager:InsertCollectibleCategories()
    for categoryIndex, categoryData in ZO_COLLECTIBLE_DATA_MANAGER:CategoryIterator() do
        if DoesCollectibleCategoryContainSlottableCollectibles(categoryIndex) then
            local name = categoryData:GetName()
            local normalIcon, pressedIcon, mouseoverIcon = categoryData:GetKeyboardIcons()
            local data = self:CreateNewTabFilterData(ITEMFILTERTYPE_COLLECTIBLE, name, normalIcon, pressedIcon, mouseoverIcon, categoryData)
            table.insert(self.quickslotFilters, data)
        end
    end
end

function ZO_QuickslotManager:CreateNewTabFilterData(filterType, text, normal, pressed, highlight, extraInfo)
    local tabData =
    {
        -- Custom data
        activeTabText = text,
        tooltipText = text,
        sortKey = "name",
        sortOrder = ZO_SORT_ORDER_UP,
        extraInfo = extraInfo,

        -- Menu bar data
        descriptor = filterType,
        normal = normal,
        pressed = pressed,
        highlight = highlight,
        callback = function(tabData) self:ChangeFilter(tabData) end,
    }

    return tabData
end

function ZO_QuickslotManager:OnMouseOverQuickSlot(slotControl)
    if slotControl.animation then
        slotControl.animation:PlayForward()
    end

    if self.mouseOverSlot ~= slotControl then
        PlaySound(SOUNDS.QUICKSLOT_MOUSEOVER)
        self.mouseOverSlot = slotControl
    end

    if IsSlotUsed(slotControl.slotNum) then
        KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
    else
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
    end
end

function ZO_QuickslotManager:OnMouseExitQuickSlot(slotControl)
    if slotControl.animation then
        slotControl.animation:PlayBackward()
    end

    self.mouseOverSlot = nil
    KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
end

-------------------
-- Global functions
-------------------

function ZO_QuickSlot_FilterButtonOnMouseEnter(self)
    ZO_MenuBarButtonTemplate_OnMouseEnter(self)
    InitializeTooltip(InformationTooltip, self, BOTTOMRIGHT, 0, 32)
    SetTooltipText(InformationTooltip, ZO_MenuBarButtonTemplate_GetData(self).tooltipText)
end

function ZO_QuickSlot_FilterButtonOnMouseExit(self)
    ClearTooltip(InformationTooltip)
    ZO_MenuBarButtonTemplate_OnMouseExit(self)
end

function ZO_Quickslot_OnInitialize(control)
    QUICKSLOT_WINDOW = ZO_QuickslotManager:New(control)
end

function ZO_QuickslotControl_OnMouseEnter(control)
    QUICKSLOT_WINDOW:OnMouseOverQuickSlot(control)
end

function ZO_QuickslotControl_OnMouseExit(control)
    QUICKSLOT_WINDOW:OnMouseExitQuickSlot(control)
end

function ZO_QuickslotControl_OnInitialize(control)
    local button = control:GetNamedChild("Button")
    button:SetDrawTier(DT_MEDIUM)
    button:SetDrawLayer(DL_BACKGROUND)
    button:SetMouseOverTexture(nil)
    button.slotType = ABILITY_SLOT_TYPE_QUICKSLOT

    local glow = control:GetNamedChild("Glow")
    button.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("QuickslotGlowAlphaAnimation", glow)

    local icon = control:GetNamedChild("Icon")
    icon:SetDrawTier(DT_MEDIUM)
    icon:SetDrawLayer(DL_BACKGROUND)
end
