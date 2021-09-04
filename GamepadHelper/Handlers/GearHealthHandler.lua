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
local AddonMessageType = GamepadHelper_Types_MessageType
---@type ItemAssessment
local ItemAssessment = GamepadHelper_Types_ItemAssessment
---@type ItemAssessmentManager
local ItemAssessmentManager = GamepadHelper_Globals_ItemAssessmentManager
---@type ItemAssessmentFilter
local ItemAssessmentFilter = GamepadHelper_Types_ItemAssessmentFilter
local Lang = GamepadHelper_Lang
---@type UnitManager
local Unit = GamepadHelper_Globals_UnitManager
--#endregion

--#endregion

-- Constants

local DefaultSettings = {
    IsEnabled = true
}

local Name = "GamepadHelper_Handlers_GearHealthHandler"

-- Fields

local _log
local _settings = DefaultSettings

-- Local functions

local function CreateSettingsControls()
    local descriptionBuilder = StringBuilder.CreateInstance()
    descriptionBuilder:AppendLine("{Repairs} all gear at stores.")
    descriptionBuilder:Append("{Recharges} weapons when they run out of charges.")
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
        DisplayName = "Gear health automation",
        Controls = settingsControls
    }
end

local function GetSoulGemSlotIndex(bagId)
    local totalSlotCount = GetBagSize(bagId)
    for slotIndex = 0, totalSlotCount - 1 do
        local itemType = GetItemType(bagId, slotIndex)
        if (itemType == Type.ItemType.SoulGem) then
            return slotIndex
        end
    end

    return nil
end

local function RechargeWeaponIfNeeded(bagId, slotIndex)
    local chargeInfo = Pack.GetChargeInfoForItem(bagId, slotIndex)
    if (chargeInfo.Charges > 0) then
        return
    end

    local soulGemSlotIndex = GetSoulGemSlotIndex(Type.Bag.Backpack)
    if (soulGemSlotIndex == nil) then
        return
    end

    ChargeItemWithSoulGem(bagId, slotIndex, Type.Bag.Backpack, soulGemSlotIndex)

    local itemLink = GetItemLink(bagId, slotIndex, Type.LinkStyle.Brackets)
    _log:Debug("Weapon {1} recharged", itemLink)
end

local function OnInventorySingleSlotUpdate(event, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage)
    RechargeWeaponIfNeeded(bagId, slotId)
end

local function OnOpenStore(event)
    if (not CanStoreRepair()) then
        _log:Debug("Store does not offer repairs")
        return
    end

    local cost = GetRepairAllCost()
    if (cost == 0) then
        _log:Debug("Gear is already at full health")
        return
    end

    local balance = GetCurrencyAmount(Type.CurrencyType.Money, Type.CurrencyLocation.Character)
    if (balance < cost) then
        _log:Debug("Not enough money for repairs")
    end

    _log:Debug("Repairing all gear")
    RepairAll()
end

local function RechargeWornWeapons()
    if (IsUnitDead(UnitTag.Player)) then
        return
    end

    local bagId = Type.Bag.Worn
    local totalSlotCount = GetBagSize(bagId)
    for slotIndex = 0, totalSlotCount - 1 do
        local itemType = GetItemType(bagId, slotIndex)
        if (itemType == Type.ItemType.Weapon) then
            RechargeWeaponIfNeeded(bagId, slotIndex)
        end
    end
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _log = Log.CreateInstance(Name)

    EventManager:RegisterForEvent(Name, Event.OpenStore, OnOpenStore)
    EventManager:RegisterForEvent(Name, Event.ActiveWeaponPairChanged, function(...) RechargeWornWeapons() end)
    EventManager:RegisterForEvent(Name, Event.InventorySingleSlotUpdate, OnInventorySingleSlotUpdate)
	EventManager:AddFilterForEvent(Name, Event.InventorySingleSlotUpdate, Type.RegisterForEventFilterType.InventoryUpdateReason, Type.InventoryUpdateReason.ItemCharge)
	EventManager:AddFilterForEvent(Name, Event.InventorySingleSlotUpdate, Type.RegisterForEventFilterType.BagId, Type.Bag.Worn)

    Messenger.Subscribe(FrameworkMessageType.InitialActivation, function() RechargeWornWeapons() end)
    Messenger.Subscribe(FrameworkMessageType.SettingsControlsRequest, CreateSettingsControls)

    _settings = Storage.GetEntry(Name, DefaultSettings, StorageScope.Account)
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)