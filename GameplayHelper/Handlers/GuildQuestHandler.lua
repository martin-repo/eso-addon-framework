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

local Name = "GameplayHelper_Handlers_GuildQuestHandler"
local SpreeQuestName = "Spree"
local ZoneIndices = {
    DarkBrotherhoodSanctuary = 451,
    ThievesDen = 447
}

-- Fields

local _log
local _settings = DefaultSettings

-- Local functions

local function AbandonQuestIfNotGuildSpree(journalQuestIndex)
    local journalQuestInfo = Pack.GetJournalQuestInfo(journalQuestIndex)

    local playerZoneIndex = GetUnitZoneIndex(UnitTag.Player)
    local playerZoneName = GetZoneNameByIndex(playerZoneIndex)

    if (Map.All(ZoneIndices, function(zoneName, zoneIndex) return zoneIndex ~= playerZoneIndex end)) then
        _log:Debug("Keeping quest {1} because player is in an invalid zone; {2} ({3})", journalQuestInfo.QuestName, playerZoneName, playerZoneIndex)
        return
    end

    local repeatType = GetJournalQuestRepeatType(journalQuestIndex)
    if (repeatType ~= Type.QuestRepeatableType.Repeatable) then
        _log:Debug("Keeping quest {1} because it is not repeatable", journalQuestInfo.QuestName)
        return
    end

    if (journalQuestInfo.QuestType ~= Type.QuestType.Guild) then
        _log:Debug("Keeping quest {1} because it is not a guild quest", journalQuestInfo.QuestName)
        return
    end

    local isSpreeQuest = string.find(journalQuestInfo.QuestName, SpreeQuestName, 1, true)
    if (isSpreeQuest) then
        _log:Debug("Spree quest {1} accepted in the {2}", journalQuestInfo.QuestName, playerZoneName)
        return
    end

    Console.Write(String.Format("Abandoning quest {1} because it is not a spree quest", journalQuestInfo.QuestName))
    AbandonQuest(journalQuestIndex)
end

local function CreateSettingsControls()
    local descriptionBuilder = StringBuilder.CreateInstance()
    descriptionBuilder:AppendLine("Inspects new quests in the {Thieves Den} and the {Dark Brotherhood Sanctuary}.")
    descriptionBuilder:Append("If it is not a {spree} quest, then it will be automatically abandoned.")
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
        DisplayName = "Guild quest observer",
        Controls = settingsControls
    }
end

local function OnQuestAdded(event, journalQuestIndex, questName, objectiveName)
    if (not _settings.IsEnabled) then
        return
    end

    AbandonQuestIfNotGuildSpree(journalQuestIndex)
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _log = Log.CreateInstance(Name)

    EventManager:RegisterForEvent(Name, Event.QuestAdded, OnQuestAdded)

    Messenger.Subscribe(FrameworkMessageType.SettingsControlsRequest, CreateSettingsControls)

    _settings = Storage.GetEntry(Name, DefaultSettings, StorageScope.Account)
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)