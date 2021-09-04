-- Usings

---@type Array
local Array = EsoAddonFramework_Framework_Array
---@type Color
local Color = EsoAddonFramework_Framework_Color
---@type Console
local Console = EsoAddonFramework_Framework_Console

-- Constants

-- Fields

-- Local functions

local function GetArgTypeColors(args)
    local argTypeColors = { }
    for _, arg in Array.Enumerate(args) do
        local argType = type(arg)
        if (argType == "string") then
            Array.Add(argTypeColors, Color.Green)
        elseif (argType == "number") then
            Array.Add(argTypeColors, Color.Blue)
        elseif (argType == "boolean") then
            Array.Add(argTypeColors, Color.Yellow)
        elseif (argType == "table") then
            Array.Add(argTypeColors, Color.Orange)
        elseif (argType == "userdata") then
            Array.Add(argTypeColors, Color.Gray)
        else
            Console.Write("[String.GetArgTypeColors] type is not supported: " .. argType)
            Array.Add(argTypeColors, Color.White)
        end
    end

    return argTypeColors
end

function SetColor(color, value, close)
    if (value == nil) then
        return "|c" .. color
    end

    if (close ~= true) then
        return "|c" .. color .. value
    end

    return "|c" .. color .. value .. "|r"
end

local function Colorize(format, ...)
    local colorized = SetColor(Color.White, format, true)

    local argCount = select("#", ...)
    local argTypeColors = GetArgTypeColors({...})

    colorized = string.gsub(colorized, "{([^:}]+):?(%w-)}", function(argString, colorOverride)
        if (colorOverride ~= "" and Color[colorOverride] == nil) then
            return "{" .. argString .. "}"
        end

        local isArgNumeric = not string.find(argString, "%D")
        if (not isArgNumeric) then
            if (colorOverride ~= "") then
                return SetColor(Color[colorOverride], argString) .. SetColor(Color.White)
            else
                return SetColor(Color.Green, argString) .. SetColor(Color.White)
            end
        end

        local argIndex = tonumber(argString)
        if (argIndex > argCount) then
            return "{" .. argString .. "}"
        end

        local color
        if (colorOverride ~= "") then
            color = Color[colorOverride]
        else
            color = argTypeColors[argIndex]
        end

        if (color == Color.White) then
            return "{" .. argString .. "}"
        end

        return SetColor(color, "{" .. argString .. "}") .. SetColor(Color.White)
    end)

    return colorized
end

local function ReplaceWithArguments(format, ...)
    local formatted = format

    local args = {...}
    for index, value in Array.Enumerate(args) do
        local count
        formatted, count = string.gsub(formatted, "{" .. index .. "}", tostring(value))
        if (count == 0) then
            formatted = formatted .. " ; " .. value
        end
    end

    local missingArgs = { }
    for missingArg in formatted:gmatch("{.-}") do
        Array.Add(missingArgs, missingArg)
    end

    if (Array.Any(missingArgs)) then
        local distinct = Array.Distinct(missingArgs)
        Array.Sort(distinct)
        for _, missingArg in Array.Enumerate(distinct) do
            formatted = formatted .. " ; " .. missingArg .. " missing"
        end
    end

    return formatted
end

-- Constructor

---@class String
EsoAddonFramework_Framework_String = { }

-- Class functions

---@param source string
---@param value string
---@return boolean
function EsoAddonFramework_Framework_String.EndsWith(source, value)
    local sourceLength = string.len(source)
    local valueLength = string.len(value)
    return string.sub(source, sourceLength - valueLength + 1, sourceLength) == value
end

---Formats a string, replacing placeholders "{X}" (where X is the index of the argument)
---with a colorized representation of the argument.
---@param format string
---@vararg any # Arguments
---@return string # Formatted string
function EsoAddonFramework_Framework_String.Format(format, ...)
    local colorized = Colorize(format, ...)
    local formatted = ReplaceWithArguments(colorized, ...)
    return formatted
end

---@param array table # Table with numeric, contiguous keys
---@param separator string # Value to separate strings
---@param finalSeparator? string # Value to separate final two strings
---@return string
function EsoAddonFramework_Framework_String.Join(array, separator, finalSeparator)
    local count = #array

    if (count == 0) then
        return ""
    elseif (count == 1) then
        return array[1]
    end

    local result = ""
    for index, value in ipairs(array) do
        if (index > 1 and (index < count or finalSeparator == nil)) then
            result = result .. separator
        elseif (index > 1 and index == count) then
            result = result .. finalSeparator
        end

        result = result .. value
    end

    return result
end

---@param value string
---@param color Color
---@return string
function EsoAddonFramework_Framework_String.SetColor(value, color)
    return SetColor(color, value, true)
end

---@param source string
---@param value string
---@return boolean
function EsoAddonFramework_Framework_String.Split(source, value)
    local parts = { }

    local index = 1
    local length = string.len(source)
    while (index < length) do
        local startPos, endPos = source:find(value, index, true)
        if (startPos ~= nil) then
            local part = source:sub(index, startPos - 1)
            if (string.len(part) > 0) then
                table.insert(parts, part)
            end
            index = endPos + 1
        else
            table.insert(parts, source:sub(index, length))
            index = length
        end
    end

    return parts
end

---@param source string
---@param value string
---@return boolean
function EsoAddonFramework_Framework_String.StartsWith(source, value)
    return string.sub(source, 1, string.len(value)) == value
end

---@param value string
---@return string
function EsoAddonFramework_Framework_String.StripColorCodes(value)
    -- LUA patters != RegEx, need to do less-than-desireable patterns...
    return value:gsub("%|c[%da-fA-F][%da-fA-F][%da-fA-F][%da-fA-F][%da-fA-F][%da-fA-F]", ""):gsub("%|r", "")
end