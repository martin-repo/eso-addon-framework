--[[
    This view will display the name and action of the current interaction target.
    It is a pure UI example and doesn't provide any real purpose.
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

local DefaultSettings = {
    IsEnabled = true
}

local Name = "GamepadHelper_Ui_InteractionTarget"

-- Fields

local _actionLabel
local _log
local _settings = DefaultSettings

-- Local functions

local function CreateControlByCode()
    _log:Information("Creating second label by code. First label was created in XML.")
    local root = GetControl("GamepadHelper_Ui_InteractionTarget")
    _actionLabel = CreateControl("GamepadHelper_Ui_InteractionTarget_Action", root, Type.ControlType.Label)
    _actionLabel:SetDimensions(500, 25)
    _actionLabel:SetAnchor(Type.AnchorPosition.Topleft, root, Type.AnchorPosition.Topleft, 0, 30)
    _actionLabel:SetFont("ZoFontWinH1")
    _actionLabel:SetInheritAlpha(true)
    _actionLabel:SetColor(GetInterfaceColor(Type.InterfaceColorType.BuffType, Type.BuffTypeColors.Buff))
    _actionLabel:SetWrapMode(Type.TextWrapMode.Truncate)
end

local function ShowActionInfo(name, action)
    GamepadHelper_Ui_InteractionTarget_Name:SetText(name)
    _actionLabel:SetText(action)
end

local function CreateSettingsControls()
    local settingsControls = {
        {
            type = "checkbox",
            name = "Enabled",
            getFunc = function() return _settings.IsEnabled end,
            setFunc = function(value)
                _settings.IsEnabled = value
                if (not _settings.IsEnabled) then
                    ShowActionInfo("", "")
                end
            end,
        }
    }

    return {
        DisplayName = "Interaction target UI",
        Controls = settingsControls
    }
end

local function OnInteractionChanged(message)
    if (not _settings.IsEnabled) then
        return
    end

    if (message.InteractionAvailable) then
        ShowActionInfo(message.ActionInfo.Name, message.ActionInfo.Action)
    else
        ShowActionInfo("", "")
    end
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _log = Log.CreateInstance(Name)
    CreateControlByCode()

    Messenger.Subscribe(FrameworkMessageType.SettingsControlsRequest, CreateSettingsControls)
    Messenger.Subscribe(AddonMessageType.InteractionChanged, OnInteractionChanged)

    _settings = Storage.GetEntry(Name)
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)