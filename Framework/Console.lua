-- Constants

-- Fields

-- Local functions

-- Constructor

---@class Console
EsoAddonFramework_Framework_Console = { }

-- Class functions

---Writes unformatted message to the console.
---@param message string
function EsoAddonFramework_Framework_Console.Write(message)
    CHAT_ROUTER:AddDebugMessage(message)
end