--#region Usings

--#region Framework usings
---@type Array
local Array = EsoAddonFramework_Framework_Array
---@type Color
local Color = EsoAddonFramework_Framework_Color
---@type Console
local Console = EsoAddonFramework_Framework_Console
---@type Event
local Event = EsoAddonFramework_Framework_Eso_Event
---@type EventManager
local EventManager = EsoAddonFramework_Framework_Eso_EventManager
---@type FrameworkMessageType
local FrameworkMessageType = EsoAddonFramework_Framework_MessageType
---@type Log
local Log = EsoAddonFramework_Framework_Log
---@type LogLevel
local LogLevel = EsoAddonFramework_Framework_LogLevel
---@type Map
local Map = EsoAddonFramework_Framework_Map
---@type Messenger
local Messenger = EsoAddonFramework_Framework_Messenger
---@type Pack
local Pack = EsoAddonFramework_Framework_Eso_Pack
---@type Storage
local Storage = EsoAddonFramework_Framework_Storage
---@type StorageScope
local StorageScope = EsoAddonFramework_Framework_StorageScope
---@type String
local String = EsoAddonFramework_Framework_String
---@type StringBuilder
local StringBuilder = EsoAddonFramework_Framework_StringBuilder
---@type Type
local Type = EsoAddonFramework_Framework_Eso_Type
---@type UnitTag
local UnitTag = EsoAddonFramework_Framework_Eso_UnitTag
--#endregion

--#region Addon usings
---@type AddonMessageType
local AddonMessageType = GameplayHelper_Types_MessageType
---@type ItemAssessment
local ItemAssessment = GameplayHelper_Types_ItemAssessment
---@type ItemAssessmentManager
local ItemAssessmentManager = GameplayHelper_Globals_ItemAssessmentManager
---@type ItemAssessmentFilter
local ItemAssessmentFilter = GameplayHelper_Types_ItemAssessmentFilter
local Lang = GameplayHelper_Lang
---@type UnitManager
local Unit = GameplayHelper_Globals_UnitManager
--#endregion

--#endregion

-- Constants

local DefaultSettings = {
    IsEnabled = true
}

LaunderItemType = {
    Ingredient = ITEMTYPE_INGREDIENT,
    Recipe = ITEMTYPE_RECIPE,
    StyleMaterial = ITEMTYPE_STYLE_MATERIAL,
    Tool = ITEMTYPE_TOOL,
}

local Name = "GameplayHelper_Handlers_FenceHandler"

SellItemType = {
    Armor = ITEMTYPE_ARMOR,
    Treasure = ITEMTYPE_TREASURE,
}

-- Fields

local _log
local _settings = DefaultSettings

-- Local functions

local function CreateSettingsControls()
    local sellNames = Map.Keys(SellItemType)
    Array.Sort(sellNames)
    local sellString = String.Join(Array.Select(sellNames, function(value) return String.SetColor(value, Color.Green) end), ", ", " and ")

    local launderNames = Map.Keys(LaunderItemType)
    Array.Sort(launderNames)
    local launderString = String.Join(Array.Select(launderNames, function(value) return String.SetColor(value, Color.Green) end), ", ", " and ")

    local descriptionBuilder = StringBuilder.CreateInstance()
    descriptionBuilder:AppendLine("Automatically {sells} and {launders} items at fences.")
    descriptionBuilder:AppendLine("Item types sold:")
    descriptionBuilder:AppendLine("    " .. sellString)
    descriptionBuilder:AppendLine("Item types laundered:")
    descriptionBuilder:Append("    " .. launderString)
    local description = String.Format(descriptionBuilder:ToString())

    local settingsControls = {
        {
            type = "description",
            text = description
        },
        {
            type = "checkbox",
            name = "Enabled",
            getFunc = function() return _settings.IsEnabled end,
            setFunc = function(value) _settings.IsEnabled = value end
        }
    }

    return {
        DisplayName = "Fence automation",
        Controls = settingsControls
    }
end

local function FenceStolenGoods(bagId, sell, launder)
    local sellInfo = Pack.GetFenceSellTransactionInfo()
    local availableSellCount = sellInfo.TotalSells - sellInfo.SellsUsed
    local launderInfo = Pack.GetFenceLaunderTransactionInfo()
    local availableLaunderCount = launderInfo.TotalLaunders - launderInfo.LaundersUsed

    local totalSlotCount = GetBagSize(bagId)
    for slotIndex = 0, totalSlotCount - 1 do
        local itemLink = GetItemLink(bagId, slotIndex, Type.LinkStyle.Brackets)
        if (itemLink ~= "" and IsItemLinkStolen(itemLink)) then
            local itemType = GetItemLinkItemType(itemLink)
            if (Array.Any(Map.Values(SellItemType), function(value) return value == itemType end)) then
                if (sell and availableSellCount > 0) then
                    local slotCount = GetSlotStackSize(bagId, slotIndex)
                    local sellCount = math.min(availableSellCount, slotCount)
                    _log:Debug("Sell {1} x{2}", itemLink, sellCount)
                    SellInventoryItem(bagId, slotIndex, sellCount)
                    availableSellCount = availableSellCount - sellCount
                end
            elseif (Array.Any(Map.Values(LaunderItemType), function(value) return value == itemType end)) then
                if (launder and availableLaunderCount > 0) then
                    local slotCount = GetSlotStackSize(bagId, slotIndex)
                    local launderCount = math.min(availableLaunderCount, slotCount)
                    _log:Debug("Launder {1} x{2}", itemLink, launderCount)
                    LaunderItem(bagId, slotIndex, launderCount)
                    availableLaunderCount = availableLaunderCount - launderCount
                end
            else
                _log:Warning("{1} had unsupported type {2}", itemLink, Map.GetKey(Type.ItemType, itemType))
            end
        end
    end
end

local function OnOpenFence(event, allowSell, allowLaunder)
    if (not _settings.IsEnabled) then
        return
    end

    if (not allowSell and not allowLaunder) then
        return
    end

    FenceStolenGoods(Type.Bag.Backpack, allowSell, allowLaunder)
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _log = Log.CreateInstance(Name)

    EventManager:RegisterForEvent(Name, Event.OpenFence, OnOpenFence)

    Messenger.Subscribe(FrameworkMessageType.SettingsControlsRequest, CreateSettingsControls)

    _settings = Storage.GetEntry(Name, DefaultSettings, StorageScope.Account)
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)