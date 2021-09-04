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
    IsEnabled = true,
    NodeTravelCount = { },
    SellValue = 0,
    ZoneDeaths = { }
}

local NegativeZoneAdjectives = {
    "bleak",
    "boring",
    "damp",
    "depressing",
    "dismal",
    "dull",
    "dreary",
    "glum",
    "horrible",
    "miserable",
    "stupid",
    "wretched"
}

local Name = "GamepadHelper_Handlers_StatisticsHandler"

local PositiveZoneAdjectives = {
    "amazing",
    "awesome",
    "beautiful",
    "elegant",
    "fascinating",
    "gorgeous",
    "incredible",
    "impressive",
    "magnificent",
    "stunning",
    "superb",
    "wonderful"
}

-- Fields

local _currentWayshrine
local _fastTravel
local _log
local _settings = DefaultSettings
local _totalSellValue

-- Local functions

local function CreateSettingsControls()
    local settingsControls = {
        {
            type = "description",
            text = String.Format("Collects and displays {statistics} about the player's journey throughout {Tamriel:Yellow}.")
        },
        {
            type = "checkbox",
            name = "Enabled",
            getFunc = function() return _settings.IsEnabled end,
            setFunc = function(value) _settings.IsEnabled = value end
        }
    }

    return {
        DisplayName = "Statistics",
        Controls = settingsControls
    }
end

local function OnOpenFence(event, allowSell, allowLaunder)
    _totalSellValue = 0
end

local function OnEndFastTravelInteraction(event)
    _currentWayshrine = nil
end

local function OnStartFastTravelInteraction(event, nodeIndex)
    local nodeInfo = Pack.GetFastTravelNodeInfo(nodeIndex)
    if (nodeInfo.PoiType ~= Type.PointOfInterestType.Wayshrine) then
        return
    end

    _currentWayshrine = nodeIndex
end

local function OnPlayerDead(event)
    if (not _settings.IsEnabled) then
        return
    end

    local zoneIndex = GetUnitZoneIndex(UnitTag.Player)
    if (_settings.ZoneDeaths[zoneIndex] == nil) then
        _settings.ZoneDeaths[zoneIndex] = 0
    end

    _settings.ZoneDeaths[zoneIndex] = _settings.ZoneDeaths[zoneIndex] + 1

    local countString = zo_strformat("<<i:1>>", _settings.ZoneDeaths[zoneIndex])
    local adjective = NegativeZoneAdjectives[math.random(#NegativeZoneAdjectives)]
    local zoneName = GetZoneNameByIndex(zoneIndex)
    Console.Write(String.Format("Died for the {1:Blue} time in {2:None} {3}", countString, adjective, zoneName))
end

local function OnSellReceipt(event, itemName, itemQuantity, money)
    if (not _settings.IsEnabled) then
        return
    end

    _totalSellValue = _totalSellValue + money
end

local function OnOpenStore(event)
    _totalSellValue = 0
end

local function OnCloseStore(event)
    if (not _settings.IsEnabled) then
        return
    end

    if (_totalSellValue == 0) then
        return
    end

    _settings.SellValue = _settings.SellValue + _totalSellValue

    Console.Write(String.Format("{1} gold gained at stores", _settings.SellValue))
end

local function OnFastTravelComplete()
    if (_fastTravel == nil) then
        return
    end

    if (_settings.NodeTravelCount[_fastTravel.DestinationNode] == nil) then
        _settings.NodeTravelCount[_fastTravel.DestinationNode] = 0
    end

    _settings.NodeTravelCount[_fastTravel.DestinationNode] = _settings.NodeTravelCount[_fastTravel.DestinationNode] + 1

    local countString = zo_strformat("<<i:1>>", _settings.NodeTravelCount[_fastTravel.DestinationNode])

    local nodeInfo = Pack.GetFastTravelNodeInfo(_fastTravel.DestinationNode)

    local adjective = PositiveZoneAdjectives[math.random(#PositiveZoneAdjectives)]

    local nodeIndices = Pack.GetFastTravelNodePOIIndicies(_fastTravel.DestinationNode)
    local nodeZoneName = GetZoneNameByIndex(nodeIndices.ZoneIndex)

    Console.Write(String.Format("Arriving for the {1:Blue} time at {2} in {3:None} {4}", countString, nodeInfo.Name, adjective, nodeZoneName))
end

local function OnMoneyUpdate(event, newMoney, oldMoney, reason, reasonSupplementaryInfo)
    if (not _settings.IsEnabled) then
        return
    end

    if (reason == Type.CurrencyChangeReason.TravelGraveyard) then
        OnFastTravelComplete()
    end
end

local function OnFastTravelToNode(nodeIndex)
    if (not _settings.IsEnabled) then
        _fastTravel = nil
        return
    end

    local nodeInfo = Pack.GetFastTravelNodeInfo(nodeIndex)
    if (nodeInfo.PoiType ~= Type.PointOfInterestType.Wayshrine) then
        _fastTravel = nil
        return
    end

    _fastTravel = {
        OriginZoneName = GetPlayerActiveZoneName(),
        OriginSubZoneName = GetPlayerActiveSubzoneName(),
        DestinationNode = nodeIndex
    }

    if (_currentWayshrine == nil) then
        return
    end

    _fastTravel.OriginNode = _currentWayshrine
    OnFastTravelComplete()
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _log = Log.CreateInstance(Name)

    EventManager:RegisterForEvent(Name, Event.OpenFence, OnOpenFence)
    EventManager:RegisterForEvent(Name, Event.OpenStore, OnOpenStore)
    EventManager:RegisterForEvent(Name, Event.SellReceipt, OnSellReceipt)
    EventManager:RegisterForEvent(Name, Event.CloseStore, OnCloseStore)

    EventManager:RegisterForEvent(Name, Event.StartFastTravelInteraction, OnStartFastTravelInteraction)
    EventManager:RegisterForEvent(Name, Event.EndFastTravelInteraction, OnEndFastTravelInteraction)
    EventManager:RegisterForEvent(Name, Event.MoneyUpdate, OnMoneyUpdate)

    EventManager:RegisterForEvent(Name, Event.PlayerDead, OnPlayerDead)

    ZO_PostHook("FastTravelToNode", OnFastTravelToNode)

    Messenger.Subscribe(FrameworkMessageType.SettingsControlsRequest, CreateSettingsControls)

    _settings = Storage.GetEntry(Name, DefaultSettings, StorageScope.Account)
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)