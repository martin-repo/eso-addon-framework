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
    OutputSuppressions = true
}

local MirriAdjectives = {
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

local MirriCompanionId = 2
local MirriName = "Mirri"
local MirriVerbs = {
    "admires",
    "beholds",
    "inspects",
    "is crazy about",
    "looks at",
    "marvels at",
    "observes",
    "studies",
    "watches"
}

local Name = "GameplayHelper_Handlers_MirriHandler"

-- Fields

local _companionName
local _log
local _mirriActivated = false
local _settings = DefaultSettings

-- Local functions

local function CreateSettingsControls()
    local descriptionBuilder = StringBuilder.CreateInstance()
    descriptionBuilder:AppendLine("Suppresses some interactions and synergies when {Mirri} is active.")
    descriptionBuilder:AppendLine("Suppressed interactions:")
    descriptionBuilder:AppendLine("    - " .. "{butterflies}")
    descriptionBuilder:AppendLine("    - " .. "{torch bugs}")
    descriptionBuilder:AppendLine("    - " .. "{navigators}")
    descriptionBuilder:AppendLine("    - " .. "the {Dark Brotherhood Sanctuary}")
    descriptionBuilder:AppendLine("Suppressed synergies:")
    descriptionBuilder:Append("    - " .. "{Blade of Woe}")
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
        },
        {
            type = "divider"
        },
        {
            type = "checkbox",
            name = "Output suppressions to chat",
            tooltip = "Outputs why an interaction was suppressed to the chat window",
            getFunc = function() return _settings.OutputSuppressions end,
            setFunc = function(value) _settings.OutputSuppressions = value end,
            disabled = function() return not _settings.IsEnabled end
        }
    }

    return {
        DisplayName = "Mirri suppressor",
        Controls = settingsControls
    }
end

local function EndConversationIfNavigator()
    if (not IsInteractionPending() and
        not IsInteracting())
    then
        return
    end

    if (IsInteractionPending()) then
        zo_callLater(EndConversationIfNavigator, 100)
        return
    end

    local name = GetUnitName(UnitTag.Interact)
    local caption = GetUnitCaption(UnitTag.Interact)
    local isNavigator = caption ~= nil and caption:lower() == "navigator"
    if (isNavigator) then
        local interactionType = GetInteractionType()
        EndInteraction(interactionType)

        if (_settings.OutputSuppressions) then
            Console.Write(String.Format("{1} does not want to travel with {2}", MirriName, name))
        end
    end

    _log:Debug("Interaction with {1} approved", name)
end

local function OnClientInteractResult(event, result, interactTargetName)
    if (not _settings.IsEnabled or not _mirriActivated) then
        return false
    end

    if (result ~= Type.ClientInteractResult.Success) then
        return
    end

    EndConversationIfNavigator()
end

local function OnCompanionActivated(event, companionId)
    local companionNameInfo = Unit.GetNameInfo(UnitTag.Companion)

    if (companionId ~= MirriCompanionId) then
        _log:Debug("Non-Mirri companion {1} [{2}] activated", companionNameInfo.Name, companionId)
        return
    end

    _log:Debug("{1} activated", companionNameInfo.Name)
    _mirriActivated = true
    _companionName = companionNameInfo.Name
    Messenger.Publish(AddonMessageType.InteractionCriteriaChanged)
end

local function OnCompanionDeactivated(event)
    _log:Debug("{1} deactivated", _companionName)

    if (_mirriActivated) then
        _mirriActivated = false
        Messenger.Publish(AddonMessageType.InteractionCriteriaChanged)
    end
end

local function OnInteractionChangedPreview(message)
    if (not _settings.IsEnabled or not _mirriActivated) then
        return
    end

    if (message.ActionInfo.Name == "Torchbug" or
        message.ActionInfo.Name == "Butterfly") then
        if (_settings.OutputSuppressions) then
            Console.Write(String.Format(
                "{1} {2:None} the {3:None} {4}",
                MirriName,
                MirriVerbs[math.random(#MirriVerbs)],
                MirriAdjectives[math.random(#MirriAdjectives)],
                message.ActionInfo.Name))
        end

        _log:Debug("Suppressing interaction {1}", message.ActionInfo.Name)
        return true
    end

    if (message.ActionInfo.Name == "Dark Brotherhood Sanctuary") then
        if (_settings.OutputSuppressions) then
            Console.Write(String.Format("{1} refuses to enter the {2}", MirriName, message.ActionInfo.Name))
        end

        _log:Debug("Suppressing interaction {1}", message.ActionInfo.Name)
        return true
    end
end

local function OnSynergyChangedPreview(message)
    if (not _settings.IsEnabled or not _mirriActivated) then
        return false
    end

    if (string.find(message.SynergyInfo.IconFilename, BladeOfWoeIcon, 1, true)) then
        if (_settings.OutputSuppressions) then
            Console.Write(String.Format("{1} cannot accept the use of {2}", MirriName, message.SynergyInfo.SynergyName))
        end

        _log:Debug("Suppressing synergy {1}", message.SynergyInfo.SynergyName)
        return true
    end
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _log = Log.CreateInstance(Name)

    if (HasActiveCompanion()) then
        local companionNameInfo = Unit.GetNameInfo(UnitTag.Companion)
        _companionName = companionNameInfo.Name

        local companionId = GetActiveCompanionDefId()
        if (companionId == MirriCompanionId) then
            _mirriActivated = true
        end
    end

    EventManager:RegisterForEvent(Name, Event.ClientInteractResult, OnClientInteractResult)
    EventManager:RegisterForEvent(Name, Event.CompanionActivated, OnCompanionActivated)
    EventManager:RegisterForEvent(Name, Event.CompanionDeactivated, OnCompanionDeactivated)

    Messenger.Subscribe(FrameworkMessageType.SettingsControlsRequest, CreateSettingsControls)
    Messenger.Subscribe(AddonMessageType.InteractionChangedPreview, OnInteractionChangedPreview)
    Messenger.Subscribe(AddonMessageType.SynergyChangedPreview, OnSynergyChangedPreview)

    _settings = Storage.GetEntry(Name, DefaultSettings, StorageScope.Account)
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)