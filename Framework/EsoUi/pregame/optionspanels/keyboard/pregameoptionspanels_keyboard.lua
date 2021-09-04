--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

KEYBOARD_OPTIONS:AddUserPanel(SETTING_PANEL_VIDEO, GetString("SI_SETTINGSYSTEMPANEL", SETTING_PANEL_VIDEO))
KEYBOARD_OPTIONS:AddUserPanel(SETTING_PANEL_AUDIO, GetString("SI_SETTINGSYSTEMPANEL", SETTING_PANEL_AUDIO))
KEYBOARD_OPTIONS:AddUserPanel(SETTING_PANEL_ACCOUNT, GetString("SI_SETTINGSYSTEMPANEL", SETTING_PANEL_ACCOUNT), nil, IsAccountLoggedIn)
