--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_Loot_Gamepad_Base = ZO_Object:Subclass()

function ZO_Loot_Gamepad_Base:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function ZO_Loot_Gamepad_Base:Initialize(tooltipType)
    self.tooltipType = tooltipType
end

function ZO_Loot_Gamepad_Base:InitializeKeybindStripDescriptorsMixin(areEthereal)
    local lootBackupKeybind = KEYBIND_STRIP:GenerateGamepadBackButtonDescriptor(
            function()
                EndLooting()
            end)

    lootBackupKeybind.ethereal = areEthereal

    self.keybindStripDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        { -- Exit Button
            --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
            name = "Gamepad Loot Exit",
            keybind = "UI_SHORTCUT_EXIT",
            callback =  function()
                EndLooting()
                SCENE_MANAGER:ShowBaseScene()
            end,
            ethereal = true
        },
        { -- Take Selected
            name = GetString(SI_LOOT_TAKE),
            keybind = "UI_SHORTCUT_PRIMARY",
            callback = function()
                self:LootTargeted()
            end,

            ethereal = areEthereal
        },
        { -- Take All
            name = GetString(SI_LOOT_TAKE_ALL),
            keybind = "UI_SHORTCUT_SECONDARY",
            callback =  function()
                LOOT_SHARED:LootAllItems()
            end,
            ethereal = areEthereal
        },
        lootBackupKeybind
    }
end

function ZO_Loot_Gamepad_Base:OnSelectionChanged(list, selectedData, oldSelectedData)
    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)

    if selectedData then
        self:ShowTooltip(selectedData)
        self:UpdateButtonTextOnSelection(selectedData)
    else
        self:HideTooltip()
    end
end

function ZO_Loot_Gamepad_Base:HideTooltip()
    GAMEPAD_TOOLTIPS:ClearTooltip(self.tooltipType)
    GAMEPAD_TOOLTIPS:HideBg(self.tooltipType)
end

do
    local NOT_EQUIPPED = false
    local NO_CREATOR_NAME = nil
    local FORCE_FULL_DURABILITY = true
    local NO_PREVIEW_VALUE = nil
    function ZO_Loot_Gamepad_Base:ShowTooltip(selectedData)
        GAMEPAD_TOOLTIPS:ClearTooltip(self.tooltipType)
        GAMEPAD_TOOLTIPS:Reset(self.tooltipType)
        
        local lootType = selectedData.lootType
        if selectedData.currencyType then
            GAMEPAD_TOOLTIPS:LayoutCurrency(self.tooltipType, selectedData.currencyType, selectedData.currencyAmount)
        elseif selectedData.isQuest then
            GAMEPAD_TOOLTIPS:LayoutQuestItem(self.tooltipType, GetLootQuestItemId(selectedData.lootId))
        elseif lootType == LOOT_TYPE_ANTIQUITY_LEAD then
            GAMEPAD_TOOLTIPS:LayoutAntiquityLead(self.tooltipType, GetLootAntiquityLeadId(selectedData.lootId))
        else
            local lootLink = GetLootItemLink(selectedData.lootId)
            if lootType == LOOT_TYPE_COLLECTIBLE then
                GAMEPAD_TOOLTIPS:LayoutCollectibleFromLink(self.tooltipType, lootLink)
            else
                GAMEPAD_TOOLTIPS:LayoutItemWithStackCount(self.tooltipType, lootLink, NOT_EQUIPPED, NO_CREATOR_NAME, FORCE_FULL_DURABILITY, NO_PREVIEW_VALUE, selectedData.stackCount)
            end
        end
        GAMEPAD_TOOLTIPS:ShowBg(self.tooltipType)
    end
end

function ZO_Loot_Gamepad_Base:LootTargeted()
    local item = self.itemList:GetTargetData()
    if item then
        if item.currencyType then
            LootCurrency(item.currencyType)
        else
            LootItemById(item.lootId)
        end
    end
end

function ZO_Loot_Gamepad_Base:Show()
    assert(false) -- must override
end

function ZO_Loot_Gamepad_Base:HasLootItems()
    local unownedMoney, ownedMoney = GetLootCurrency(CURT_MONEY)
    local telvarStones = GetLootCurrency(CURT_TELVAR_STONES)
    local writVouchers = GetLootCurrency(CURT_WRIT_VOUCHERS)
    return unownedMoney > 0 or ownedMoney > 0 or telvarStones > 0 or writVouchers > 0 or GetNumLootItems() > 0 
end

