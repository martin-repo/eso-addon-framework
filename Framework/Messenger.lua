--[[
    Messenger class is used for communication between classes.
]]

-- Usings

local Array = EsoAddonFramework_Framework_Array
local Map = EsoAddonFramework_Framework_Map

-- Constants

-- Fields

local _subscribers = { }

-- Local functions

-- Constructor

---@class Messenger
EsoAddonFramework_Framework_Messenger = { }

-- Class functions

---@param messageType any
---@param callback fun(message:table):any # Callback when a message is received.
function EsoAddonFramework_Framework_Messenger.Subscribe(messageType, callback)
    if (_subscribers[messageType] == nil) then
        Map.Add(_subscribers, messageType, { })
    end

    Array.Add(_subscribers[messageType], callback)
end

---@param messageType any
---@param message any
---@param abortPredicate? fun(output:any):boolean # Predicate that evaluates if sending should continue.
---@return ... # Return values, one from each subscriber.
function EsoAddonFramework_Framework_Messenger.Publish(messageType, message, abortPredicate)
    if (_subscribers[messageType] == nil) then
        return
    end

    local outputs = { }
    for _, callback in Array.Enumerate(_subscribers[messageType]) do
        local output = callback(message)
        Array.Add(outputs, output)

        if (abortPredicate ~= nil and abortPredicate(output) == true) then
            return unpack(outputs)
        end
    end

    return unpack(outputs)
end