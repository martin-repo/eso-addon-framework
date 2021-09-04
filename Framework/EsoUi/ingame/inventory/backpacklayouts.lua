--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

----------------------------------------
-- Backpack Layout Fragment
----------------------------------------

ZO_BackpackLayoutFragment = ZO_SceneFragment:Subclass()
local DEFAULT_BACKPACK_LAYOUT_DATA =
{
    inventoryFilterDividerTopOffsetY = DEFAULT_INVENTORY_FILTER_DIVIDER_TOP_OFFSET_Y,
    width = 565,
    backpackOffsetY = 136,
    inventoryTopOffsetY = -20,
    inventoryBottomOffsetY = -30,
    sortByOffsetY = 103,
    emptyLabelOffsetY = 200,
    sortByHeaderWidth = 576,
    sortByNameWidth = 241,
    useSearchBar = true,
    hideBankInfo = true,
    hideCurrencyInfo = false,
}

function ZO_BackpackLayoutFragment:New(...)
    local fragment = ZO_SceneFragment.New(self)
    fragment:Initialize(...)
    return fragment
end

function ZO_BackpackLayoutFragment:Initialize(layoutData)
    if(layoutData) then
        for k,v in pairs(DEFAULT_BACKPACK_LAYOUT_DATA) do
            if layoutData[k] == nil then
                layoutData[k] = v
            end
        end
        self.layoutData = layoutData
    else
        self.layoutData = DEFAULT_BACKPACK_LAYOUT_DATA
    end
end

function ZO_BackpackLayoutFragment:SetLayoutValue(key, value)
    self.layoutData[key] = value
end

function ZO_BackpackLayoutFragment:Show()
    PLAYER_INVENTORY:ApplyBackpackLayout(self.layoutData)
    self:OnShown()
end

function ZO_BackpackLayoutFragment:Hide()
    self:OnHidden()
end

----------------------------------------
-- Fragment Declarations
----------------------------------------
local DEFAULT_INVENTORY_TOP_OFFSET_Y = ZO_SCENE_MENU_HEIGHT -- currently we only need to offset by the height of the menu bar from ZO_InventoryMenu

BACKPACK_DEFAULT_LAYOUT_FRAGMENT = ZO_BackpackLayoutFragment:New()

BACKPACK_MENU_BAR_LAYOUT_FRAGMENT = ZO_BackpackLayoutFragment:New(
    {
        inventoryTopOffsetY = DEFAULT_INVENTORY_TOP_OFFSET_Y,
        inventoryFilterDividerTopOffsetY = DEFAULT_INVENTORY_FILTER_DIVIDER_TOP_OFFSET_Y,
    })

BACKPACK_BANK_LAYOUT_FRAGMENT = ZO_BackpackLayoutFragment:New(
    {
        inventoryTopOffsetY = DEFAULT_INVENTORY_TOP_OFFSET_Y,
        inventoryFilterDividerTopOffsetY = DEFAULT_INVENTORY_FILTER_DIVIDER_TOP_OFFSET_Y,
        hiddenFilters = { [ITEM_TYPE_DISPLAY_CATEGORY_QUEST] = true },
        additionalFilter = function (slot)
            return (not slot.stolen)
        end,
        hideBankInfo = false,
    })

BACKPACK_HOUSE_BANK_LAYOUT_FRAGMENT = ZO_DeepTableCopy(BACKPACK_BANK_LAYOUT_FRAGMENT)
BACKPACK_HOUSE_BANK_LAYOUT_FRAGMENT:SetLayoutValue("hideCurrencyInfo", true)

BACKPACK_GUILD_BANK_LAYOUT_FRAGMENT = ZO_BackpackLayoutFragment:New(
    {
        inventoryTopOffsetY = DEFAULT_INVENTORY_TOP_OFFSET_Y,
        inventoryFilterDividerTopOffsetY = DEFAULT_INVENTORY_FILTER_DIVIDER_TOP_OFFSET_Y,
        hiddenFilters = { [ITEM_TYPE_DISPLAY_CATEGORY_QUEST] = true },
        additionalFilter = function (slot)
            return not (slot.stolen or slot.isPlayerLocked or slot.isBoPTradeable or IsItemBound(slot.bagId, slot.slotIndex))
        end,
        hideBankInfo = false,
    })

BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT = ZO_BackpackLayoutFragment:New(
    {
        inventoryTopOffsetY = DEFAULT_INVENTORY_TOP_OFFSET_Y,
        inventoryFilterDividerTopOffsetY = DEFAULT_INVENTORY_FILTER_DIVIDER_TOP_OFFSET_Y,
        backpackOffsetY = 140,
        sortByOffsetY = 110,
        emptyLabelOffsetY = 140,
        hiddenFilters = { [ITEM_TYPE_DISPLAY_CATEGORY_QUEST] = true, [ITEM_TYPE_DISPLAY_CATEGORY_JUNK] = true },
        additionalFilter = function(slot)
            return IsItemSellableOnTradingHouse(slot.bagId, slot.slotIndex)
        end,
    })

BACKPACK_MAIL_LAYOUT_FRAGMENT = ZO_BackpackLayoutFragment:New(
    {
        inventoryTopOffsetY = 50,
        inventoryBottomOffsetY = -60,
        inventoryFilterDividerTopOffsetY = DEFAULT_INVENTORY_FILTER_DIVIDER_TOP_OFFSET_Y,
        hiddenFilters = { [ITEM_TYPE_DISPLAY_CATEGORY_QUEST] = true },
        additionalFilter = function (slot)
            return (not IsItemBound(slot.bagId, slot.slotIndex)) and (not slot.stolen) and (not slot.isPlayerLocked) and (not IsItemBoPAndTradeable(slot.bagId, slot.slotIndex))
        end,
    })

BACKPACK_PLAYER_TRADE_LAYOUT_FRAGMENT = ZO_BackpackLayoutFragment:New(
    {
        inventoryTopOffsetY = 50,
        inventoryBottomOffsetY = -60,
        inventoryFilterDividerTopOffsetY = DEFAULT_INVENTORY_FILTER_DIVIDER_TOP_OFFSET_Y,
        hiddenFilters = { [ITEM_TYPE_DISPLAY_CATEGORY_QUEST] = true },
        additionalFilter = function (slot)
            return TRADE_WINDOW:CanTradeItem(slot)
        end,
        waitUntilInventoryOpensToClearNewStatus = true,
        alwaysReapplyLayout = true,
    })

BACKPACK_STORE_LAYOUT_FRAGMENT = ZO_BackpackLayoutFragment:New(
    {
        inventoryTopOffsetY = DEFAULT_INVENTORY_TOP_OFFSET_Y,
        inventoryBottomOffsetY = -30,
        inventoryFilterDividerTopOffsetY = DEFAULT_INVENTORY_FILTER_DIVIDER_TOP_OFFSET_Y,
        hiddenFilters = { [ITEM_TYPE_DISPLAY_CATEGORY_QUEST] = true },
        additionalFilter = function (slot)
            return (not slot.stolen) and (not slot.isPlayerLocked)
        end,
        alwaysReapplyLayout = true,
    })

BACKPACK_FENCE_LAYOUT_FRAGMENT = ZO_BackpackLayoutFragment:New(
    {
        inventoryTopOffsetY = DEFAULT_INVENTORY_TOP_OFFSET_Y,
        inventoryBottomOffsetY = -30,
        inventoryFilterDividerTopOffsetY = DEFAULT_INVENTORY_FILTER_DIVIDER_TOP_OFFSET_Y,
        hiddenFilters = { [ITEM_TYPE_DISPLAY_CATEGORY_QUEST] = true },
        additionalFilter = function (slot)
            return slot.stolen and slot.stackSellPrice > 0
        end,
        alwaysReapplyLayout = true,
    })

BACKPACK_LAUNDER_LAYOUT_FRAGMENT = ZO_BackpackLayoutFragment:New(
    {
        inventoryTopOffsetY = DEFAULT_INVENTORY_TOP_OFFSET_Y,
        inventoryBottomOffsetY = -30,
        inventoryFilterDividerTopOffsetY = DEFAULT_INVENTORY_FILTER_DIVIDER_TOP_OFFSET_Y,
        hiddenFilters = { [ITEM_TYPE_DISPLAY_CATEGORY_QUEST] = true },
        additionalFilter = function (slot)
            return slot.stolen
        end,
        alwaysReapplyLayout = true,
    })