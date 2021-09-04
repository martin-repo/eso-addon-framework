--[[
    Storage class is used to access saved variables.
]]

-- Usings

---@type Map
local Map = EsoAddonFramework_Framework_Map
---@type StorageScope
local StorageScope = EsoAddonFramework_Framework_StorageScope

-- Constants

local Namespace = "storage"
local Version = 1

-- Fields

local _accountStorage
local _characterStorage

-- Local functions

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _accountStorage = ZO_SavedVars:NewAccountWide(
        addonInfo.SavedVariables,
        Version,
        Namespace,
        { },
        GetWorldName())

    _characterStorage = ZO_SavedVars:NewCharacterIdSettings(
        addonInfo.SavedVariables,
        Version,
        Namespace,
        { },
        GetWorldName())
end

---@class Storage
EsoAddonFramework_Framework_Storage = { }
EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)

-- Class functions

---@param name string # Name of storage section to get.
---@param default? table # Default settings if they don't exist in storage
---@param scope? StorageScope
---@return table # Storage section
function EsoAddonFramework_Framework_Storage.GetEntry(name, default, scope)
    if (scope == nil) then
        scope = StorageScope.Account
    end

    local storage
    if (scope == StorageScope.Account) then
        storage = _accountStorage
    elseif (scope == StorageScope.Character) then
        storage = _characterStorage
    else
        return nil
    end

    if (storage[name] == nil) then
        storage[name] = { }
    end

    if (default ~= nil) then
        Map.ConcatMap(storage[name], default)
    end

    return storage[name]
end