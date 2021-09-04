--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local ZO_OptionsPanel_Camera_ControlData =
{
    --Gamepad
    [SETTING_TYPE_GAMEPAD] =
    {
        --Options_Gamepad_CameraSensitivity
        [GAMEPAD_SETTING_CAMERA_SENSITIVITY] =
        {
            controlType = OPTIONS_SLIDER,
            system = SETTING_TYPE_GAMEPAD,
            settingId = GAMEPAD_SETTING_CAMERA_SENSITIVITY,
            panel = SETTING_PANEL_CAMERA,
            text = SI_GAMEPAD_OPTIONS_CAMERA_SENSITIVITY,
            minValue = 0.65,
            maxValue = 1.05,
            valueFormat = "%.2f",
            showValue = true,
            showValueMin = 0,
            showValueMax = 100,
        },
        --Options_Gamepad_InvertY
        [GAMEPAD_SETTING_INVERT_Y] =
        {
            controlType = OPTIONS_CHECKBOX,
            system = SETTING_TYPE_GAMEPAD,
            settingId = GAMEPAD_SETTING_INVERT_Y,
            panel = SETTING_PANEL_CAMERA,
            text = SI_GAMEPAD_OPTIONS_INVERT_Y,
        },
    },
}

ZO_SharedOptions.AddTableToPanel(SETTING_PANEL_CAMERA, ZO_OptionsPanel_Camera_ControlData)