--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

--Pregame Options Table
GAMEPAD_SETTINGS_DATA =
{
    [SETTING_PANEL_CINEMATIC] =
    {
        {
            panel = SETTING_PANEL_CINEMATIC,
            system = SETTING_TYPE_CUSTOM,
            settingId = OPTIONS_CUSTOM_SETTING_GAMEPAD_PREGAME_VIEW_CREDITS,
        },
        {
            panel = SETTING_PANEL_CINEMATIC,
            system = SETTING_TYPE_CUSTOM,
            settingId = OPTIONS_CUSTOM_SETTING_GAMEPAD_PREGAME_PLAY_CINEMATIC,
        },
    },
    [SETTING_PANEL_CAMERA] =
    {
        {
            panel = SETTING_PANEL_CAMERA,
            system = SETTING_TYPE_GAMEPAD,
            settingId = GAMEPAD_SETTING_INVERT_Y,
        },
        {
            panel = SETTING_PANEL_CAMERA,
            system = SETTING_TYPE_GAMEPAD,
            settingId = GAMEPAD_SETTING_CAMERA_SENSITIVITY,
        },
    },
    [SETTING_PANEL_GAMEPLAY] =
    {
        {
            panel = SETTING_PANEL_GAMEPLAY,
            system = SETTING_TYPE_GAMEPAD,
            settingId = GAMEPAD_SETTING_VIBRATION,
        },
    },
    [SETTING_PANEL_VIDEO] =
    {
        {
            panel = SETTING_PANEL_VIDEO,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_CONSOLE_ENHANCED_RENDER_QUALITY,
            header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_DISPLAY,
        },
        {
            panel = SETTING_PANEL_VIDEO,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_GRAPHICS_MODE_PS5,
            header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_DISPLAY,
        },
        {
            panel = SETTING_PANEL_VIDEO,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_GRAPHICS_MODE_XBSS,
            header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_DISPLAY,
        },
        {
            panel = SETTING_PANEL_VIDEO,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_GRAPHICS_MODE_XBSX,
            header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_DISPLAY,
        },
        {
            panel = SETTING_PANEL_VIDEO,
            system = SETTING_TYPE_CUSTOM,
            settingId = OPTIONS_CUSTOM_SETTING_GAMMA_ADJUST,
        },
        {
            panel = SETTING_PANEL_VIDEO,
            system = SETTING_TYPE_CUSTOM,
            settingId = OPTIONS_CUSTOM_SETTING_SCREEN_ADJUST,
        },
        {
            panel = SETTING_PANEL_VIDEO,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_HDR_BRIGHTNESS,
        },
        {
            panel = SETTING_PANEL_VIDEO,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_HDR_MODE,
        },
    },
    [SETTING_PANEL_AUDIO] =
    {
        {
            panel = SETTING_PANEL_AUDIO,
            system = SETTING_TYPE_SUBTITLES,
            settingId = SUBTITLE_SETTING_ENABLED_FOR_VIDEOS,
            header = SI_AUDIO_OPTIONS_SUBTITLES,
        },
        {
            panel = SETTING_PANEL_AUDIO,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_AUDIO_VOLUME,
            header = SI_AUDIO_OPTIONS_GENERAL,
        },
        {
            panel = SETTING_PANEL_AUDIO,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_MUSIC_ENABLED,
        },
        {
            panel = SETTING_PANEL_AUDIO,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_MUSIC_VOLUME,
        },
        {
            panel = SETTING_PANEL_AUDIO,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_SOUND_ENABLED,
        },
        {
            panel = SETTING_PANEL_AUDIO,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_AMBIENT_VOLUME,
        },
        {
            panel = SETTING_PANEL_AUDIO,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_SFX_VOLUME,
        },
        {
            panel = SETTING_PANEL_AUDIO,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_UI_VOLUME,
        },
        {
            panel = SETTING_PANEL_AUDIO,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_VIDEO_VOLUME,
        },
        {
            panel = SETTING_PANEL_AUDIO,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_VO_VOLUME,
        },
        {
            panel = SETTING_PANEL_AUDIO,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_FOOTSTEPS_VOLUME,
        },
        {
            panel = SETTING_PANEL_AUDIO,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_VOICE_CHAT_VOLUME,
        },
        {
            panel = SETTING_PANEL_AUDIO,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_BACKGROUND_AUDIO,
            header = SI_AUDIO_OPTIONS_OUTPUT,
        },
    },
    [SETTING_PANEL_ACCOUNT] =
    {
        -- Email Address
        {
            panel = SETTING_PANEL_ACCOUNT,
            system = SETTING_TYPE_ACCOUNT,
            settingId = ACCOUNT_SETTING_ACCOUNT_EMAIL,
            header = SI_INTERFACE_OPTIONS_ACCOUNT_EMAIL_HEADER,
        },
        {
            panel = SETTING_PANEL_ACCOUNT,
            system = SETTING_TYPE_CUSTOM,
            settingId = OPTIONS_CUSTOM_SETTING_RESEND_EMAIL_ACTIVATION,
            header = SI_INTERFACE_OPTIONS_ACCOUNT_EMAIL_HEADER,
        },
        -- Marketing Preferences
        {
            panel = SETTING_PANEL_ACCOUNT,
            system = SETTING_TYPE_ACCOUNT,
            settingId = ACCOUNT_SETTING_GET_UPDATES,
            header = SI_INTERFACE_OPTIONS_ACCOUNT_MARKETING_HEADER,
        },
    },
}

local ZO_OptionsPanel_Gamepad_Pregame_ControlData =
{
    --Pregame Gamepad settings
    [SETTING_TYPE_CUSTOM] =
    {
        --View Credits
        [OPTIONS_CUSTOM_SETTING_GAMEPAD_PREGAME_VIEW_CREDITS] =
        {
            controlType = OPTIONS_INVOKE_CALLBACK,
            system = SETTING_TYPE_CUSTOM,
            panel = SETTING_PANEL_CINEMATIC,
            settingId = OPTIONS_CUSTOM_SETTING_GAMEPAD_PREGAME_VIEW_CREDITS,
            text = SI_GAME_MENU_CREDITS,
            callback = function()
                            SCENE_MANAGER:Push("gamepad_credits")
                        end

        },
        --Play Cinematic
        [OPTIONS_CUSTOM_SETTING_GAMEPAD_PREGAME_PLAY_CINEMATIC] =
        {
            controlType = OPTIONS_INVOKE_CALLBACK,
            system = SETTING_TYPE_CUSTOM,
            panel = SETTING_PANEL_CINEMATIC,
            settingId = OPTIONS_CUSTOM_SETTING_GAMEPAD_PREGAME_PLAY_CINEMATIC,
            text = SI_GAME_MENU_PLAY_CINEMATIC,
            callback = ZO_PlayIntroCinematicAndReturn,
        },

    }
}

ZO_SharedOptions.AddTableToPanel(SETTING_PANEL_CINEMATIC, ZO_OptionsPanel_Gamepad_Pregame_ControlData)