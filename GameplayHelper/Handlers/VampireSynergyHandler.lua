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

local BladeOfWoeIcon = "darkbrotherhood"
local DefaultSettings = {
    IsEnabled = true,
    SuppressBladeOfWoe = true,
    SuppressFeed = true,
    AlwaysFeedOnPlayers = true
}

local Name = "GameplayHelper_Handlers_VampireSynergyHandler"
local VampireFeedIcon = "vampire_synergy_feed"

-- Fields

local _isVampire
local _log
local _settings = DefaultSettings
local _vampireStage

-- Local functions

local function UpdateCheckboxLabels()
    if (_settings.IsEnabled and _settings.SuppressBladeOfWoe == true) then
        SuppressBladeOfWoeCheckbox.label:SetText(String.Format("Suppress {Blade of Woe} synergy"))
    else
        SuppressBladeOfWoeCheckbox.label:SetText("Suppress Blade of Woe synergy")
    end

    if (_settings.IsEnabled and _settings.SuppressFeed == true) then
        SuppressFeedCheckbox.label:SetText(String.Format("Suppress {Feed} synergy"))
    else
        SuppressFeedCheckbox.label:SetText("Suppress Feed synergy")
    end
end

local function CreateSettingsControls()
    local descriptionBuilder = StringBuilder.CreateInstance()
    descriptionBuilder:AppendLine("Suppress {Blade of Woe} synergy when vampirism is below stage {1}.")
    descriptionBuilder:Append("Suppress {Feed} synergy while at vampirism stage {1} or {2}.")
    local description = String.Format(descriptionBuilder:ToString(), 4, 5)

    local settingsControls = {
        {
            type = "description",
            text = description,
        },
        {
            type = "checkbox",
            name = "Enabled",
            getFunc = function() return _settings.IsEnabled end,
            setFunc = function(value)
                _settings.IsEnabled = value
                UpdateCheckboxLabels()
            end,
        },
        {
            type = "divider"
        },
        {
            type = "checkbox",
            name = "Suppress Blade of Woe synergy",
            getFunc = function() return _settings.SuppressBladeOfWoe end,
            setFunc = function(value)
                _settings.SuppressBladeOfWoe = value
                UpdateCheckboxLabels()
            end,
            disabled = function() return not _settings.IsEnabled end,
            reference = "SuppressBladeOfWoeCheckbox"
        },
        {
            type = "checkbox",
            name = "Suppress Feed synergy",
            getFunc = function() return _settings.SuppressFeed end,
            setFunc = function(value)
                _settings.SuppressFeed = value
                UpdateCheckboxLabels()
            end,
            disabled = function() return not _settings.IsEnabled end,
            reference = "SuppressFeedCheckbox"
        },
        {
            type = "checkbox",
            name = "Always enable feed on players",
            getFunc = function() return _settings.AlwaysFeedOnPlayers end,
            setFunc = function(value) _settings.AlwaysFeedOnPlayers = value end,
            disabled = function() return not _settings.IsEnabled or not _settings.SuppressFeed end
        }
    }

    return {
        DisplayName = String.Format("{Vampire:Red} synergy suppressor"),
        Controls = settingsControls
    }
end

local function UpdateSettingsUi()
    if (SuppressBladeOfWoeCheckbox == nil) then
        zo_callLater(function() UpdateSettingsUi() end, 500)
        return
    end

    UpdateCheckboxLabels()
end

local function OnSynergyChangedPreview(message)
    if (not _settings.IsEnabled) then
        return
    end

    if (not _isVampire) then
        return false
    end

    local isBladeOfWoeSynergy = string.find(message.SynergyInfo.IconFilename, BladeOfWoeIcon, 1, true)
    if (isBladeOfWoeSynergy) then
        if (not _settings.SuppressBladeOfWoe) then
            return
        end

        if (_vampireStage < 4) then
            _log:Debug("Blocking synergy {1} because vampire stage is {2}", message.SynergyInfo.SynergyName, _vampireStage)
            return true
        else
            return false
        end
    end

    local isVampireFeedSynergy = string.find(message.SynergyInfo.IconFilename, VampireFeedIcon, 1, true)
    if (isVampireFeedSynergy) then
        if (not _settings.SuppressFeed) then
            return
        end

        if (_settings.AlwaysFeedOnPlayers and IsUnitPlayer(UnitTag.ReticleOver)) then
            _log:Debug("Allowing synergy {1} because target is a player", message.SynergyInfo.SynergyName)
            return false
        end

        if (_vampireStage >= 4) then
            _log:Debug("Blocking synergy {1} because vampire stage is {2}", message.SynergyInfo.SynergyName, _vampireStage)
            return true
        else
            return false
        end
    end

    return false
end

local function OnVampireStatusChanged(message)
    _isVampire = message.IsVampire
    _vampireStage = message.Stage
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _log = Log.CreateInstance(Name)

    Messenger.Subscribe(FrameworkMessageType.SettingsControlsRequest, CreateSettingsControls)
    Messenger.Subscribe(FrameworkMessageType.SettingsShown, function() UpdateSettingsUi() end)
    Messenger.Subscribe(AddonMessageType.SynergyChangedPreview, OnSynergyChangedPreview)
    Messenger.Subscribe(AddonMessageType.VampireStatusChanged, OnVampireStatusChanged)

    _settings = Storage.GetEntry(Name, DefaultSettings, StorageScope.Account)
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)