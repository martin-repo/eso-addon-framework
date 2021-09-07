--#region Usings

--#region Framework usings
--#endregion

--#region Addon usings
--#endregion

--#endregion

-- Constants

-- Fields

-- Local functions

local function HandleCommand(command)
    local parts = String.Split(command, " ")
    if (not Array.Any(parts)) then
        -- No arguments
        -- ...
        return
    end

    if (Array.Count(parts) > 1) then
        -- Multiple arguments
        -- ...
        return
    end

    local argument = Array.First(parts)
    if (argument == "abc") then
        -- ...
    elseif (argument == "def") then
        -- ...
    else
        -- ...
    end
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    SLASH_COMMANDS["/addonexample"] = HandleCommand
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)