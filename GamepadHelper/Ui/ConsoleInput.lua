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

local Name = "GamepadHelper_Ui_ConsoleInput"

-- Fields

-- Local functions

local function HandleCommand(command)
    local parts = String.Split(command, " ")
    if (not Array.Any(parts)) then
        Console.Write(String.Format("Argument(s) missing."))
        Console.Write(String.Format("Use one of {help}, {settings} or {reload}"))
        return
    end

    if (Array.Count(parts) > 1) then
        Console.Write(String.Format("Multiple arguments not supported."))
        return
    end

    local argument = Array.First(parts)
    if (argument == "help") then
        Console.Write(String.Format("Help is shown in the settings page."))
    elseif (argument == "settings") then
        Messenger.Publish(FrameworkMessageType.ShowSettings)
    elseif (argument == "reload") then
        ReloadUI()
    else
        Console.Write(String.Format("Unsupported argument"))
    end
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    SLASH_COMMANDS["/gamepadhelper"] = HandleCommand
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)