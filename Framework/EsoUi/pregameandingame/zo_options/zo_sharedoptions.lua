--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-- this table stores everything needed to setup every setting control
-- each OptionsPanel_Whatever.lua file creates a table and adds itself to this one.
ZO_SharedOptions_SettingsData  = {} 
SETTING_TYPE_CUSTOM = 5000 --this must be bigger than EsoGameDataEnums::cSettingSystemTypeSize
internalassert(SETTING_TYPE_CUSTOM > (SETTING_TYPE_MAX_VALUE + 1))

ZO_SharedOptions = ZO_InitializingObject:Subclass()

function ZO_SharedOptions:Initialize()
    self.controlTable = {}
    self.panelNames = {}
    self.isGamepadOptions = false
end

function ZO_SharedOptions:IsGamepadOptions()
    return self.isGamepadOptions
end

function ZO_SharedOptions:SaveCachedSettings()
    -- We only care about saving cached setting messages ingame
    if SendAllCachedSettingMessages then
        SendAllCachedSettingMessages()
    end
end

function ZO_SharedOptions:GetControlTypeFromControl(control)
    local data = control.data
    if data.controlType == OPTIONS_FINITE_LIST then
        if self:IsGamepadOptions() then
            return OPTIONS_HORIZONTAL_SCROLL_LIST
        else
            return OPTIONS_DROPDOWN
        end
    end

    return data.controlType
end

function ZO_SharedOptions:GetControlType(controlType)
    if controlType == OPTIONS_FINITE_LIST then
        if self:IsGamepadOptions() then
            return OPTIONS_HORIZONTAL_SCROLL_LIST
        else
            return OPTIONS_DROPDOWN
        end
    end

    return controlType
end

function ZO_SharedOptions:InitializeControl(control, selected, isKeyboardControl)
    local data = control.data
    local text = nil

    if type(data.text) == "string" then
        text = data.text
    elseif type(data.text) == "function" then
        text = data.text(control)
    else
        text = GetString(data.text)
    end

    local controlType = self:GetControlTypeFromControl(control)
    control.optionsManager = self

    if controlType == OPTIONS_SECTION_TITLE then
        GetControl(control, "Label"):SetText(text)
    elseif controlType == OPTIONS_DROPDOWN then
        GetControl(control, "Name"):SetText(text)
        ZO_Options_SetupDropdown(control)
    elseif controlType == OPTIONS_HORIZONTAL_SCROLL_LIST then
        GetControl(control, "Name"):SetText(text)
        ZO_Options_SetupScrollList(control, selected)
    elseif controlType == OPTIONS_CHECKBOX then
        GetControl(control, "Name"):SetText(text)
        ZO_Options_SetupCheckBox(control)
    elseif controlType == OPTIONS_SLIDER then
        GetControl(control, "Name"):SetText(text)
        ZO_Options_SetupSlider(control, selected)
    elseif controlType == OPTIONS_INVOKE_CALLBACK  then
        ZO_Options_SetupInvokeCallback(control, selected, text)
    elseif controlType == OPTIONS_COLOR then
        GetControl(control, "Name"):SetText(text)
    elseif controlType == OPTIONS_CHAT_COLOR then
        GetControl(control, "Name"):SetText(text)
        data.customResetToDefaultsFunction = ZO_OptionsPanel_Social_ResetChatColorToDefault
    elseif controlType == OPTIONS_CUSTOM then
        if data.customSetupFunction then
            data.customSetupFunction(control, selected)
        end
    end

    if data.onInitializeFunction then
        data.onInitializeFunction(control, isKeyboardControl)
    end
end

do
    local OPTION_CONTROL_TYPES =
    {
        [OPTIONS_DROPDOWN] = true,
        [OPTIONS_CHECKBOX] = true,
        [OPTIONS_SLIDER] = true,
        [OPTIONS_HORIZONTAL_SCROLL_LIST] = true,
        [OPTIONS_COLOR] = true,
        [OPTIONS_CHAT_COLOR] = true,
    }

    function ZO_SharedOptions:IsControlTypeAnOption(data)
        local controlType = self:GetControlType(data.controlType)
        return OPTION_CONTROL_TYPES[controlType]
    end
end

function ZO_SharedOptions:DoesSettingExist(settingData)
    local existsValueOrCallback
    if self:IsGamepadOptions() then
        existsValueOrCallback = settingData.existsOnGamepad or settingData.exists
    else
        existsValueOrCallback = settingData.exists
    end

    if existsValueOrCallback == nil then
        return true -- default is existence
    elseif type(existsValueOrCallback) == "function" then
        return existsValueOrCallback()
    else
        return existsValueOrCallback
    end
end

function ZO_SharedOptions:LoadDefaults(control, settingData)
    if self:DoesSettingExist(settingData) then
        if settingData.customResetToDefaultsFunction then
            settingData.customResetToDefaultsFunction(control, settingData)
        elseif self:IsControlTypeAnOption(settingData) then
            if not settingData.excludeFromResetToDefault then
                ResetSettingToDefault(settingData.system, settingData.settingId)
            end
        end
    end
end

function ZO_SharedOptions:GetSettingsData(panel, system, settingId)
    return ZO_SharedOptions_SettingsData[panel][system][settingId]
end

function ZO_SharedOptions.AddTableToPanel(panel, table)
    for key, entry in pairs(table) do
        if ZO_SharedOptions_SettingsData[panel] == nil then
            ZO_SharedOptions_SettingsData[panel] = {}
        end
        ZO_SharedOptions_SettingsData[panel][key] = entry
    end
end

function ZO_SharedOptions.AddTableToSystem(panel, system, table)
    for key, entry in pairs(table) do
        if ZO_SharedOptions_SettingsData[panel] == nil then
            ZO_SharedOptions_SettingsData[panel] = {}
        end
        if ZO_SharedOptions_SettingsData[panel][system] == nil then
            ZO_SharedOptions_SettingsData[panel][system] = {}
        end
        ZO_SharedOptions_SettingsData[panel][system][key] = entry
    end
end

function ZO_SharedOptions:ApplySettings(control)
    -- optional override
end

function ZO_SharedOptions:EnableApplyButton()
    -- optional override
end

function ZO_SharedOptions.GetColorOptionHighlight()
    -- optional override
end

do
    local SETTING_PANEL_DISABLES_SHARE_FEATURES =
    {
        [SETTING_PANEL_ACCOUNT] = true,
    }

    function ZO_SharedOptions.DoesPanelDisableShareFeatures(panel)
        return SETTING_PANEL_DISABLES_SHARE_FEATURES[panel] == true
    end
end
