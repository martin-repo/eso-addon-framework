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

local Name = "GameplayHelper_Handlers_StoreHandler"

-- Fields

local _log
local _settings = DefaultSettings

-- Local functions

local function CreateSettingsControls()
    local settingsControls = {
        {
            type = "description",
            text = String.Format("Automatically {sells} and {destroys:Red} items at stores. Uses {Item assessment:Blue} rules.")
        },
        {
            type = "checkbox",
            name = "Enabled",
            getFunc = function() return _settings.IsEnabled end,
            setFunc = function(value) _settings.IsEnabled = value end
        }
    }

    return {
        DisplayName = "Store automation",
        Controls = settingsControls
    }
end

local function SellOrDestroy(bagId, slotIndex, itemLink)
    local count = GetSlotStackSize(bagId, slotIndex)

    if (GetItemSellInformation(bagId, slotIndex) == Type.ItemSellInformation.CannotSell) then
        _log:Debug("Destroy {1} x{2}", itemLink, count)
        DestroyItem(bagId, slotIndex)
        return
    end

    _log:Debug("Sell {1} x{2}", itemLink, count)
    SellInventoryItem(bagId, slotIndex, count)
end

local function OnOpenStore(event)
    if (not _settings.IsEnabled) then
        return
    end

    local bagId = Type.Bag.Backpack
    local totalSlotCount = GetBagSize(bagId)
    for slotIndex = 0, totalSlotCount - 1 do
        local itemLink = GetItemLink(bagId, slotIndex, Type.LinkStyle.Brackets)
        if (itemLink ~= "" and
            not IsItemLinkStolen(itemLink) and
            not IsItemPlayerLocked(bagId, slotIndex)) then
            local itemAssessment = ItemAssessmentManager.AssessItem(itemLink)
            if (itemAssessment == ItemAssessment.Dispose) then
                SellOrDestroy(bagId, slotIndex, itemLink)
            end
        end
    end
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _log = Log.CreateInstance(Name)

    _settings = Storage.GetEntry(Name, DefaultSettings, StorageScope.Account)

    Messenger.Subscribe(FrameworkMessageType.SettingsControlsRequest, CreateSettingsControls)

    EventManager:RegisterForEvent(Name, Event.OpenStore, OnOpenStore)
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)