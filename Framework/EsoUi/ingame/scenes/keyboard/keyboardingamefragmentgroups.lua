--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_RESTYLE_SHEETS_KEYBOARD_FRAGMENT_GROUP = 
{
    RESTYLE_PREVIEW_OPTIONS_FRAGMENT,
    ITEM_PREVIEW_KEYBOARD:GetFragment(),
    MEDIUM_LEFT_PANEL_BG_FRAGMENT,
    ZO_RESTYLE_SHEET_WINDOW_FRAGMENT,
    MINIMIZE_CHAT_FRAGMENT,
}

WRIT_ADVISOR_KEYBOARD_FRAGMENT_GROUP =
{
    WRIT_ADVISOR_FRAGMENT,
    WRIT_ADVISOR_HEADER_FRAGMENT,
    MEDIUM_LEFT_PANEL_BG_FRAGMENT
}

HELP_TUTORIALS_KEYBOARD_FRAGMENT_GROUP_BASE =
{
    HELP_TUTORIALS_FRAGMENT,
    RIGHT_BG_FRAGMENT,
    TITLE_FRAGMENT,
    TREE_UNDERLAY_FRAGMENT,
    HELP_WINDOW_SOUNDS,
}

ADVANCED_STATS_FRAGMENT_GROUP =
{
    ADVANCED_STATS_FRAGMENT, 
    RIGHT_BG_FRAGMENT
}

local helpModalUnderlayFragment = ZO_SimpleSceneFragment:New(HelpOverlayModal)
helpModalUnderlayFragment:RegisterCallback("StateChange", function(oldState, newState)
    local wasVisible = oldState ~= SCENE_FRAGMENT_HIDDEN
    local isVisible = newState ~= SCENE_FRAGMENT_HIDDEN
    if wasVisible ~= isVisible then
        HELP_MANAGER:OnOverlayVisibilityChanged(isVisible)
    end
end)

HELP_TUTORIALS_OVERLAY_KEYBOARD_FRAGMENT_GROUP = ZO_ShallowTableCopy(HELP_TUTORIALS_KEYBOARD_FRAGMENT_GROUP_BASE)
table.insert(HELP_TUTORIALS_OVERLAY_KEYBOARD_FRAGMENT_GROUP, helpModalUnderlayFragment)
table.insert(HELP_TUTORIALS_OVERLAY_KEYBOARD_FRAGMENT_GROUP, ZO_SetTitleFragment:New(SI_HELP_TUTORIALS))