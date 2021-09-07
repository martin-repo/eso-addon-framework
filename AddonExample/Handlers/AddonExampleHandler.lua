--#region Usings

--#region Framework usings
--#endregion

--#region Addon usings
--#endregion

--#endregion

-- Constants

local DefaultSettings = {
    IsEnabled = true
}

local Name = "AddonExample_Handlers_AddonExampleHandler"

-- Fields

local _log
local _settings

-- Local functions

---@param event Event # esoui type: `integer`
---@param actionSlotIndex number # esoui type: `luaindex`
local function OnActionSlotAbilityUsed(event, actionSlotIndex)
    if (not _settings.IsEnabled) then
        return
    end

    local abilityId = GetSlotBoundId(actionSlotIndex)
    local abilityName = GetAbilityName(abilityId)

    _log:Debug("Publishing message")
    Messenger.Publish(AddonMessageType.DisplayAbilityName, { AbilityName = abilityName })
end

local function OnInitialActivation()
    Console.Write(String.Format(Lang.LanguageSectionA["Welcome to {Tamriel}, {1}!"], GetUnitName(UnitTag.Player)))
    Console.Write(String.Format(Lang.LanguageSectionA.NiceDay))
end

local function OnSettingsControlsRequest()
    local settingsControls = {
        {
            type = "description",
            text = String.Format("Handler example for publishing a message whenever an ability is used")
        },
        {
            type = "checkbox",
            name = "Enabled",
            getFunc = function() return _settings.IsEnabled end,
            setFunc = function(value) _settings.IsEnabled = value end,
        }
    }

    return {
        DisplayName = String.Format("AddonExample handler example"),
        Controls = settingsControls
    }
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _log = Log.CreateInstance(Name)

    Messenger.Subscribe(FrameworkMessageType.InitialActivation, OnInitialActivation)
    Messenger.Subscribe(FrameworkMessageType.SettingsControlsRequest, OnSettingsControlsRequest)

    EventManager:RegisterForEvent(Name, Event.ActionSlotAbilityUsed, OnActionSlotAbilityUsed)

    _settings = Storage.GetEntry(Name, DefaultSettings, StorageScope.Account)
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)