--#region Usings

--#region Framework usings
--#endregion

--#region Addon usings
--#endregion

--#endregion

-- Constants

local Name = "AddonExample_Ui_AbilityDisplay"

-- Fields

local _callLaterId
local _log

-- Local functions

local function ShowAblilityName(name)
    AddonExample_Ui_AbilityDisplay_Name:SetText(name)
end

local function OnDisplayAbilityName(message)
    if (_callLaterId ~= nil) then
        zo_removeCallLater(_callLaterId)
        _callLaterId = nil
    end

    _log:Debug("Showing ability name")
    ShowAblilityName(message.AbilityName)
    _callLaterId = zo_callLater(
        function()
            _callLaterId = nil
            _log:Debug("Hiding ability name")
            ShowAblilityName("")
        end,
        3000)
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _log = Log.CreateInstance(Name)

    Messenger.Subscribe(AddonMessageType.DisplayAbilityName, OnDisplayAbilityName)
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)