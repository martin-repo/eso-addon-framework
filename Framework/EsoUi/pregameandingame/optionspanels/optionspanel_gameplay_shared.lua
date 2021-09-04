--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local ZO_OptionsPanel_Gameplay_ControlData =
{
    [SETTING_TYPE_GAMEPAD] =
    {
        --Options_Gamepad_Vibration
        [GAMEPAD_SETTING_VIBRATION] =
        {
            controlType = OPTIONS_CHECKBOX,
            system = SETTING_TYPE_GAMEPAD,
            settingId = GAMEPAD_SETTING_VIBRATION,
            panel = SETTING_PANEL_GAMEPLAY,
            text = SI_GAMEPAD_OPTIONS_CAMERA_VIBRATION,
        },
    },
}

ZO_SharedOptions.AddTableToPanel(SETTING_PANEL_GAMEPLAY, ZO_OptionsPanel_Gameplay_ControlData)