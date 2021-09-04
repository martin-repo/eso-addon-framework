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

local FirstAbilitySlotIndex = Type.Globals.ActionBarFirstNormalSlotIndex + 1 -- SlotIndex is zero-based, GetSlotBoundId(...) is one-based
local DefaultSettings = {
    IsEnabled = true,
    AbilitySlotIndex = FirstAbilitySlotIndex,
    SwapDuration = 5
}

local LastAbilitySlotIndex = Type.Globals.ActionBarUltimateSlotIndex -- Will equal the last ability slot as one-base
local MesmerizeAbilityIds = {
    Mesmerize = 128709,
    Hypnosis = 137861,
    Stupefy = 138097
}

local Name = "GamepadHelper_Handlers_VampireNpcHandler"
local VampireSkillLineIndex = 5

-- Fields

local _log
local _originalAbility
local _settings = DefaultSettings
local _waitId
local _waitInProgress = false

-- Local functions

local function CreateSettingsControls()
    local descriptionBuilder = StringBuilder.CreateInstance()
    descriptionBuilder:Append("When an NPCs reject interaction due to the player being a {vampire:Red} at stage {1}, ")
    descriptionBuilder:Append("the {Mesmerize} skill (or one of its morphs) will be slotted.")
    local description = String.Format(descriptionBuilder:ToString(), 4)

    local settingsControls = {
        {
            type = "description",
            text = description
        },
        {
            type = "checkbox",
            name = "Enabled",
            getFunc = function() return _settings.IsEnabled end,
            setFunc = function(value) _settings.IsEnabled = value end,
        },
        {
            type = "divider"
        },
        {
            type = "dropdown",
            name = "Skill slot",
            choices = {"1", "2", "3", "4", "5"},
            getFunc = function() return tostring(_settings.AbilitySlotIndex - Type.Globals.ActionBarFirstNormalSlotIndex) end,
            setFunc = function(value) _settings.AbilitySlotIndex = tonumber(value) + Type.Globals.ActionBarFirstNormalSlotIndex end,
            disabled = function() return not _settings.IsEnabled end
        },
        {
            type = "slider",
            name = "Mesmerize duration",
            tooltip = "Restores original skill after this amount of seconds",
            min = 1,
            max = 10,
            getFunc = function() return _settings.SwapDuration end,
            setFunc = function(value) _settings.SwapDuration = value end,
            disabled = function() return not _settings.IsEnabled end
        },
    }

    return {
        DisplayName = String.Format("{Vampire:Red} NPC mesmerizer"),
        Controls = settingsControls
    }
end

local function GetMesmerizeInfo()
    local abilityCount = GetNumSkillAbilities(Type.SkillType.World, VampireSkillLineIndex)
    for abilityIndex = 1, abilityCount do
        local abilityId = GetSkillAbilityId(Type.SkillType.World, VampireSkillLineIndex, abilityIndex, false)
        for _, value in pairs(MesmerizeAbilityIds) do
            if (abilityId == value) then
                local abilityInfo = Pack.GetSkillAbilityInfo(Type.SkillType.World, VampireSkillLineIndex, abilityIndex)

                _log:Debug("{1} found", abilityInfo.Name)

                return {
                    AbilityInfo = abilityInfo,
                    SkillType = Type.SkillType.World,
                    SkillLineIndex = VampireSkillLineIndex,
                    AbilityIndex = abilityIndex
                }
            end
        end
    end

    return nil
end

local function GetSlotAbilityInfo(abilitySlotIndex)
    local abilityId = GetSlotBoundId(abilitySlotIndex)
    if (abilityId == nil) then
        return nil
    end

    local name = GetAbilityName(abilityId)
    local ability = Pack.GetSpecificSkillAbilityKeysByAbilityId(abilityId)

    return {
        Name = name,
        SkillType = ability.SkillType,
        SkillLineIndex = ability.SkillLineIndex,
        AbilityIndex = ability.SkillIndex,
        AbilitySlotIndex = abilitySlotIndex
    }
end

local function IsMesmerizeSlotted()
    for abilitySlotIndex = FirstAbilitySlotIndex, LastAbilitySlotIndex do
        local abilityId = GetSlotBoundId(abilitySlotIndex)
        if (abilityId ~= nil) then
            for _, value in pairs(MesmerizeAbilityIds) do
                if (abilityId == value) then
                    return true
                end
            end
        end
    end

    return false
end

local function RestoreOriginalAbility()
    if (_originalAbility == nil) then
        return
    end

    _log:Debug("Slotting skill {1} in slot {2}", _originalAbility.Name, _originalAbility.AbilitySlotIndex)
    SlotSkillAbilityInSlot(
        _originalAbility.SkillType,
        _originalAbility.SkillLineIndex,
        _originalAbility.AbilityIndex,
        _originalAbility.AbilitySlotIndex)

    _waitInProgress = false
    _originalAbility = nil
end

local function TempSwapMesmerizeAbility()
    local isMesmerizeSlotted = IsMesmerizeSlotted()
    if (isMesmerizeSlotted) then
        _log:Debug("Mesmerize is already slotted")
        return
    end

    local mesmerizeInfo = GetMesmerizeInfo()
    if (mesmerizeInfo == nil) then
        _log:Debug("Mesmerize was not found")
        return
    end

    if (not mesmerizeInfo.AbilityInfo.Purchased) then
        _log:Debug("Mesmerize is not purchased")
        return
    end

    _originalAbility = GetSlotAbilityInfo(_settings.AbilitySlotIndex)

    _log:Debug("Slotting skill {1} in slot {2}", mesmerizeInfo.AbilityInfo.Name, _settings.AbilitySlotIndex)
    SlotSkillAbilityInSlot(mesmerizeInfo.SkillType, mesmerizeInfo.SkillLineIndex, mesmerizeInfo.AbilityIndex, _settings.AbilitySlotIndex)

    if (_originalAbility == nil) then
        return
    end

    local swapDuration = _settings.SwapDuration * 1000
    _log:Debug("Waiting for {1} milliseconds", swapDuration)
    _waitInProgress = true
    _waitId = zo_callLater(RestoreOriginalAbility, swapDuration)
end

local function OnActionSlotAbilityUsed(event, actionSlotIndex)
    if (not _waitInProgress) then
        return
    end

    if (actionSlotIndex ~= _settings.AbilitySlotIndex) then
        return
    end

    _log:Debug("Wait cancelled; player used Mesmerize skill")
    zo_removeCallLater(_waitId)

    -- Wait a short duration, otherwise the skill doesn't seem to activate properly
    zo_callLater(RestoreOriginalAbility, 500)
end

local function OnClientInteractResult(event, result, interactTargetName)
    if result ~= Type.ClientInteractResult.FearfulVampire then
        return
    end

    local interactResult = Map.GetKey(Type.ClientInteractResult, result)
    _log:Debug("NPC {1} rejected interaction; reason {2}", interactTargetName, interactResult)
    TempSwapMesmerizeAbility()
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _log = Log.CreateInstance(Name)

    EventManager:RegisterForEvent(Name, Event.ClientInteractResult, OnClientInteractResult)
    EventManager:RegisterForEvent(Name, Event.ActionSlotAbilityUsed, OnActionSlotAbilityUsed)

    Messenger.Subscribe(FrameworkMessageType.SettingsControlsRequest, CreateSettingsControls)

    _settings = Storage.GetEntry(Name, DefaultSettings, StorageScope.Account)
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)