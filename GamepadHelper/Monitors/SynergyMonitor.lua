--[[
    Monitors when a synergy is available.
    A preview message is sent (MessageType.SynergyChangedPreview) where subscribers can choose to suppress the synergy from showing in the UI.
    A second message is sent (MessageType.SynergyChanged) if the synergy was not suppressed.
]]

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

local Name = "GamepadHelper_Monitors_SynergyMonitor"

-- Fields

local _log
local _synergy = {
    Available = false,
    Suppressed = false,
}

-- Local functions

local function HandleSynergyLost()
    if (_synergy.Available) then
        _log:Debug("Synergy lost")
        _synergy.Available = false
        Messenger.Publish(AddonMessageType.SynergyChanged, { SynergyAvailable = false })
    end

    _synergy.Suppressed = false
end

local function OnSynergyAbilityChanged(eventCode)
    local synergyInfo = Pack.GetSynergyInfo()
    local synergyLost = not synergyInfo.SynergyName
    if (synergyLost) then
        -- Old synergy was handled in pre-hook function
        return
    end

    if (_synergy.Suppressed) then
        _log:Debug("Synergy {1} ignored since it has been suppressed", synergyInfo.SynergyName)
        return
    end

    _log:Debug("Synergy {1} available", synergyInfo.SynergyName)
    _synergy.Available = true
    Messenger.Publish(AddonMessageType.SynergyChanged, { SynergyAvailable = true, SynergyInfo = synergyInfo })
end

local function OnSynergyAbilityChangedPreHook()
    local synergyInfo = Pack.GetSynergyInfo()
    local synergyLost = not synergyInfo.SynergyName
    if (synergyLost) then
        HandleSynergyLost()
        return
    end

    -- If switching between synergies, handle the old one as lost
    HandleSynergyLost()

    _log:Debug("Synergy {1} pre-hook preview", synergyInfo.SynergyName)
    local suppressResponses = {
        Messenger.Publish(
            AddonMessageType.SynergyChangedPreview,
            { SynergyInfo = synergyInfo },
            function(suppress) return suppress == true end
        )
    }
    local suppress = Array.Any(suppressResponses, function(suppress) return suppress == true end)

    if (suppress) then
        _log:Debug("Synergy {1} suppressed", synergyInfo.SynergyName)
        _synergy.Suppressed = true
        return true
    end

    return false
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _log = Log.CreateInstance(Name)

    -- Use instance "SYNERGY" instead of class "ZO_Synergy"
    ZO_PreHook(SYNERGY, "OnSynergyAbilityChanged", OnSynergyAbilityChangedPreHook)

    EventManager:RegisterForEvent(Name, Event.SynergyAbilityChanged, OnSynergyAbilityChanged)
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)