do
    local STOLEN_ICON_TEXTURE = "EsoUI/Art/Inventory/inventory_stolenItem_icon.dds"

    function ZO_Loot_Gamepad_Base:UpdateList()
        self.itemList:Clear()

        self.itemCount = 0
        -- Assume there are no non-stolen items present until proven otherwise.
        self.nonStolenItemsPresent = false

        local lootData = LOOT_SHARED:GetSortedLootData()

        for _, data in ipairs(lootData) do
            local entryData
            if data.currencyType then
                local currencyIcon = GetCurrencyLootGamepadIcon(data.currencyType)
                entryData = ZO_GamepadEntryData:New(data.name, currencyIcon)
                entryData.currencyType = data.currencyType
                entryData.currencyAmount = data.currencyAmount
                local NO_LOOT_ID = nil
                local NO_DISPLAY_QUALITY = nil
                local NO_VALUE = nil
                local NOT_QUEST_ITEM = nil
                entryData:InitializeLootVisualData(NO_LOOT_ID, data.currencyAmount, NO_DISPLAY_QUALITY, NO_VALUE, NOT_QUEST_ITEM, data.isStolen)
            else
                entryData = ZO_GamepadEntryData:New(data.name, data.icon)
                entryData:InitializeLootVisualData(data.lootId, data.count, data.displayQuality, data.value, data.isQuest, data.isStolen, data.itemType)
            end

            if data.isStolen then
                entryData:AddIcon(STOLEN_ICON_TEXTURE)
            else
                self.nonStolenItemsPresent = true
            end
            self.itemList:AddEntry("ZO_GamepadItemSubEntryTemplate", entryData)
        end
        self.itemCount = self.itemList:GetNumEntries()

        if self.intialLootUpdate then
            self.itemList:CommitWithoutReselect()
        else
            self.itemList:Commit()
        end
    
        -- this text depends on the list itself
        self:UpdateAllControlText()
    end
end

function ZO_Loot_Gamepad_Base:UpdateLootWindow(name, actionName, isOwned)
    if not self.isInitialized then
        self:DeferredInitialize()
    end

    self.numUsedBagSlots = GetNumBagUsedSlots(BAG_BACKPACK)
    self.numTotalBagSlots = GetBagSize(BAG_BACKPACK)
    self.bagFull = self.numUsedBagSlots == self.numTotalBagSlots

    self:SetTitle(name)
    self.intialLootUpdate = self.control:IsControlHidden()
    self:Update(isOwned)

    if self.intialLootUpdate then
        self:Show()
    elseif not self:HasLootItems() then
        self:Hide()
    end
end

function  ZO_Loot_Gamepad_Base:EnoughRoomToTakeAll()
    local itemCount = self.itemCount or 0
    return not (self.numUsedBagSlots + itemCount > self.numTotalBagSlots)
end

-- Overridden in LootPickup

function ZO_Loot_Gamepad_Base:UpdateButtonTextOnSelection(selectedData)
end

function ZO_Loot_Gamepad_Base:UpdateAllControlText()
end

--------------------------
-- ZO_Loot_Common_Gamepad
--------------------------

local ZO_Loot_Common_Gamepad = ZO_Object:Subclass()

function ZO_Loot_Common_Gamepad:UpdateLootWindow(name, actionName, isOwned)
    if SCENE_MANAGER:IsShowing("gamepad_inventory_root") or SCENE_MANAGER:IsSceneOnStack("gamepad_inventory_root") then
        LOOT_INVENTORY_WINDOW_GAMEPAD:UpdateLootWindow(name, actionName, isOwned)
    else
        if SCENE_MANAGER:IsShowing("lootGamepad") or SCENE_MANAGER:IsShowingBaseScene() then
            --The update will show the window if we're on the base scene
            LOOT_WINDOW_GAMEPAD:UpdateLootWindow(name, actionName, isOwned)
        else
            EndInteraction(INTERACTION_LOOT)
        end
    end
end

function ZO_Loot_Common_Gamepad:Hide()
    LOOT_WINDOW_GAMEPAD:Hide()
    LOOT_INVENTORY_WINDOW_GAMEPAD:Hide()
end

function ZO_Loot_Common_Gamepad:AreNonStolenItemsPresent()
    return (LOOT_WINDOW_GAMEPAD.nonStolenItemsPresent == true)
end

--[[ Globals ]]--
LOOT_COMMON_GAMEPAD = ZO_Loot_Common_Gamepad:New()
SYSTEMS:RegisterGamepadObject("loot", LOOT_COMMON_GAMEPAD)
