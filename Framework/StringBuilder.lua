-- Usings

-- Constants

-- Fields

-- Local functions

-- Constructor

---@class StringBuilder
EsoAddonFramework_Framework_StringBuilder = { }

local StringBuilderInstance = { }
StringBuilderInstance.__index = StringBuilderInstance

-- Class functions

---@class StringBuilderInstance
---@field Append fun(value:string)
---@field AppendLine fun(value:string)
---@field ToString fun():string

---@return StringBuilderInstance
function EsoAddonFramework_Framework_StringBuilder.CreateInstance()
    local stringBuilderInstance = { }
    setmetatable(stringBuilderInstance, StringBuilderInstance)
    stringBuilderInstance.Value = ""
    return stringBuilderInstance
end

---@param value string
function StringBuilderInstance:Append(value)
    self.Value = self.Value .. value
end

---@param value? string
function StringBuilderInstance:AppendLine(value)
    if (value ~= nil) then
        self:Append(value)
    end

    self.Value = self.Value .. "\r\n"
end

---@return string
function StringBuilderInstance:ToString()
    return self.Value
end