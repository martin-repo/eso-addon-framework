--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local panelBuilder = ZO_KeyboardOptionsPanelBuilder:New(SETTING_PANEL_SOCIAL)

-----------------------------
-- Social -> Chat settings --
-----------------------------
panelBuilder:AddSetting({
    controlName = "Options_Social_TextSize",
    template = "ZO_Options_Slider",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_TEXT_SIZE,
    header = SI_SOCIAL_OPTIONS_CHAT_SETTINGS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_MinAlpha",
    template = "ZO_Options_Slider",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_MIN_ALPHA,
    header = SI_SOCIAL_OPTIONS_CHAT_SETTINGS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_UseProfanityFilter",
    settingType = SETTING_TYPE_LANGUAGE,
    settingId = LANGUAGE_SETTING_USE_PROFANITY_FILTER,
    header = SI_SOCIAL_OPTIONS_CHAT_SETTINGS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ReturnCursorOnChatFocus",
    settingType = SETTING_TYPE_UI,
    settingId = UI_SETTING_RETURN_CURSOR_ON_CHAT_FOCUS,
    header = SI_SOCIAL_OPTIONS_CHAT_SETTINGS,
})

-----------------------------
-- Social -> Notifications --
-----------------------------
panelBuilder:AddSetting({
    controlName = "Options_Social_LeaderboardsNotification",
    settingType = SETTING_TYPE_UI,
    settingId = UI_SETTING_SHOW_LEADERBOARD_NOTIFICATIONS,
    header = SI_SOCIAL_OPTIONS_NOTIFICATIONS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_AutoDeclineDuelInvites",
    settingType = SETTING_TYPE_UI,
    settingId = UI_SETTING_AUTO_DECLINE_DUEL_INVITES,
    header = SI_SOCIAL_OPTIONS_NOTIFICATIONS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_AvANotifications",
    settingType = SETTING_TYPE_UI,
    settingId = UI_SETTING_SHOW_AVA_NOTIFICATIONS,
    header = SI_SOCIAL_OPTIONS_NOTIFICATIONS,
})

---------------------------
-- Social -> Chat Colors --
---------------------------
panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Say",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_SAY,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Yell",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_YELL,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_WhisperIncoming",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_WHISPER_INC,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_WhisperOutgoing",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_WHISPER_OUT,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Group",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_GROUP,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Zone",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_ZONE,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Zone_English",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_ZONE_ENG,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Zone_French",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_ZONE_FRA,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Zone_German",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_ZONE_GER,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Zone_Japanese",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_ZONE_JPN,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Zone_Russian",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_ZONE_RUS,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_NPC",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_NPC,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Emote",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_EMOTE,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_System",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_SYSTEM,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_Guild1Title",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_TITLE_GUILD1,
    template = "ZO_Options_Social_GuildLabel",
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Guild1",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_GUILD1,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Officer1",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_OFFICER1,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_Guild2Title",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_TITLE_GUILD2,
    template = "ZO_Options_Social_GuildLabel",
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Guild2",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_GUILD2,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Officer2",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_OFFICER2,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_Guild3Title",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_TITLE_GUILD3,
    template = "ZO_Options_Social_GuildLabel",
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Guild3",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_GUILD3,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Officer3",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_OFFICER3,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_Guild4Title",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_TITLE_GUILD4,
    template = "ZO_Options_Social_GuildLabel",
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Guild4",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_GUILD4,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Officer4",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_OFFICER4,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_Guild5Title",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_TITLE_GUILD5,
    template = "ZO_Options_Social_GuildLabel",
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Guild5",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_GUILD5,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})

panelBuilder:AddSetting({
    controlName = "Options_Social_ChatColor_Officer5",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_OFFICER5,
    header = SI_SOCIAL_OPTIONS_CHAT_COLORS,
})
