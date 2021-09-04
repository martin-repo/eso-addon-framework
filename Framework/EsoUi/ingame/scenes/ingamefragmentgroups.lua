--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

FRAGMENT_GROUP =
{
    MOUSE_DRIVEN_UI_WINDOW =
    {
        MOUSE_UI_MODE_FRAGMENT,
        KEYBIND_STRIP_FADE_FRAGMENT,
        KEYBIND_STRIP_MUNGE_BACKDROP_FRAGMENT,
        UI_SHORTCUTS_ACTION_LAYER_FRAGMENT,
        CLEAR_CURSOR_FRAGMENT,
        UI_COMBAT_OVERLAY_FRAGMENT,
        END_IN_WORLD_INTERACTIONS_FRAGMENT,
    },

    MOUSE_DRIVEN_UI_WINDOW_NO_COMBAT_OVERLAY =
    {
        MOUSE_UI_MODE_FRAGMENT,
        KEYBIND_STRIP_FADE_FRAGMENT,
        UI_SHORTCUTS_ACTION_LAYER_FRAGMENT,
        CLEAR_CURSOR_FRAGMENT,
        END_IN_WORLD_INTERACTIONS_FRAGMENT,
    },

    MOUSE_DRIVEN_UI_WINDOW_NO_KEYBIND_STRIP =
    {
        MOUSE_UI_MODE_FRAGMENT,
        UI_SHORTCUTS_ACTION_LAYER_FRAGMENT,
        CLEAR_CURSOR_FRAGMENT,
        UI_COMBAT_OVERLAY_FRAGMENT,
        END_IN_WORLD_INTERACTIONS_FRAGMENT,
    },

    GAMEPAD_DRIVEN_UI_WINDOW =
    {
        MOUSE_UI_MODE_FRAGMENT, --still need this as it blocks clicks from becoming attacks
        GAMEPAD_UI_MODE_FRAGMENT,
        KEYBIND_STRIP_GAMEPAD_FRAGMENT,
        KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT,
        UI_SHORTCUTS_ACTION_LAYER_FRAGMENT,
        CLEAR_CURSOR_FRAGMENT,
        UI_COMBAT_OVERLAY_FRAGMENT,
        END_IN_WORLD_INTERACTIONS_FRAGMENT,
        HIDE_MOUSE_FRAGMENT,
    },

    GAMEPAD_DRIVEN_UI_NO_KEYBIND_BACKGROUND_WINDOW =
    {
        MOUSE_UI_MODE_FRAGMENT, --still need this as it blocks clicks from becoming attacks
        GAMEPAD_UI_MODE_FRAGMENT,
        KEYBIND_STRIP_GAMEPAD_FRAGMENT,
        UI_SHORTCUTS_ACTION_LAYER_FRAGMENT,
        CLEAR_CURSOR_FRAGMENT,
        UI_COMBAT_OVERLAY_FRAGMENT,
        END_IN_WORLD_INTERACTIONS_FRAGMENT,
        HIDE_MOUSE_FRAGMENT,
    },

    FRAME_TARGET_CENTERED =
    {
        FRAME_TARGET_CENTERED_FRAGMENT,
        FRAME_TARGET_BLUR_CENTERED_FRAGMENT,
        FRAME_PLAYER_FRAGMENT,
    },

    FRAME_TARGET_CENTERED_NO_BLUR =
    {
        FRAME_TARGET_CENTERED_FRAGMENT,
        FRAME_PLAYER_FRAGMENT,
    },

    FRAME_TARGET_STANDARD_RIGHT_PANEL =
    {
        FRAME_TARGET_STANDARD_RIGHT_PANEL_FRAGMENT,
        FRAME_TARGET_BLUR_STANDARD_RIGHT_PANEL_FRAGMENT,
        FRAME_PLAYER_FRAGMENT,
    },

    FRAME_TARGET_STANDARD_RIGHT_PANEL_MEDIUM_LEFT_PANEL =
    {
        FRAME_TARGET_STANDARD_RIGHT_PANEL_MEDIUM_LEFT_PANEL_FRAGMENT,
        FRAME_TARGET_BLUR_STANDARD_RIGHT_PANEL_MEDIUM_LEFT_PANEL_FRAGMENT,
        FRAME_PLAYER_FRAGMENT,
    },

    FRAME_TARGET_FURNITURE_BROWSER_NO_BLUR =
    {
        FRAME_TARGET_FURNITURE_BROWSER_FRAGMENT,
        FRAME_PLAYER_FRAGMENT,
    },

    FRAME_TARGET_CENTERED_UNIFORM_BLUR =
    {
        FRAME_TARGET_CENTERED_FRAGMENT,
        FRAME_PLAYER_FRAGMENT,
        UNIFORM_BLUR_FRAGMENT,
    },

    FRAME_TARGET_OPTIONS =
    {
        FRAME_TARGET_OPTIONS_FRAGMENT,
        FRAME_PLAYER_FRAGMENT,
    },

    FRAME_TARGET_GAMEPAD =
    {
        FRAME_TARGET_GAMEPAD_FRAGMENT,
        FRAME_TARGET_BLUR_GAMEPAD_FRAGMENT,
        FRAME_PLAYER_FRAGMENT,
    },

    FRAME_TARGET_GAMEPAD_OPTIONS =
    {
        FRAME_TARGET_GAMEPAD_OPTIONS_FRAGMENT,
        FRAME_PLAYER_FRAGMENT,
    },

    FRAME_TARGET_GAMEPAD_LEFT =
    {
        FRAME_TARGET_LEFT_GAMEPAD_FRAGMENT,
        FRAME_TARGET_LEFT_BLUR_GAMEPAD_FRAGMENT,
        FRAME_PLAYER_FRAGMENT,
    },

    READ_ONLY_EQUIPPED_ITEMS =
    {
        THIN_LEFT_PANEL_BG_FRAGMENT,
        READ_ONLY_CHARACTER_WINDOW_FRAGMENT,
        CHARACTER_WINDOW_HEADER_FRAGMENT,
    },

    PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT = 
    {
        PLAYER_PROGRESS_BAR_FRAGMENT,
        PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT,
    },

    PLAYER_PROGRESS_BAR_GAMEPAD = 
    {
        PLAYER_PROGRESS_BAR_FRAGMENT,
        PLAYER_PROGRESS_BAR_GAMEPAD_NAME_LOCATION_ANCHOR_FRAGMENT,
    },

    PLAYER_PROGRESS_BAR_GAMEPAD_CURRENT = 
    {
        PLAYER_PROGRESS_BAR_FRAGMENT,
        PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT,
        PLAYER_PROGRESS_BAR_GAMEPAD_NAME_LOCATION_ANCHOR_FRAGMENT,
    },

    FRAME_TARGET_GAMEPAD_RIGHT =
    {
        FRAME_TARGET_GAMEPAD_RIGHT_FRAGMENT,
        FRAME_TARGET_BLUR_GAMEPAD_RIGHT_FRAGMENT,
        FRAME_PLAYER_FRAGMENT,
    },

    FRAME_TARGET_GAMEPAD_RIGHT_FURTHER_AWAY =
    {
        FRAME_TARGET_GAMEPAD_RIGHT_FRAGMENT,
        FRAME_TARGET_DISTANCE_GAMEPAD_FAR_FRAGMENT,
        FRAME_TARGET_BLUR_GAMEPAD_RIGHT_FRAGMENT,
        FRAME_PLAYER_FRAGMENT,
    },

    GAMEPAD_ACTIVITY_FINDER_DEPENDENCIES =
    {
        GAMEPAD_GROUP_ROLES_FRAGMENT,
        GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT,
        MINIMIZE_CHAT_FRAGMENT,
        GAMEPAD_MENU_SOUND_FRAGMENT,
        GAMEPAD_ACTIVITY_QUEUE_DATA_FRAGMENT,
        GAMEPAD_GENERIC_FOOTER_FRAGMENT,
    },

    HOUSING_EDITOR_HUD =
    {
        HOUSING_EDITOR_HUD_ACTION_LAYER_FRAGMENT,
        UNIT_FRAMES_FRAGMENT,
        COMPASS_FRAME_FRAGMENT
    },

    KEYBOARD_KEYBIND_STRIP_GROUP =
    {
        KEYBIND_STRIP_MUNGE_BACKDROP_FRAGMENT,
        KEYBIND_STRIP_FADE_FRAGMENT,
    },

    GAMEPAD_KEYBIND_STRIP_GROUP =
    {
        KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT,
        KEYBIND_STRIP_GAMEPAD_FRAGMENT,
    },

    SUPRESS_COLLECTIBLES_GROUP =
    {
        SUPPRESS_COLLECTIBLE_NOTIFICATIONS_FRAGMENT,
        SUPPRESS_COLLECTIBLE_ANNOUNCEMENTS_FRAGMENT,
    },

    SIEGE_BAR_GROUP = 
    {
        SIEGE_ACTION_LAYER_FRAGMENT,
        SIEGE_HUD_FRAGMENT,
        PLAYER_PROGRESS_BAR_FRAGMENT,
        UNIT_FRAMES_FRAGMENT,
        PLAYER_ATTRIBUTE_BARS_FRAGMENT,
        COMPASS_FRAME_FRAGMENT,
        PERFORMANCE_METER_FRAGMENT,
    },

    BATTLEGROUND_SCOREBOARD_GROUP =
    {
        BATTLEGROUND_SCOREBOARD_FRAGMENT,
        UNIT_FRAMES_FRAGMENT,
        UI_COMBAT_OVERLAY_FRAGMENT,
    },

    BATTLEGROUND_MATCH_INFO_KEYBOARD_GROUP =
    {
        BATTLEGROUND_MATCH_INFO_KEYBOARD_FRAGMENT,
        THIN_TALL_RIGHT_PANEL_BG_FRAGMENT,
    },

    BATTLEGROUND_MATCH_INFO_GAMEPAD_GROUP =
    {
        BATTLEGROUND_MATCH_INFO_GAMEPAD_FRAGMENT,
        GAMEPAD_NAV_QUADRANT_4_BACKGROUND_FRAGMENT,
    },
}

ZO_GAMEPAD_DIALOG_FRAGMENT_GROUP = FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW
ZO_GAMEPAD_DIALOG_DONT_END_IN_WORLD_INTERACTIONS_FRAGMENT_GROUP = { }
for k, v in ipairs(ZO_GAMEPAD_DIALOG_FRAGMENT_GROUP) do
    if v ~= END_IN_WORLD_INTERACTIONS_FRAGMENT then
        table.insert(ZO_GAMEPAD_DIALOG_DONT_END_IN_WORLD_INTERACTIONS_FRAGMENT_GROUP, v)
    end
end
