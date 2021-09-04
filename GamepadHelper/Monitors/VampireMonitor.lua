--[[
    Monitors changes to a players vampire state or stage.
    A message is sent (MessageType.VampireStatusChanged) when there is any change.
    Listens to message (MessageType.VampireStatusRequest) where it will return the current status.
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

local BuffAbilityIds = {
    Stage1 = 135397,
    Stage2 = 135399,
    Stage3 = 135400,
    Stage4 = 135402,
    Stage5 = 135412
}

local Name = "GamepadHelper_Monitors_VampireMonitor"
local BuffStage = {
    Stage1 = 1,
    Stage2 = 2,
    Stage3 = 3,
    Stage4 = 4,
    Stage5 = 5
}

-- Fields

local _log
local _status = {
    IsVampire = false,
    Stage = 0,
    StageEnding = 0
}

-- Local functions

local function IsVampireEffect(abilityId)
    for _, buffAbilityId in pairs(BuffAbilityIds) do
        if (abilityId == buffAbilityId) then
            return true
        end
    end

    return false
end

local function GetVampireBuff()
    local buffCount = GetNumBuffs(UnitTag.Player)
    _log:Debug("Player has {1} buff(s)", buffCount)

    if (buffCount == 0) then
        return nil
    end

    for buffIndex = 1, buffCount do
        local buffInfo = Pack.GetUnitBuffInfo(UnitTag.Player, buffIndex)

        if (IsVampireEffect(buffInfo.AbilityId)) then
            _log:Debug("Player has buff {1}", buffInfo.BuffName)
            return buffInfo
        end
    end

    _log:Debug("Player does not have vampire buff")
    return nil
end

local function UpdateStatus()
    local buffInfo = GetVampireBuff()
    if (buffInfo == nil) then
        _status.IsVampire = false
        _status.Stage = 0
        _status.StageEnding = 0
        return
    end

    local buffAbility = Map.GetKey(BuffAbilityIds, buffInfo.AbilityId)
    local stage = BuffStage[buffAbility]

    _status.IsVampire = true
    _status.Stage = stage
    _status.StageEnding = buffInfo.TimeEnding
end

local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if (unitTag ~= UnitTag.Player) then
        return
    end

    if (not IsVampireEffect(abilityId)) then
        return
    end

    local effectResult = Map.GetKey(Type.MsgEffectResult, changeType)

    _log:Debug("Effect {1} changed; {2}", effectName, effectResult)
    UpdateStatus()
    Messenger.Publish(
        AddonMessageType.VampireStatusChanged,
        {
            IsVampire = _status.IsVampire,
            Stage = _status.Stage,
            StageEnding = _status.StageEnding
        }
    )
end

local function OnVampireStatusRequest(message)
    return {unpack(_status)}
end

local function StoreVampireAbilityIds(settings)
    _log:Debug("Adding vampire abilities to storage (for development purposes)")

    settings.Abilities = { }

    local skillLineCount = GetNumSkillLines(Type.SkillType.World)
    for skillLineIndex = 1, skillLineCount do
        local skillLineName = GetSkillLineName(Type.SkillType.World, skillLineIndex)
        if (skillLineName == "Vampire") then
            settings.VampireSkillLineIndex = skillLineIndex

            local skillCount = GetNumSkillAbilities(Type.SkillType.World, skillLineIndex)
            for skillIndex = 1, skillCount do
                local abilityInfo = Pack.GetSkillAbilityInfo(Type.SkillType.World, skillLineIndex, skillIndex)
                if (not abilityInfo.Passive) then
                    local abilities = { }
                    settings.Abilities[skillIndex] = abilities

                    local morphBaseAbilityId = GetAbilityProgressionAbilityId(abilityInfo.ProgressionIndex, Type.MorphSlot.Base, 1)
                    local morphBaseAbilityName = GetAbilityName(morphBaseAbilityId)
                    abilities[morphBaseAbilityName] = morphBaseAbilityId

                    local morph1AbilityId = GetAbilityProgressionAbilityId(abilityInfo.ProgressionIndex, Type.MorphSlot.Morph1, 1)
                    local morph1AbilityName = GetAbilityName(morph1AbilityId)
                    abilities[morph1AbilityName] = morph1AbilityId

                    local morph2AbilityId = GetAbilityProgressionAbilityId(abilityInfo.ProgressionIndex, Type.MorphSlot.Morph2, 1)
                    local morph2AbilityName = GetAbilityName(morph2AbilityId)
                    abilities[morph2AbilityName] = morph2AbilityId
                end
            end

            return
        end
    end
end

local function StoreVampireEffectAbilityIds(settings)
    _log:Debug("Adding vampire effect abilities to storage (for development purposes)")

    settings.Buffs = { }

    for abilityId = 100000, 200000 do
        if (DoesAbilityExist(abilityId)) then
            local abilityName = GetAbilityName(abilityId)
            if (string.find(abilityName, "Vampire Stage", 1, true)) then
                settings.Buffs[abilityName] = abilityId
            end
        end
    end
end

local function Initialize()
    UpdateStatus()
    Messenger.Publish(
        AddonMessageType.VampireStatusChanged,
        {
            IsVampire = _status.IsVampire,
            Stage = _status.Stage,
            StageEnding = _status.StageEnding
        }
    )
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _log = Log.CreateInstance(Name)

    EventManager:RegisterForEvent(Name, Event.EffectChanged, OnEffectChanged)

    Messenger.Subscribe(FrameworkMessageType.InitialActivation, Initialize)
    Messenger.Subscribe(AddonMessageType.VampireStatusRequest, OnVampireStatusRequest)

    local settings = Storage.GetEntry(Name)
    if (settings.AddonVersion ~= addonInfo.Version) then
        StoreVampireAbilityIds(settings)
        StoreVampireEffectAbilityIds(settings)
        settings.AddonVersion = addonInfo.Version
    end
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)

-- Class functions