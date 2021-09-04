--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local ITEM_TYPE_TO_CATEGORY_MAP = {
    [ITEMTYPE_REAGENT] = GAMEPAD_ITEM_CATEGORY_ALCHEMY,
    [ITEMTYPE_POTION_BASE] = GAMEPAD_ITEM_CATEGORY_ALCHEMY,
    [ITEMTYPE_POISON_BASE] = GAMEPAD_ITEM_CATEGORY_ALCHEMY,

    [ITEMTYPE_LURE] = GAMEPAD_ITEM_CATEGORY_BAIT,

    [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = GAMEPAD_ITEM_CATEGORY_BLACKSMITH,
    [ITEMTYPE_BLACKSMITHING_MATERIAL] = GAMEPAD_ITEM_CATEGORY_BLACKSMITH,
    [ITEMTYPE_BLACKSMITHING_BOOSTER] = GAMEPAD_ITEM_CATEGORY_BLACKSMITH,

    [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = GAMEPAD_ITEM_CATEGORY_CLOTHIER,
    [ITEMTYPE_CLOTHIER_MATERIAL] = GAMEPAD_ITEM_CATEGORY_CLOTHIER,
    [ITEMTYPE_CLOTHIER_BOOSTER] = GAMEPAD_ITEM_CATEGORY_CLOTHIER,

    [ITEMTYPE_FOOD] = GAMEPAD_ITEM_CATEGORY_CONSUMABLE,
    [ITEMTYPE_DRINK] = GAMEPAD_ITEM_CATEGORY_CONSUMABLE,
    [ITEMTYPE_RECIPE] = GAMEPAD_ITEM_CATEGORY_CONSUMABLE,

    [ITEMTYPE_COSTUME] = GAMEPAD_ITEM_CATEGORY_COSTUME,

    [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = GAMEPAD_ITEM_CATEGORY_ENCHANTING,
    [ITEMTYPE_ENCHANTING_RUNE_ASPECT] = GAMEPAD_ITEM_CATEGORY_ENCHANTING,
    [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = GAMEPAD_ITEM_CATEGORY_ENCHANTING,

    [ITEMTYPE_GLYPH_WEAPON] = GAMEPAD_ITEM_CATEGORY_GLYPHS,
    [ITEMTYPE_GLYPH_ARMOR] = GAMEPAD_ITEM_CATEGORY_GLYPHS,
    [ITEMTYPE_GLYPH_JEWELRY] = GAMEPAD_ITEM_CATEGORY_GLYPHS,

    [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = GAMEPAD_ITEM_CATEGORY_JEWELRYCRAFTING,
    [ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = GAMEPAD_ITEM_CATEGORY_JEWELRYCRAFTING,
    [ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] = GAMEPAD_ITEM_CATEGORY_JEWELRYCRAFTING,
    [ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = GAMEPAD_ITEM_CATEGORY_JEWELRYCRAFTING,

    [ITEMTYPE_POTION] = GAMEPAD_ITEM_CATEGORY_POTION,

    [ITEMTYPE_INGREDIENT] = GAMEPAD_ITEM_CATEGORY_PROVISIONING,
    [ITEMTYPE_ADDITIVE] = GAMEPAD_ITEM_CATEGORY_PROVISIONING,
    [ITEMTYPE_SPICE] = GAMEPAD_ITEM_CATEGORY_PROVISIONING,
    [ITEMTYPE_FLAVORING] = GAMEPAD_ITEM_CATEGORY_PROVISIONING,

    [ITEMTYPE_SIEGE] = GAMEPAD_ITEM_CATEGORY_SIEGE,
    [ITEMTYPE_AVA_REPAIR] = GAMEPAD_ITEM_CATEGORY_SIEGE,

    [ITEMTYPE_RACIAL_STYLE_MOTIF] = GAMEPAD_ITEM_CATEGORY_STYLE_MATERIAL,
    [ITEMTYPE_STYLE_MATERIAL] = GAMEPAD_ITEM_CATEGORY_STYLE_MATERIAL,

    [ITEMTYPE_SOUL_GEM] = GAMEPAD_ITEM_CATEGORY_SOUL_GEM,

    [ITEMTYPE_LOCKPICK] = GAMEPAD_ITEM_CATEGORY_TOOL,
    [ITEMTYPE_TOOL] = GAMEPAD_ITEM_CATEGORY_TOOL,

    [ITEMTYPE_ARMOR_TRAIT] = GAMEPAD_ITEM_CATEGORY_TRAIT_ITEM,
    [ITEMTYPE_WEAPON_TRAIT] = GAMEPAD_ITEM_CATEGORY_TRAIT_ITEM,
    [ITEMTYPE_JEWELRY_RAW_TRAIT] = GAMEPAD_ITEM_CATEGORY_TRAIT_ITEM,
    [ITEMTYPE_JEWELRY_TRAIT] = GAMEPAD_ITEM_CATEGORY_TRAIT_ITEM,

    [ITEMTYPE_TROPHY] = GAMEPAD_ITEM_CATEGORY_TROPHY,

    [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = GAMEPAD_ITEM_CATEGORY_WOODWORKING,
    [ITEMTYPE_WOODWORKING_MATERIAL] = GAMEPAD_ITEM_CATEGORY_WOODWORKING,
    [ITEMTYPE_WOODWORKING_BOOSTER] = GAMEPAD_ITEM_CATEGORY_WOODWORKING,
}

local function GetCategoryFromItemType(itemType)
    -- This is not an exhaustive map: when we don't have a category we'll just use the raw itemtype instead.
    return ITEM_TYPE_TO_CATEGORY_MAP[itemType]
end

local WEAPON_TYPE_TO_CATEGORY_MAP = {
    [WEAPONTYPE_AXE] = GAMEPAD_ITEM_CATEGORY_AXE,
    [WEAPONTYPE_TWO_HANDED_AXE] = GAMEPAD_ITEM_CATEGORY_AXE,

    [WEAPONTYPE_BOW] = GAMEPAD_ITEM_CATEGORY_BOW,

    [WEAPONTYPE_DAGGER] = GAMEPAD_ITEM_CATEGORY_DAGGER,

    [WEAPONTYPE_HAMMER] = GAMEPAD_ITEM_CATEGORY_HAMMER,
    [WEAPONTYPE_TWO_HANDED_HAMMER] = GAMEPAD_ITEM_CATEGORY_HAMMER,

    [WEAPONTYPE_SHIELD] = GAMEPAD_ITEM_CATEGORY_SHIELD,

    [WEAPONTYPE_HEALING_STAFF] = GAMEPAD_ITEM_CATEGORY_STAFF,
    [WEAPONTYPE_FIRE_STAFF] = GAMEPAD_ITEM_CATEGORY_STAFF,
    [WEAPONTYPE_FROST_STAFF] = GAMEPAD_ITEM_CATEGORY_STAFF,
    [WEAPONTYPE_LIGHTNING_STAFF] = GAMEPAD_ITEM_CATEGORY_STAFF,

    [WEAPONTYPE_SWORD] = GAMEPAD_ITEM_CATEGORY_SWORD,
    [WEAPONTYPE_TWO_HANDED_SWORD] = GAMEPAD_ITEM_CATEGORY_SWORD,
}

local function GetCategoryFromWeapon(itemData)
    local weaponType
    if itemData.bagId and itemData.slotIndex then
        weaponType = GetItemWeaponType(itemData.bagId, itemData.slotIndex)
    else
        weaponType = GetItemLinkWeaponType(itemData.itemLink)
    end

    local category = WEAPON_TYPE_TO_CATEGORY_MAP[weaponType]
    internalassert(category)
    return category
end

local ARMOR_EQUIP_TYPE_TO_CATEGORY_MAP = {
    [EQUIP_TYPE_CHEST] = GAMEPAD_ITEM_CATEGORY_CHEST,
    [EQUIP_TYPE_FEET] = GAMEPAD_ITEM_CATEGORY_FEET,
    [EQUIP_TYPE_HAND] = GAMEPAD_ITEM_CATEGORY_HANDS,
    [EQUIP_TYPE_HEAD] = GAMEPAD_ITEM_CATEGORY_HEAD,
    [EQUIP_TYPE_LEGS] = GAMEPAD_ITEM_CATEGORY_LEGS,
    [EQUIP_TYPE_NECK] = GAMEPAD_ITEM_CATEGORY_AMULET,
    [EQUIP_TYPE_RING] = GAMEPAD_ITEM_CATEGORY_RING,
    [EQUIP_TYPE_SHOULDERS] = GAMEPAD_ITEM_CATEGORY_SHOULDERS,
    [EQUIP_TYPE_WAIST] = GAMEPAD_ITEM_CATEGORY_WAIST,
}

local function GetCategoryFromArmor(itemData)
    local category = ARMOR_EQUIP_TYPE_TO_CATEGORY_MAP[itemData.equipType]
    internalassert(category)
    return category
end

function ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription(itemData)
    local category = nil 

    if itemData.itemType == ITEMTYPE_WEAPON then
        category = GetCategoryFromWeapon(itemData)
    elseif itemData.itemType == ITEMTYPE_ARMOR then
        category = GetCategoryFromArmor(itemData)
    else
        category = GetCategoryFromItemType(itemData.itemType)
    end

    if category then
        return GetString("SI_GAMEPADITEMCATEGORY", category)
    end

    return zo_strformat(SI_INVENTORY_HEADER, GetString("SI_ITEMTYPE", itemData.itemType))
end

 --helper comparators
function ZO_InventoryUtils_DoesNewItemMatchFilterType(itemData, currentFilter)
    if not currentFilter then return true end

    for i, filter in ipairs(itemData.filterData) do
        if filter == currentFilter then
            return true
        end
    end
    return false
end

function ZO_InventoryUtils_DoesNewItemMatchSupplies(itemData)
    return itemData.equipType == EQUIP_TYPE_INVALID
            and not ZO_InventoryUtils_DoesNewItemMatchFilterType(itemData, ITEMFILTERTYPE_QUICKSLOT)
            and not ZO_InventoryUtils_DoesNewItemMatchFilterType(itemData, ITEMFILTERTYPE_CRAFTING)
            and not ZO_InventoryUtils_DoesNewItemMatchFilterType(itemData, ITEMFILTERTYPE_FURNISHING)
end

function ZO_InventoryUtils_UpdateTooltipEquippedIndicatorText(tooltipType, equipSlot, actorCategory)
    local isHidden, highestPriorityVisualLayerThatIsShowing = WouldEquipmentBeHidden(equipSlot or EQUIP_SLOT_NONE, actorCategory)
    local equipSlotText = ""

    if equipSlot == EQUIP_SLOT_MAIN_HAND then
        equipSlotText = GetString(SI_GAMEPAD_EQUIPPED_MAIN_HAND_ITEM_HEADER)
    elseif equipSlot == EQUIP_SLOT_BACKUP_MAIN then
        equipSlotText = GetString(SI_GAMEPAD_EQUIPPED_BACKUP_MAIN_ITEM_HEADER)
    elseif equipSlot == EQUIP_SLOT_OFF_HAND then
        equipSlotText = GetString(SI_GAMEPAD_EQUIPPED_OFF_HAND_ITEM_HEADER)
    elseif equipSlot == EQUIP_SLOT_BACKUP_OFF then
        equipSlotText = GetString(SI_GAMEPAD_EQUIPPED_BACKUP_OFF_ITEM_HEADER)
    end

    local equippedStringId = SI_GAMEPAD_EQUIPPED_ITEM_HEADER
    if actorCategory == GAMEPLAY_ACTOR_CATEGORY_COMPANION then
        equippedStringId = SI_GAMEPAD_EQUIPPED_COMPANION_ITEM_HEADER
    end

    if isHidden then
        GAMEPAD_TOOLTIPS:SetStatusLabelText(tooltipType, GetString(equippedStringId), equipSlotText, ZO_SELECTED_TEXT:Colorize(GetHiddenByStringForVisualLayer(highestPriorityVisualLayerThatIsShowing)))
    else
        GAMEPAD_TOOLTIPS:SetStatusLabelText(tooltipType, GetString(equippedStringId), equipSlotText)
    end
end