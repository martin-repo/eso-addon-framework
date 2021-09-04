--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local function GetDisplayText(index)
    -- Start index display at 1 instead of 0
    return zo_strformat(SI_GRAPHICS_OPTIONS_VIDEO_ACTIVE_DISPLAY_FORMAT, index + 1)
end

local function InitializeDisplays(control, numDisplays)
    local valid = {}
    local events = {}
    local itemText = {}

    for i = 1, numDisplays do
        -- Identifying indicies start at 0
        local index = i - 1
        local optionText = GetDisplayText(index)
        valid[#valid + 1] = index
        events[#events + 1] = "ActiveDisplayChanged"
        itemText[#itemText + 1] = optionText
    end

    control.data.valid = valid
    control.data.events = events
    control.data.itemText = itemText

    ZO_OptionsWindow_InitializeControl(control)

    ZO_Options_SetOptionActiveOrInactive(control, GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_FULLSCREEN) == FULLSCREEN_MODE_FULLSCREEN_EXCLUSIVE)
end

local function GetResolutionInfo(w, h)
    local optionValue = string.format("%dx%d", w, h)
    local optionText = zo_strformat(SI_GRAPHICS_OPTIONS_VIDEO_RESOLUTION_FORMAT, w, h)
    return optionValue, optionText
end

local function InitializeResolution(control, ...)
    local valid = {}
    local itemText = {}

    -- process two elements at a time since the input looks like this: {w1, h1, w2, h2, w3, h3, ...}
    for i = 1, select("#", ...), 2 do
        local optionValue, optionText = GetResolutionInfo(select(i, ...))
        if optionValue and optionText then
            valid[#valid + 1] = optionValue
            itemText[#itemText + 1] = optionText
        end
    end

    control.data.valid = valid
    control.data.itemText = itemText

    ZO_OptionsWindow_InitializeControl(control)

    ZO_Options_SetOptionActiveOrInactive(control, GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_FULLSCREEN) == FULLSCREEN_MODE_FULLSCREEN_EXCLUSIVE)
end

function ZO_OptionsPanel_Video_InitializeDisplays(control)
    InitializeDisplays(control, GetNumDisplays())
end

function ZO_OptionsPanel_Video_OnActiveDisplayChanged(control)
    ZO_OptionsWindow_InitializeControl(control)
    ZO_Options_UpdateOption(control)
end

function ZO_OptionsPanel_Video_InitializeResolution(control)
    local DEFAULT_DISPLAY_INDEX = 1
    InitializeResolution(control, GetDisplayModes(DEFAULT_DISPLAY_INDEX))
end

function ZO_OptionsPanel_Video_SetCustomScale(self, formattedValueString)
    SetSetting(SETTING_TYPE_UI, UI_SETTING_CUSTOM_SCALE, formattedValueString)
    ApplySettings()
end

function ZO_OptionsPanel_Video_CustomScale_RefreshEnabled(control)
    if ZO_GameMenu_PreGame or GetSetting(SETTING_TYPE_UI, UI_SETTING_USE_CUSTOM_SCALE) == "0" then
        ZO_Options_SetOptionInactive(control)
    else
        ZO_Options_SetOptionActive(control)
    end
end

do
    local DELAY_CHANGES_MS = 500
    local g_applyChangesId = nil
    EVENT_MANAGER:RegisterForEvent("ZO_Options_GamepadCustomScaleChanged", EVENT_INTERFACE_SETTING_CHANGED, function(_, systemType, settingId)
        if systemType == SETTING_TYPE_UI and settingId == UI_SETTING_GAMEPAD_CUSTOM_SCALE then
            -- Deliberately delay applying the custom scale to avoid artifacts caused by manipulating the slider during a resize
            if g_applyChangesId then
                zo_removeCallLater(g_applyChangesId)
            end
            g_applyChangesId = zo_callLater(function()
                ApplySettings()
                g_applyChangesId = nil
            end, DELAY_CHANGES_MS)
        end
    end)
end

function ZO_OptionsPanel_Video_HasConsoleRenderQualitySetting()
    if IsConsoleUI() then
        local numValidOptions = 0
        for settingValue = CONSOLE_ENHANCED_RENDER_QUALITY_ITERATION_BEGIN, CONSOLE_ENHANCED_RENDER_QUALITY_ITERATION_END do
            if DoesSystemSupportConsoleEnhancedRenderQuality(settingValue) then
                numValidOptions = numValidOptions + 1
                if numValidOptions > 1 then
                    return true
                end
            end
        end
    end

    return false
end


local ZO_OptionsPanel_Video_ControlData =
{
    --Graphics
    [SETTING_TYPE_GRAPHICS] =
    {
        --Options_Video_DisplayMode
        [GRAPHICS_SETTING_FULLSCREEN] =
        {
            controlType = OPTIONS_FINITE_LIST,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_FULLSCREEN,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_DISPLAY_MODE,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_DISPLAY_MODE_TOOLTIP,
            valid = {FULLSCREEN_MODE_FULLSCREEN_EXCLUSIVE, FULLSCREEN_MODE_WINDOWED, FULLSCREEN_MODE_FULLSCREEN_WINDOWED, },
            valueStringPrefix = "SI_FULLSCREENMODE",
            exists = ZO_IsPCUI,

            events = {[FULLSCREEN_MODE_WINDOWED] = "DisplayModeNonExclusive", [FULLSCREEN_MODE_FULLSCREEN_WINDOWED] = "DisplayModeNonExclusive", [FULLSCREEN_MODE_FULLSCREEN_EXCLUSIVE] = "DisplayModeExclusive",},
        },
        --Options_Video_ActiveDisplay
        [GRAPHICS_SETTING_ACTIVE_DISPLAY] =
        {
            controlType = OPTIONS_FINITE_LIST,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_ACTIVE_DISPLAY,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_ACTIVE_DISPLAY,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_ACTIVE_DISPLAY_TOOLTIP,
            exists = IsActiveDisplayEnabledOnPlatform,

            eventCallbacks =
            {
                ["DisplayModeNonExclusive"] = ZO_Options_SetOptionInactive,
                ["DisplayModeExclusive"] = ZO_Options_SetOptionActive,
            },
        },
        --Options_Video_Resolution
        [GRAPHICS_SETTING_RESOLUTION] =
        {
            controlType = OPTIONS_FINITE_LIST,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_RESOLUTION,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_RESOLUTION,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_RESOLUTION_TOOLTIP,
            exists = ZO_IsPCUI,

            eventCallbacks =
            {
                ["DisplayModeNonExclusive"] = ZO_Options_SetOptionInactive,
                ["DisplayModeExclusive"] = ZO_Options_SetOptionActive,
                ["ActiveDisplayChanged"] = ZO_OptionsPanel_Video_OnActiveDisplayChanged,
            },

            gamepadIsEnabledCallback = function()
                                return tonumber(GetSetting(SETTING_TYPE_GRAPHICS,GRAPHICS_SETTING_FULLSCREEN)) == FULLSCREEN_MODE_FULLSCREEN_EXCLUSIVE
                            end
        },
        --Options_Video_VSync
        [GRAPHICS_SETTING_VSYNC] =
        {
            controlType = OPTIONS_CHECKBOX,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_VSYNC,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_VSYNC,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_VSYNC_TOOLTIP,
            exists = ZO_IsPCUI,
        },
        --Options_Video_RenderThread
        [GRAPHICS_SETTING_RENDER_THREAD] =
        {
            controlType = OPTIONS_CHECKBOX,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_RENDER_THREAD,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_RENDER_THREAD,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_RENDER_THREAD_TOOLTIP,
            exists = function()
                return ZO_IsPCUI() and not IsMacUI()
            end
        },
        --Options_Video_AntiAliasing_Type
        [GRAPHICS_SETTING_ANTIALIASING_TYPE] =
        {
            controlType = OPTIONS_FINITE_LIST,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_ANTIALIASING_TYPE,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_ANTI_ALIASING,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_ANTI_ALIASING_TOOLTIP,
            valid = { ANTIALIASING_TYPE_NONE, ANTIALIASING_TYPE_FXAA, ANTIALIASING_TYPE_TAA, },
            valueStringPrefix = "SI_ANTIALIASINGTYPE",
            exists = ZO_IsPCUI,
        },
        --Options_Video_Gamma_Adjustment
        [GRAPHICS_SETTING_GAMMA_ADJUSTMENT] =
        {
            controlType = OPTIONS_SLIDER,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_GAMMA_ADJUSTMENT,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_GAMMA_ADJUSTMENT,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_GAMMA_ADJUSTMENT_TOOLTIP,
            minValue = 75,
            maxValue = 150,
            valueFormat = "%.2f",
        },
        --Options_Video_Graphics_Quality
        [GRAPHICS_SETTING_PRESETS] =
        {
            controlType = OPTIONS_FINITE_LIST,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_PRESETS,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_PRESETS,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_PRESETS_TOOLTIP,

            valid = IsMinSpecMachine() 
                    and {GRAPHICS_PRESETS_MINIMUM, GRAPHICS_PRESETS_LOW, GRAPHICS_PRESETS_MEDIUM, GRAPHICS_PRESETS_CUSTOM}
                    or {GRAPHICS_PRESETS_MINIMUM, GRAPHICS_PRESETS_LOW, GRAPHICS_PRESETS_MEDIUM, GRAPHICS_PRESETS_HIGH, GRAPHICS_PRESETS_ULTRA, GRAPHICS_PRESETS_MAXIMUM, GRAPHICS_PRESETS_CUSTOM},

            valueStringPrefix = "SI_GRAPHICSPRESETS",
            mustReloadSettings = true,
            mustPushApply = true,
            exists = ZO_IsPCUI,
        },
        --Options_Video_Texture_Resolution
        [GRAPHICS_SETTING_MIP_LOAD_SKIP_LEVELS] =
        {
            controlType = OPTIONS_FINITE_LIST,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_MIP_LOAD_SKIP_LEVELS,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_TEXTURE_RES,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_TEXTURE_RES_TOOLTIP,

            valid = IsMinSpecMachine() 
                    and {TEX_RES_CHOICE_LOW, TEX_RES_CHOICE_MEDIUM}
                    or {TEX_RES_CHOICE_LOW, TEX_RES_CHOICE_MEDIUM, TEX_RES_CHOICE_HIGH},

            valueStringPrefix = "SI_TEXTURERESOLUTIONCHOICE",
            mustPushApply = true,
            exists = ZO_IsPCUI,
        },
        --Options_Video_Sub_Sampling
        [GRAPHICS_SETTING_SUB_SAMPLING] =
        {
            controlType = OPTIONS_FINITE_LIST,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_SUB_SAMPLING,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_SUB_SAMPLING,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_SUB_SAMPLING_TOOLTIP,
            valid = {SUB_SAMPLING_MODE_LOW, SUB_SAMPLING_MODE_MEDIUM, SUB_SAMPLING_MODE_NORMAL},
            valueStringPrefix = "SI_SUBSAMPLINGMODE",
            exists = ZO_IsPCUI,
        },
        --Options_Video_Shadows
        [GRAPHICS_SETTING_SHADOWS] =
        {
            controlType = OPTIONS_FINITE_LIST,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_SHADOWS,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_SHADOWS,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_SHADOWS_TOOLTIP,
            valid = {SHADOWS_CHOICE_OFF, SHADOWS_CHOICE_LOW, SHADOWS_CHOICE_MEDIUM, SHADOWS_CHOICE_HIGH, SHADOWS_CHOICE_ULTRA},
            valueStringPrefix = "SI_SHADOWSCHOICE",
            mustPushApply = true,
            exists = ZO_IsPCUI,
        },
        --Options_Video_Screenspace_Water_Reflection_Quality
        [GRAPHICS_SETTING_SCREENSPACE_WATER_REFLECTION_QUALITY] =
        {
            controlType = OPTIONS_FINITE_LIST,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_SCREENSPACE_WATER_REFLECTION_QUALITY,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_SCREENSPACE_WATER_REFLECTION_QUALITY,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_SCREENSPACE_WATER_REFLECTION_QUALITY_TOOLTIP,
            valid = {SCREENSPACE_WATER_REFLECTION_QUALITY_OFF, SCREENSPACE_WATER_REFLECTION_QUALITY_LOW, SCREENSPACE_WATER_REFLECTION_QUALITY_MEDIUM, SCREENSPACE_WATER_REFLECTION_QUALITY_HIGH, SCREENSPACE_WATER_REFLECTION_QUALITY_ULTRA},
            valueStringPrefix = "SI_SCREENSPACEWATERREFLECTIONQUALITY",
            mustPushApply = true,
            exists = ZO_IsPCUI,
        },
        --Options_Video_Planar_Water_Reflection_Quality
        [GRAPHICS_SETTING_PLANAR_WATER_REFLECTION_QUALITY] =
        {
            controlType = OPTIONS_FINITE_LIST,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_PLANAR_WATER_REFLECTION_QUALITY,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_PLANAR_WATER_REFLECTION_QUALITY,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_PLANAR_WATER_REFLECTION_QUALITY_TOOLTIP,
            valid = {PLANAR_WATER_REFLECTION_QUALITY_OFF, PLANAR_WATER_REFLECTION_QUALITY_MEDIUM, PLANAR_WATER_REFLECTION_QUALITY_HIGH},
            valueStringPrefix = "SI_PLANARWATERREFLECTIONQUALITY",
            mustPushApply = true,
            exists = ZO_IsPCUI,
        },
        --Options_Video_Maximum_Particle_Systems
        [GRAPHICS_SETTING_PFX_GLOBAL_MAXIMUM] =
        {
            controlType = OPTIONS_SLIDER,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_PFX_GLOBAL_MAXIMUM,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_MAXIMUM_PARTICLE_SYSTEMS,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_MAXIMUM_PARTICLE_SYSTEMS_TOOLTIP,
            minValue = 768,
            maxValue = 2048,
            valueFormat = "%d",
            showValue = true,
            showValueMin = 768,
            showValueMax = 2048,
            exists = ZO_IsPCUI,
        },
        --Options_Video_Particle_Suppression_Distance
        [GRAPHICS_SETTING_PFX_SUPPRESS_DISTANCE] =
        {
            controlType = OPTIONS_SLIDER,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_PFX_SUPPRESS_DISTANCE,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_PARTICLE_SUPPRESSION_DISTANCE,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_PARTICLE_SUPPRESSION_DISTANCE_TOOLTIP,
            minValue = 35.0,
            maxValue = 100.0,
            valueFormat = "%d",
            showValue = true,
            showValueMin = 35,
            showValueMax = 100,
            exists = ZO_IsPCUI,
        },
        --Options_Video_View_Distance
        [GRAPHICS_SETTING_VIEW_DISTANCE] =
        {
            controlType = OPTIONS_SLIDER,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_VIEW_DISTANCE,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_VIEW_DISTANCE,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_VIEW_DISTANCE_TOOLTIP,
            minValue = 0.4,
            maxValue = 2.0,
            valueFormat = "%.2f",
            showValue = true,
            showValueMin = 0,
            showValueMax = 100,
            exists = ZO_IsPCUI,
        },
        --Options_Video_Ambient_Occlusion
        [GRAPHICS_SETTING_AMBIENT_OCCLUSION_TYPE] =
        {
            controlType = OPTIONS_FINITE_LIST,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_AMBIENT_OCCLUSION_TYPE,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_AMBIENT_OCCLUSION_TYPE,
            tooltipText = IsMacUI()
                    and SI_GRAPHICS_OPTIONS_VIDEO_MAC_AMBIENT_OCCLUSION_TYPE_TOOLTIP
                    or SI_GRAPHICS_OPTIONS_VIDEO_WINDOWS_AMBIENT_OCCLUSION_TYPE_TOOLTIP,
            valid = IsMacUI()
                    and {AMBIENT_OCCLUSION_TYPE_NONE, AMBIENT_OCCLUSION_TYPE_SSAO, AMBIENT_OCCLUSION_TYPE_HBAO}
                    or {AMBIENT_OCCLUSION_TYPE_NONE, AMBIENT_OCCLUSION_TYPE_SSAO, AMBIENT_OCCLUSION_TYPE_HBAO, AMBIENT_OCCLUSION_TYPE_LSAO, AMBIENT_OCCLUSION_TYPE_SSGI},
            valueStringPrefix = "SI_AMBIENTOCCLUSIONTYPE",
            exists = ZO_IsPCUI,
        },
        --Options_Video_Clutter_2D_Quality
        [GRAPHICS_SETTING_CLUTTER_2D_QUALITY] =
        {
            controlType = OPTIONS_FINITE_LIST,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_CLUTTER_2D_QUALITY,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_CLUTTER_2D_QUALITY,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_CLUTTER_2D_QUALITY_TOOLTIP,
            valid = { CLUTTER_QUALITY_OFF, CLUTTER_QUALITY_LOW, CLUTTER_QUALITY_MEDIUM, CLUTTER_QUALITY_HIGH, CLUTTER_QUALITY_ULTRA, },
            valueStringPrefix = "SI_CLUTTERQUALITY",
            exists = ZO_IsPCUI,
        },
        --Options_Video_Depth_Of_Field_Mode
        [GRAPHICS_SETTING_DEPTH_OF_FIELD_MODE] =
        {
            controlType = OPTIONS_FINITE_LIST,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_DEPTH_OF_FIELD_MODE,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_DEPTH_OF_FIELD_MODE,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_DEPTH_OF_FIELD_MODE_TOOLTIP,
            
            valid = IsMacUI()
                    and {DEPTH_OF_FIELD_MODE_OFF, DEPTH_OF_FIELD_MODE_SIMPLE, DEPTH_OF_FIELD_MODE_SMOOTH}
                    or {DEPTH_OF_FIELD_MODE_OFF, DEPTH_OF_FIELD_MODE_SIMPLE, DEPTH_OF_FIELD_MODE_SMOOTH, DEPTH_OF_FIELD_MODE_CIRCULAR},
            
            valueStringPrefix = "SI_DEPTHOFFIELDMODE",
            exists = ZO_IsPCUI,
        },
        --Options_Video_Bloom
        [GRAPHICS_SETTING_BLOOM] =
        {
            controlType = OPTIONS_CHECKBOX,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_BLOOM,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_BLOOM,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_BLOOM_TOOLTIP,
            exists = ZO_IsPCUI,
        },
        --Options_Video_Distortion
        [GRAPHICS_SETTING_DISTORTION] =
        {
            controlType = OPTIONS_CHECKBOX,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_DISTORTION,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_DISTORTION,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_DISTORTION_TOOLTIP,
            exists = ZO_IsPCUI,
        },
        --Options_Video_God_Rays
        [GRAPHICS_SETTING_GOD_RAYS] =
        {
            controlType = OPTIONS_CHECKBOX,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_GOD_RAYS,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_GOD_RAYS,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_GOD_RAYS_TOOLTIP,
            exists = ZO_IsPCUI,
        },
        [GRAPHICS_SETTING_CONSOLE_ENHANCED_RENDER_QUALITY] =
        {
            controlType = OPTIONS_FINITE_LIST,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_CONSOLE_ENHANCED_RENDER_QUALITY,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_CONSOLE_ENHANCED_RENDER_QUALITY,
            tooltipText = GetTooltipStringForRenderQualitySetting(),
            --valid = dynamically determined based on the system below,
            valueStringPrefix = "SI_CONSOLEENHANCEDRENDERQUALITY",
            mustPushApply = GetUIPlatform() == UI_PLATFORM_XBOX,
            exists = ZO_OptionsPanel_Video_HasConsoleRenderQualitySetting,
        },
        [GRAPHICS_SETTING_GRAPHICS_MODE_PS5] =
        {
            controlType = OPTIONS_FINITE_LIST,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_GRAPHICS_MODE_PS5,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_CONSOLE_ENHANCED_RENDER_QUALITY,
            tooltipText = SI_GRAPHICS_OPTIONS_CONSOLE_ENHANCED_RENDER_QUALITY_TOOLTIP_PS5,
            valid = { GRAPHICS_MODE_FIDELITY, GRAPHICS_MODE_PERFORMANCE },
            valueStringPrefix = "SI_GRAPHICSMODE",
            mustPushApply = false,
            exists = GetUIPlatform() == UI_PLATFORM_PS5
        },
        [GRAPHICS_SETTING_GRAPHICS_MODE_XBSS] =
        {
            controlType = OPTIONS_FINITE_LIST,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_GRAPHICS_MODE_XBSS,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_CONSOLE_ENHANCED_RENDER_QUALITY,
            tooltipText = SI_GRAPHICS_OPTIONS_CONSOLE_ENHANCED_RENDER_QUALITY_TOOLTIP_XBSS,
            valid = { GRAPHICS_MODE_FIDELITY, GRAPHICS_MODE_PERFORMANCE },
            valueStringPrefix = "SI_GRAPHICSMODE",
            mustPushApply = true,
            exists = DoesPlatformSupportGraphicSetting(GRAPHICS_SETTING_GRAPHICS_MODE_XBSS)
        },
        [GRAPHICS_SETTING_GRAPHICS_MODE_XBSX] =
        {
            controlType = OPTIONS_FINITE_LIST,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_GRAPHICS_MODE_XBSX,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_CONSOLE_ENHANCED_RENDER_QUALITY,
            tooltipText = SI_GRAPHICS_OPTIONS_CONSOLE_ENHANCED_RENDER_QUALITY_TOOLTIP_XBSX,
            valid = { GRAPHICS_MODE_FIDELITY, GRAPHICS_MODE_PERFORMANCE },
            valueStringPrefix = "SI_GRAPHICSMODE",
            mustPushApply = true,
            exists = DoesPlatformSupportGraphicSetting(GRAPHICS_SETTING_GRAPHICS_MODE_XBSX)
        },
        [GRAPHICS_SETTING_HDR_BRIGHTNESS] =
        {
            controlType = OPTIONS_SLIDER,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_HDR_BRIGHTNESS,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_HDR_BRIGHTNESS,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_HDR_BRIGHTNESS_TOOLTIP,
            minValue = 0,
            maxValue = 1,
            valueFormat = "%.2f",
            visible = IsSystemUsingHDR,
        },
        [GRAPHICS_SETTING_HDR_MODE] =
        {
            controlType = OPTIONS_FINITE_LIST,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_HDR_MODE,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_HDR_MODE,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_HDR_MODE_TOOLTIP,
            valid = { HDR_MODE_DEFAULT, HDR_MODE_VIBRANT },
            valueStringPrefix = "SI_HDRMODE",
            visible = IsSystemUsingHDR,
            exists = IsConsoleUI,
        },
        [GRAPHICS_SETTING_SHOW_ADDITIONAL_ALLY_EFFECTS] =
        {
            controlType = OPTIONS_CHECKBOX,
            system = SETTING_TYPE_GRAPHICS,
            settingId = GRAPHICS_SETTING_SHOW_ADDITIONAL_ALLY_EFFECTS,
            panel = SETTING_PANEL_VIDEO,
            text = SI_GRAPHICS_OPTIONS_VIDEO_SHOW_ADDITIONAL_ALLY_EFFECTS,
            tooltipText = SI_GRAPHICS_OPTIONS_VIDEO_SHOW_ADDITIONAL_ALLY_EFFECTS_TOOLTIP,
            exists = ZO_IsPCUI,
        },
    },

    --UI Settings
    [SETTING_TYPE_UI] =
    {
        --Options_Video_UseCustomScale
        [UI_SETTING_USE_CUSTOM_SCALE] =
        {
            controlType = OPTIONS_CHECKBOX,
            system = SETTING_TYPE_UI,
            settingId = UI_SETTING_USE_CUSTOM_SCALE,
            panel = SETTING_PANEL_VIDEO,
            text = SI_VIDEO_OPTIONS_UI_USE_CUSTOM_SCALE,
            tooltipText = SI_VIDEO_OPTIONS_UI_USE_CUSTOM_SCALE_TOOLTIP,
            exists = ZO_IsIngameUI,
            events = {
                [true] = "UseCustomScaleToggled",
                [false] = "UseCustomScaleToggled",
            },
        },
        --Options_Video_CustomScale
        [UI_SETTING_CUSTOM_SCALE] =
        {
            controlType = OPTIONS_SLIDER,
            system = SETTING_TYPE_UI,
            settingId = UI_SETTING_CUSTOM_SCALE,
            panel = SETTING_PANEL_VIDEO,
            text = SI_VIDEO_OPTIONS_UI_CUSTOM_SCALE,
            tooltipText = SI_VIDEO_OPTIONS_UI_CUSTOM_SCALE_TOOLTIP,
            exists = ZO_IsIngameUI,
            valueFormat = "%.6f",
            minValue = KEYBOARD_CUSTOM_UI_SCALE_LOWER_BOUND,
            maxValue = KEYBOARD_CUSTOM_UI_SCALE_UPPER_BOUND,
            onReleasedHandler = ZO_OptionsPanel_Video_SetCustomScale,
            eventCallbacks =
            {
                ["UseCustomScaleToggled"] = ZO_OptionsPanel_Video_CustomScale_RefreshEnabled,
            }
        },
        [UI_SETTING_USE_GAMEPAD_CUSTOM_SCALE] =
        {
            controlType = OPTIONS_CHECKBOX,
            system = SETTING_TYPE_UI,
            settingId = UI_SETTING_USE_GAMEPAD_CUSTOM_SCALE,
            panel = SETTING_PANEL_VIDEO,
            text = SI_VIDEO_OPTIONS_UI_USE_CUSTOM_SCALE,
            tooltipText = SI_VIDEO_OPTIONS_UI_USE_CUSTOM_SCALE_TOOLTIP,
            exists = ZO_IsIngameUI,
        },
        [UI_SETTING_GAMEPAD_CUSTOM_SCALE] =
        {
            controlType = OPTIONS_SLIDER,
            system = SETTING_TYPE_UI,
            settingId = UI_SETTING_GAMEPAD_CUSTOM_SCALE,
            panel = SETTING_PANEL_VIDEO,
            text = SI_VIDEO_OPTIONS_UI_CUSTOM_SCALE,
            tooltipText = SI_VIDEO_OPTIONS_UI_CUSTOM_SCALE_TOOLTIP,
            exists = ZO_IsIngameUI,
            valueFormat = "%.6f",
            minValue = GAMEPAD_CUSTOM_UI_SCALE_LOWER_BOUND,
            maxValue = GAMEPAD_CUSTOM_UI_SCALE_UPPER_BOUND,
            gamepadIsEnabledCallback = function() 
                return GetSetting(SETTING_TYPE_UI, UI_SETTING_USE_GAMEPAD_CUSTOM_SCALE) ~= "0"
            end,
        },
    },

    [SETTING_TYPE_CUSTOM] =
    {
        [OPTIONS_CUSTOM_SETTING_SCREEN_ADJUST] =
        {
            controlType = OPTIONS_INVOKE_CALLBACK,
            system = SETTING_TYPE_CUSTOM,
            panel = SETTING_PANEL_VIDEO,
            settingId = OPTIONS_CUSTOM_SETTING_SCREEN_ADJUST,
            text = SI_SETTING_SHOW_SCREEN_ADJUST,
            exists = ZO_IsConsoleOrHeronUI,
            gamepadIsEnabledCallback = function() 
                -- only allow resizing once the previous one has been completed.
                return not IsGUIResizing()
            end,
            disabledText = SI_SETTING_SHOW_SCREEN_ADJUST_DISABLED,
            callback = function()
                SCENE_MANAGER:Push("screenAdjust")
            end,
            customResetToDefaultsFunction = function()
                SetOverscanOffsets(0, 0, 0, 0)
            end
        },

        [OPTIONS_CUSTOM_SETTING_GAMMA_ADJUST] =
        {
            controlType = OPTIONS_INVOKE_CALLBACK,
            system = SETTING_TYPE_CUSTOM,
            panel = SETTING_PANEL_VIDEO,
            settingId = OPTIONS_CUSTOM_SETTING_GAMMA_ADJUST,
            text = SI_VIDEO_OPTIONS_CALIBRATE_GAMMA,
            gamepadTextOverride = SI_GAMMA_MAIN_TEXT,
            callback = function()
                SCENE_MANAGER:Push("gammaAdjust")
            end,
            customResetToDefaultsFunction = function()
                ResetSettingToDefault(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_GAMMA_ADJUSTMENT)
            end
        },

        [OPTIONS_CUSTOM_SETTING_SCREENSHOT_MODE] =
        {
            controlType = OPTIONS_INVOKE_CALLBACK,
            system = SETTING_TYPE_CUSTOM,
            panel = SETTING_PANEL_VIDEO,
            settingId = OPTIONS_CUSTOM_SETTING_SCREENSHOT_MODE,
            text = SI_SETTING_ENTER_SCREENSHOT_MODE,
            tooltipText = SI_SETTING_ENTER_SCREENSHOT_MODE_TOOLTIP,
            callback = function()
                            SCREENSHOT_MODE_GAMEPAD:Show()
                        end,
        },
    },
}

--Dynamically determine which console render quality settings are allowed on this system
local renderQualitySetting = ZO_OptionsPanel_Video_ControlData[SETTING_TYPE_GRAPHICS][GRAPHICS_SETTING_CONSOLE_ENHANCED_RENDER_QUALITY]
renderQualitySetting.valid = {}
for settingValue = CONSOLE_ENHANCED_RENDER_QUALITY_ITERATION_BEGIN, CONSOLE_ENHANCED_RENDER_QUALITY_ITERATION_END do
    if DoesSystemSupportConsoleEnhancedRenderQuality(settingValue) then
        table.insert(renderQualitySetting.valid, settingValue)
    end
end

ZO_SharedOptions.AddTableToPanel(SETTING_PANEL_VIDEO, ZO_OptionsPanel_Video_ControlData)
