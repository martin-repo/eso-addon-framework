--[[
    SettingsManager handles creation and showing of settings page.
]]

-- Usings

local Array = EsoAddonFramework_Framework_Array
local FrameworkMessageType = EsoAddonFramework_Framework_MessageType
local Messenger = EsoAddonFramework_Framework_Messenger
local String = EsoAddonFramework_Framework_String

-- Constants

-- Fields

local _addonInfo
local _settingsPanel

-- Local functions

local function OnSettingsPanelOpened(panel)
    if (panel ~= _settingsPanel) then
        return
    end

    Messenger.Publish(FrameworkMessageType.SettingsShown)
end

local function CreateSettingsMenu()
    local panelData = {
        type = "panel",
        name = _addonInfo.DisplayName,
        author = _addonInfo.Author,
        version = _addonInfo.Version,
        registerForRefresh = true
    }

    ---@diagnostic disable-next-line: undefined-global
    _settingsPanel = LibAddonMenu2:RegisterAddonPanel(_addonInfo.Name, panelData)

    local optionControls = { }

    local controlsInfos = {Messenger.Publish(FrameworkMessageType.SettingsControlsRequest)}
    for _, controlsInfo in Array.Enumerate(controlsInfos) do
        Array.Add(optionControls, {
            type = "submenu",
            name = controlsInfo.DisplayName,
            controls = controlsInfo.Controls,
            isLast = controlsInfo.IsLast
        })
    end

    Array.Sort(optionControls, function(a, b)
        if (a.isLast == true) then
            return false
        elseif (b.isLast == true) then
            return true
        end

        local aClean = String.StripColorCodes(a.name)
        local bClean = String.StripColorCodes(b.name)
        return aClean < bClean
    end)

    ---@diagnostic disable-next-line: undefined-global
    LibAddonMenu2:RegisterOptionControls(_addonInfo.Name, optionControls)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", OnSettingsPanelOpened)
end

local function ShowSettings()
    ---@diagnostic disable-next-line: undefined-global
    LibAddonMenu2:OpenToPanel(_settingsPanel)
end

local function Initialize()
    CreateSettingsMenu()
    Messenger.Subscribe(FrameworkMessageType.ShowSettings, ShowSettings)
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _addonInfo = addonInfo
    Messenger.Subscribe(FrameworkMessageType.InitialActivation, Initialize)
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)

-- Class functions