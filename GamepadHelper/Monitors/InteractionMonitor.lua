--[[
    Monitors when an interaction is available.
    A preview message is sent (MessageType.InteractionChangedPreview) where subscribers can choose to suppress the interaction from showing in the UI.
    A second message is sent (MessageType.InteractionChanged) if the interaction was not suppressed.
    Listens to message (MessageType.InteractionCriteriaChanged) where it will re-evaluate interaction (ie. resend messages).
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

local Name = "GamepadHelper_Monitors_InteractionMonitor"

-- Fields

local _action = {
    Available = false,
    Suppressed = false,
    Name = ""
}

local _log

-- Local functions

local function GetActionInfo()
    if (IsCutsceneActive() or
       IsInteracting() or
       IsLooting()) then
        return nil
    end

    local actionInfo = Pack.GetGameCameraInteractableActionInfo()

    if (actionInfo.InteractBlocked) then
        return nil
    end

    if (actionInfo.Name == nil) then
        return nil
    end

    return actionInfo
end

local function HandleInteractionLost()
    if (_action.Available) then
        _log:Debug("Interaction lost")
        _action.Available = false
        Messenger.Publish(AddonMessageType.InteractionChanged, { InteractionAvailable = false })
    end
end

local function OnInteractionCriteriaChanged(message)
    _log:Debug("Interaction reset")
    HandleInteractionLost()
end

local function OnReticleTryHandlingInteractionPreHook(event, interactionPossible, currentFrameTimeSeconds)
    if (not interactionPossible) then
        HandleInteractionLost()
        return false
    end

    local actionInfo = GetActionInfo()
    if (actionInfo == nil) then
        HandleInteractionLost()
        return false
    end

    if (_action.Available and _action.Name == actionInfo.Name) then
        -- The same interaction is available, return current suppressed status
        return _action.Suppressed
    end

    _log:Debug("Interaction {1} preview", actionInfo.Name)
    local suppressResponses = {
        Messenger.Publish(
            AddonMessageType.InteractionChangedPreview,
            { ActionInfo = actionInfo },
            function(suppress) return suppress == true end
        )
    }
    local suppress = Array.Any(suppressResponses, function(suppress) return suppress == true end)

    if (suppress) then
        HandleInteractionLost()
    end

    _action.Available = true
    _action.Name = actionInfo.Name

    _action.Suppressed = suppress
    if (_action.Suppressed) then
        return true
    end

    _log:Debug("Interaction {1} available", actionInfo.Name)
    Messenger.Publish(AddonMessageType.InteractionChanged, { InteractionAvailable = true, ActionInfo = actionInfo })
    return false
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _log = Log.CreateInstance(Name)

    Messenger.Subscribe(AddonMessageType.InteractionCriteriaChanged, OnInteractionCriteriaChanged)

    -- Use instance "RETICLE" instead of class "ZO_Reticle"
    ZO_PreHook(RETICLE, "TryHandlingInteraction", OnReticleTryHandlingInteractionPreHook)
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)