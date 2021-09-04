--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local function IsSoundEnabled()
    return tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SOUND_ENABLED)) ~= 0
end

local ZO_OptionsPanel_Audio_ControlData =
{
    --Audio
    [SETTING_TYPE_AUDIO] =
    {
        --Options_Audio_MasterVolume
        [AUDIO_SETTING_AUDIO_VOLUME] =
        {
            controlType = OPTIONS_SLIDER,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_AUDIO_VOLUME,
            panel = SETTING_PANEL_AUDIO,
            text = SI_AUDIO_OPTIONS_MASTER_VOLUME,
            tooltipText = SI_AUDIO_OPTIONS_MASTER_VOLUME_TOOLTIP,
            minValue = 0,
            maxValue = 100,
            showValue = true,
            onReleasedHandler = function() PlaySound(SOUNDS.VOLUME_DING_ALL) end,
        },
        --Options_Audio_MusicEnabled
        [AUDIO_SETTING_MUSIC_ENABLED] =
        {
            controlType = OPTIONS_CHECKBOX,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_MUSIC_ENABLED,
            panel = SETTING_PANEL_AUDIO,
            text = SI_AUDIO_OPTIONS_MUSIC_ENABLED,
            tooltipText = SI_AUDIO_OPTIONS_MUSIC_ENABLED_TOOLTIP,
            events = {[true] = "MusicEnabled_On", [false] = "MusicEnabled_Off",},
            gamepadHasEnabledDependencies = true,
        },
        --Options_Audio_MusicVolume
        [AUDIO_SETTING_MUSIC_VOLUME] =
        {
            controlType = OPTIONS_SLIDER,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_MUSIC_VOLUME,
            panel = SETTING_PANEL_AUDIO,
            text = SI_AUDIO_OPTIONS_MUSIC_VOLUME,
            tooltipText = SI_AUDIO_OPTIONS_MUSIC_VOLUME_TOOLTIP,
            minValue = 0,
            maxValue = 100,
            showValue = true,
            eventCallbacks =
            {
                ["MusicEnabled_On"] = ZO_Options_SetOptionActive,
                ["MusicEnabled_Off"] = ZO_Options_SetOptionInactive,
            },
            onReleasedHandler = function() PlaySound(SOUNDS.VOLUME_DING_MUSIC) end,
            gamepadIsEnabledCallback = function() 
                                            return tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_ENABLED)) ~= 0
                                        end,
        },
        --Options_Audio_SoundEnabled
        [AUDIO_SETTING_SOUND_ENABLED] =
        {
            controlType = OPTIONS_CHECKBOX,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_SOUND_ENABLED,
            panel = SETTING_PANEL_AUDIO,
            text = SI_AUDIO_OPTIONS_SOUND_ENABLED,
            tooltipText = SI_AUDIO_OPTIONS_SOUND_ENABLED_TOOLTIP,
            events = {[true] = "SoundEnabled_On", [false] = "SoundEnabled_Off",},
            gamepadHasEnabledDependencies = true,
        },
        --Options_Audio_AmbientVolume
        [AUDIO_SETTING_AMBIENT_VOLUME] =
        {
            controlType = OPTIONS_SLIDER,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_AMBIENT_VOLUME,
            panel = SETTING_PANEL_AUDIO,
            text = SI_AUDIO_OPTIONS_AMBIENT_VOLUME,
            tooltipText = SI_AUDIO_OPTIONS_AMBIENT_VOLUME_TOOLTIP,
            minValue = 0,
            maxValue = 100,
            showValue = true,
            eventCallbacks =
            {
                ["SoundEnabled_On"] = ZO_Options_SetOptionActive,
                ["SoundEnabled_Off"]= ZO_Options_SetOptionInactive,
            },
            onReleasedHandler = function() PlaySound(SOUNDS.VOLUME_DING_AMBIENT) end,
            gamepadIsEnabledCallback = IsSoundEnabled,
        },
        --Options_Audio_SFXVolume
        [AUDIO_SETTING_SFX_VOLUME] =
        {
            controlType = OPTIONS_SLIDER,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_SFX_VOLUME,
            panel = SETTING_PANEL_AUDIO,
            text = SI_AUDIO_OPTIONS_SFX_VOLUME,
            tooltipText = SI_AUDIO_OPTIONS_SFX_VOLUME_TOOLTIP,
            minValue = 0,
            maxValue = 100,
            showValue = true,
            eventCallbacks =
            {
                ["SoundEnabled_On"] = ZO_Options_SetOptionActive,
                ["SoundEnabled_Off"]= ZO_Options_SetOptionInactive,
            },
            onReleasedHandler = function() PlaySound(SOUNDS.VOLUME_DING_SFX) end,
            gamepadIsEnabledCallback = IsSoundEnabled,
        },
        --Options_Audio_FootstepsVolume
        [AUDIO_SETTING_FOOTSTEPS_VOLUME] =
        {
            controlType = OPTIONS_SLIDER,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_FOOTSTEPS_VOLUME,
            panel = SETTING_PANEL_AUDIO,
            text = SI_AUDIO_OPTIONS_FOOTSTEPS_VOLUME,
            tooltipText = SI_AUDIO_OPTIONS_FOOTSTEPS_VOLUME_TOOLTIP,
            minValue = 0,
            maxValue = 100,
            showValue = true,
            eventCallbacks =
            {
                ["SoundEnabled_On"] = ZO_Options_SetOptionActive,
                ["SoundEnabled_Off"]= ZO_Options_SetOptionInactive,
            },
            onReleasedHandler = function() PlaySound(SOUNDS.VOLUME_DING_FOOTSTEPS) end,
            gamepadIsEnabledCallback = IsSoundEnabled,
        },
        --Options_Audio_VOVolume
        [AUDIO_SETTING_VO_VOLUME] =
        {
            controlType = OPTIONS_SLIDER,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_VO_VOLUME,
            panel = SETTING_PANEL_AUDIO,
            text = SI_AUDIO_OPTIONS_VO_VOLUME,
            tooltipText = SI_AUDIO_OPTIONS_VO_VOLUME_TOOLTIP,
            minValue = 0,
            maxValue = 100,
            showValue = true,
            eventCallbacks =
            {
                ["SoundEnabled_On"] = ZO_Options_SetOptionActive,
                ["SoundEnabled_Off"]= ZO_Options_SetOptionInactive,
            },
            onReleasedHandler = function() PlaySound(SOUNDS.VOLUME_DING_VO) end,
            gamepadIsEnabledCallback = IsSoundEnabled,
        },
        --Options_Audio_UISoundVolume
        [AUDIO_SETTING_UI_VOLUME] =
        {
            controlType = OPTIONS_SLIDER,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_UI_VOLUME,
            panel = SETTING_PANEL_AUDIO,
            text = SI_AUDIO_OPTIONS_UI_VOLUME,
            tooltipText = SI_AUDIO_OPTIONS_UI_VOLUME_TOOLTIP,
            minValue = 0,
            maxValue = 100,
            showValue = true,
            eventCallbacks =
            {
                ["SoundEnabled_On"] = ZO_Options_SetOptionActive,
                ["SoundEnabled_Off"]= ZO_Options_SetOptionInactive,
            },
            onReleasedHandler = function() PlaySound(SOUNDS.VOLUME_DING_UI) end,
            gamepadIsEnabledCallback = IsSoundEnabled,
        },
        --Options_Audio_VideoSoundVolume
        [AUDIO_SETTING_VIDEO_VOLUME] =
        {
            controlType = OPTIONS_SLIDER,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_VIDEO_VOLUME,
            panel = SETTING_PANEL_AUDIO,
            text = SI_AUDIO_OPTIONS_VIDEO_VOLUME,
            tooltipText = SI_AUDIO_OPTIONS_VIDEO_VOLUME_TOOLTIP,
            minValue = 0,
            maxValue = 100,
            showValue = true,
            eventCallbacks =
            {
                ["SoundEnabled_On"] = ZO_Options_SetOptionActive,
                ["SoundEnabled_Off"]= ZO_Options_SetOptionInactive,
            },
            onReleasedHandler = function() PlaySound(SOUNDS.VOLUME_DING_VIDEO) end,
            gamepadIsEnabledCallback = IsSoundEnabled,
        },
        --Options_Audio_BackgroundAudio
        [AUDIO_SETTING_BACKGROUND_AUDIO] =
        {
            controlType = OPTIONS_CHECKBOX,
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_BACKGROUND_AUDIO,
            panel = SETTING_PANEL_AUDIO,
            text = SI_AUDIO_OPTIONS_BACKGROUND_AUDIO,
            tooltipText = SI_AUDIO_OPTIONS_BACKGROUND_AUDIO_TOOLTIP,
            exists = ZO_IsPCOrHeronUI,
        },
        --Options_Audio_VoiceChatVolume
        [AUDIO_SETTING_VOICE_CHAT_VOLUME] =
        {
            system = SETTING_TYPE_AUDIO,
            settingId = AUDIO_SETTING_VOICE_CHAT_VOLUME,
            controlType = OPTIONS_SLIDER,
            panel = SETTING_PANEL_DEBUG,
            text = SI_GAMEPAD_AUDIO_OPTIONS_VOICECHAT_VOLUME,
            minValue = 40,
            maxValue = 75,
            exists = IsConsoleUI,
        },
    },

    --Subtitles
    [SETTING_TYPE_SUBTITLES] =
    {
        --Options_Audio_SubtitlesEnabledForNPCs
        [SUBTITLE_SETTING_ENABLED_FOR_NPCS] =
        {
            controlType = OPTIONS_CHECKBOX,
            system = SETTING_TYPE_SUBTITLES,
            settingId = SUBTITLE_SETTING_ENABLED_FOR_NPCS,
            panel = SETTING_PANEL_AUDIO,
            text = SI_AUDIO_OPTIONS_NPC_SUBTITLES_ENABLED,
            tooltipText = SI_AUDIO_OPTIONS_NPC_SUBTITLES_ENABLED_TOOLTIP,
            exists = ZO_IsIngameUI,
        },
        --Options_Audio_SubtitlesEnabledForVideos
        [SUBTITLE_SETTING_ENABLED_FOR_VIDEOS] =
        {
            controlType = OPTIONS_CHECKBOX,
            system = SETTING_TYPE_SUBTITLES,
            settingId = SUBTITLE_SETTING_ENABLED_FOR_VIDEOS,
            panel = SETTING_PANEL_AUDIO,
            text = SI_AUDIO_OPTIONS_VIDEO_SUBTITLES_ENABLED,
            tooltipText = SI_AUDIO_OPTIONS_VIDEO_SUBTITLES_ENABLED_TOOLTIP,
        },
    },
}

ZO_SharedOptions.AddTableToPanel(SETTING_PANEL_AUDIO, ZO_OptionsPanel_Audio_ControlData)