--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local panelBuilder = ZO_KeyboardOptionsPanelBuilder:New(SETTING_PANEL_VIDEO)

----------------------
-- Video -> Display --
----------------------
panelBuilder:AddSetting({
    controlName = "Options_Video_DisplayMode",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_FULLSCREEN,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_DISPLAY,
    initializeControlFunction = function(control)
        ZO_OptionsWindow_InitializeControl(control)
        EVENT_MANAGER:RegisterForEvent("ZO_OptionsPanel_Video", EVENT_FULLSCREEN_MODE_CHANGED, function()
            ZO_Options_UpdateOption(control)
        end)
    end,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_ActiveDisplay",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_ACTIVE_DISPLAY,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_DISPLAY,
    initializeControlFunction = function(control)
        ZO_OptionsPanel_Video_InitializeDisplays(control)
        EVENT_MANAGER:RegisterForEvent("ZO_OptionsPanel_Video", EVENT_AVAILABLE_DISPLAY_DEVICES_CHANGED, function()
            ZO_OptionsPanel_Video_OnActiveDisplayChanged(control)
        end)
    end,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_Resolution",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_RESOLUTION,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_DISPLAY,
    initializeControlFunction = ZO_OptionsPanel_Video_InitializeResolution
})

panelBuilder:AddSetting({
    controlName = "Options_Video_VSync",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_VSYNC,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_DISPLAY,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_RenderThread",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_RENDER_THREAD,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_DISPLAY,
    template = "ZO_Options_Video_Checkbox_IncludeRestartWarning",
})

-- inline slider
panelBuilder:AddSetting({
    controlName = "Options_Video_Gamma_Adjustment",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_GAMMA_ADJUSTMENT,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_DISPLAY,
})

-- button to go to gamma adjustment screen
panelBuilder:AddSetting({
    controlName = "Options_Video_CalibrateGamma",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_GAMMA_ADJUST,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_DISPLAY,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_HDR_Brightness",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_HDR_BRIGHTNESS,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_DISPLAY,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_ScreenAdjust",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SCREEN_ADJUST,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_DISPLAY,
})

------------------------
-- Video -> Interface --
------------------------
panelBuilder:AddSetting({
    controlName = "Options_Video_UseCustomScale",
    settingType = SETTING_TYPE_UI,
    settingId = UI_SETTING_USE_CUSTOM_SCALE,
    header = SI_VIDEO_OPTIONS_INTERFACE,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_CustomScale",
    settingType = SETTING_TYPE_UI,
    settingId = UI_SETTING_CUSTOM_SCALE,
    header = SI_VIDEO_OPTIONS_INTERFACE,
    indentLevel = 1,
})

------------------------
-- Video -> Graphics  --
------------------------
panelBuilder:AddSetting({
    controlName = "Options_Video_Graphics_Quality",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_PRESETS,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_GRAPHICS,
    template = "ZO_Options_Video_Dropdown_IncludeApplyScreenWarning",
})

panelBuilder:AddSetting({
    controlName = "Options_Video_Texture_Resolution",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_MIP_LOAD_SKIP_LEVELS,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_GRAPHICS,
    template = "ZO_Options_Video_Dropdown_IncludeApplyScreenWarning",
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_AntiAliasing_Type",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_ANTIALIASING_TYPE,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_GRAPHICS,
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_Sub_Sampling",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_SUB_SAMPLING,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_GRAPHICS,
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_Shadows",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_SHADOWS,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_GRAPHICS,
    template = "ZO_Options_Video_Dropdown_IncludeApplyScreenWarning",
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_Screenspace_Water_Reflection_Quality",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_SCREENSPACE_WATER_REFLECTION_QUALITY,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_GRAPHICS,
    template = "ZO_Options_Video_Dropdown_IncludeApplyScreenWarning",
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_Planar_Water_Reflection_Quality",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_PLANAR_WATER_REFLECTION_QUALITY,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_GRAPHICS,
    template = "ZO_Options_Video_Dropdown_IncludeApplyScreenWarning",
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_Maximum_Particle_Systems",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_PFX_GLOBAL_MAXIMUM,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_GRAPHICS,
    indentLevel = 1,
    template = "ZO_Options_Video_Slider_IncludeMaxParticleSystemsWarning",
})

panelBuilder:AddSetting({
    controlName = "Options_Video_Particle_Suppression_Distance",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_PFX_SUPPRESS_DISTANCE,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_GRAPHICS,
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_View_Distance",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_VIEW_DISTANCE,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_GRAPHICS,
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_Ambient_Occlusion",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_AMBIENT_OCCLUSION_TYPE,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_GRAPHICS,
    template = "ZO_Options_Video_Dropdown_IncludeApplyScreenWarning",
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_Clutter_2D_Quality",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_CLUTTER_2D_QUALITY,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_GRAPHICS,
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_Depth_Of_Field_Mode",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_DEPTH_OF_FIELD_MODE,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_GRAPHICS,
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_Bloom",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_BLOOM,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_GRAPHICS,
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_Distortion",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_DISTORTION,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_GRAPHICS,
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_God_Rays",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_GOD_RAYS,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_GRAPHICS,
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Video_Show_Additional_Ally_Effects",
    settingType = SETTING_TYPE_GRAPHICS,
    settingId = GRAPHICS_SETTING_SHOW_ADDITIONAL_ALLY_EFFECTS,
    header = SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_GRAPHICS,
    indentLevel = 1,
})
