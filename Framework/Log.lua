--[[
    Log class is used to output logs to the console window.
]]

-- Usings

local Array = EsoAddonFramework_Framework_Array
local Color = EsoAddonFramework_Framework_Color
local Console = EsoAddonFramework_Framework_Console
local FrameworkMessageType = EsoAddonFramework_Framework_MessageType
local LogLevel = EsoAddonFramework_Framework_LogLevel
local Map = EsoAddonFramework_Framework_Map
local Messenger = EsoAddonFramework_Framework_Messenger
local Storage = EsoAddonFramework_Framework_Storage
local StorageScope = EsoAddonFramework_Framework_StorageScope
local String = EsoAddonFramework_Framework_String

-- Constants

local DefaultSettings = {
    IsEnabled = false,
    LogLevel = LogLevel.Debug,
    Classes = { }
}

local Name = "EsoAddonFramework_Framework_Utils_Log"

-- Fields

local _isInitalized = false
local _logInstances = { }
local _settings = DefaultSettings

-- Local functions

local function CreateSettingsControls()
    local settingsControls = {
        {
            type = "checkbox",
            name = "Enable log output",
            getFunc = function() return _settings.IsEnabled end,
            setFunc = function(value) _settings.IsEnabled = value end
        },
        {
            type = "dropdown",
            name = "Log level",
            choices = {"Debug", "Information", "Warning", "Error"},
            getFunc = function() return Map.GetKey(LogLevel, _settings.LogLevel) end,
            setFunc = function(value) _settings.LogLevel = LogLevel[value] end,
            disabled = function() return not _settings.IsEnabled end
        },
        {
            type = "header",
            name = "Log sources"
        }
    }

    for name, _ in Map.ByKey(_settings.Classes) do
        Array.Add(settingsControls, {
            type = "checkbox",
            name = name,
            getFunc = function() return _settings.Classes[name] end,
            setFunc = function(value) _settings.Classes[name] = value end,
            disabled = function() return not _settings.IsEnabled end
        })
    end

    return {
        DisplayName = "Debug options",
        Controls = settingsControls,
        IsLast = true
    }
end

local function InsertInstanceName(logInstance, formatString, args, argCount)
    Array.Add(args, logInstance.Name)
    argCount = argCount + 1
    local colorName = Map.GetKey(Color, Color.Gray)
    formatString = "{" .. argCount .. ":" .. colorName .. "}: " .. formatString
    return formatString, argCount
end

local function InsertLogPrefix(logLevel, formatString, args, argCount)
    local color
    if (logLevel == LogLevel.Debug) then
        Array.Add(args, "DBG")
        color = Color.Gray
    elseif (logLevel == LogLevel.Information) then
        Array.Add(args, "INF")
        color = Color.White
    elseif (logLevel == LogLevel.Warning) then
        Array.Add(args, "WRN")
        color = Color.Yellow
    elseif (logLevel == LogLevel.Error) then
        Array.Add(args, "ERR")
        color = Color.Red
    else
        Array.Add(args, "???")
        color = Color.Gray
    end

    argCount = argCount + 1
    local colorName = Map.GetKey(Color, color)
    formatString = "[{" .. argCount .. ":" .. colorName .. "}] " .. formatString
    return formatString, argCount
end

local function OutputToConsole(logInstance, logLevel, formatString, ...)
    if (not _settings.IsEnabled or
        logLevel < _settings.LogLevel) then
        return
    end

    if (_settings.Classes[logInstance.Name] == false) then
        return
    end

    local args = { }
    local argCount = select("#", ...)
    for argIndex = 1, argCount do
        local arg = select(argIndex, ...)
        if (arg ~= nil) then
            Array.Add(args, arg)
        else
            Array.Add(args, "(nil)")
        end
    end

    formatString, argCount = InsertInstanceName(logInstance, formatString, args, argCount)
    formatString, argCount = InsertLogPrefix(logLevel, formatString, args, argCount)

    local value = String.Format(formatString, unpack(args))
    Console.Write(value)
end

local function Output(logInstance, logLevel, formatString, ...)
    if (not _isInitalized) then
        -- Output to cache while not initialized, because nothing will show in the console
        Array.Add(logInstance.Cache, { LogLevel = logLevel, FormatString = tostring(formatString), Arguments = {...} })
        return
    end

    OutputToConsole(logInstance, logLevel, tostring(formatString), ...)
end

local function ProcessCache()
    for _, logInstance in Array.Enumerate(_logInstances) do
        for _, value in Array.Enumerate(logInstance.Cache) do
            OutputToConsole(logInstance, value.LogLevel, value.FormatString, unpack(value.Arguments))
        end

        logInstance.Cache = nil
    end
end

local function Initialize()
    ProcessCache()
    _isInitalized = true
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _settings = Storage.GetEntry(Name, DefaultSettings, StorageScope.Account)

    Messenger.Subscribe(FrameworkMessageType.InitialActivation, Initialize)
    Messenger.Subscribe(FrameworkMessageType.SettingsControlsRequest, CreateSettingsControls)
end

---@class Log
EsoAddonFramework_Framework_Log = { }
EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)

local LogInstance = { }
LogInstance.__index = LogInstance

-- Class functions

---@class LogInstance
---@field Debug fun(formatString:string, args:...) # Logs a debug message
---@field Information fun(formatString:string, args:...) # Logs an information message
---@field Warning fun(formatString:string, args:...) # Logs a warning message
---@field Error fun(formatString:string, args:...) # Logs an error message

---Create a log instance for a class.
---@param name string # Class name
---@return LogInstance # Created class instance
function EsoAddonFramework_Framework_Log.CreateInstance(name)
    local instanceName = Array.Last(String.Split(name, "_"))

    local logInstance = { }
    setmetatable(logInstance, LogInstance)
    logInstance.Name = instanceName

    if (_settings.Classes[logInstance.Name] == nil) then
        _settings.Classes[logInstance.Name] = true
    end

    if (not _isInitalized) then
        logInstance.Cache = { }
    end

    Array.Add(_logInstances, logInstance)

    return logInstance
end

---Logs a debug message
---@param formatString string # Class name
---@vararg any # Arguments
function LogInstance:Debug(formatString, ...)
    Output(self, LogLevel.Debug, formatString, ...)
end

---Logs an information message
---@param formatString string # Class name
---@vararg any # Arguments
function LogInstance:Information(formatString, ...)
    Output(self, LogLevel.Information, formatString, ...)
end

---Logs a warning message
---@param formatString string # Class name
---@vararg any # Arguments
function LogInstance:Warning(formatString, ...)
    Output(self, LogLevel.Warning, formatString, ...)
end

---Logs an error message
---@param formatString string # Class name
---@vararg any # Arguments
function LogInstance:Error(formatString, ...)
    Output(self, LogLevel.Error, formatString, ...)
end