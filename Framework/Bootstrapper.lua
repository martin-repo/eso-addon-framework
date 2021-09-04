--[[
    Bootstrapper class is the main glue for the addon.
]]

-- Usings

local Array = EsoAddonFramework_Framework_Array
local Event = EsoAddonFramework_Framework_Eso_Event
local EventManager = EsoAddonFramework_Framework_Eso_EventManager
local FrameworkMessageType = EsoAddonFramework_Framework_MessageType
local Messenger = EsoAddonFramework_Framework_Messenger

-- Constants

-- Fields

local _addonInfo
local _constructors = { }
local _name

-- Local functions

local function OnAddonLoaded(event, addonName)
    if addonName ~= _addonInfo.Name then
        return
    end

    EventManager:UnregisterForEvent(_name, Event.AddOnLoaded)

    for _, constructor in Array.Enumerate(_constructors) do
        constructor(_addonInfo)
    end
end

local function OnPlayerActivated(event, isInitial)
    EventManager:UnregisterForEvent(_name, Event.PlayerActivated)

    Messenger.Publish(FrameworkMessageType.InitialActivation)
end

-- Constructor

EsoAddonFramework_Framework_Bootstrapper = { }

-- Class functions

---@class AddonInfo
---@field Name string # Addon identification name (short, no spaces, no special characters)
---@field DisplayName string # Addon name that is shown in the UI (may contain color codes)
---@field Description string # Short addon description
---@field Author string # Shown in settings menu
---@field Version string # Shown in settings menu
---@field SavedVariables string # Storage name (eg. Name .. "Storage")
---@field Libraries table # Array of library names that this addon requires

---@param constructor fun(addon:AddonInfo)
function EsoAddonFramework_Framework_Bootstrapper.Register(constructor)
    Array.Add(_constructors, constructor)
end

---@param addonInfo AddonInfo
function EsoAddonFramework_Framework_Bootstrapper.Start(addonInfo)
    _addonInfo = addonInfo

    _name = "EsoAddonFramework_Framework_Bootstrapper_" .. addonInfo.Name

    EventManager:RegisterForEvent(_name, Event.AddOnLoaded, OnAddonLoaded)
    EventManager:RegisterForEvent(_name, Event.PlayerActivated, OnPlayerActivated)
end