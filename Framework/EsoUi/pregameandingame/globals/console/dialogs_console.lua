--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ESO_Dialogs["REQUESTING_ACCOUNT_DATA"] = 
{
    canQueue = true,
    mustChoose = true,
    setup = function(dialog)
        dialog:setupFunc()
    end,

    gamepadInfo =
    {
        dialogType = GAMEPAD_DIALOGS.COOLDOWN,
    },
    title =
    {
        text = GetString("SI_SETTINGSYSTEMPANEL", SETTING_PANEL_ACCOUNT),
    },
    mainText = 
    {
        text = "",
    },
    loading = 
    {
        text = GetString(SI_INTERFACE_OPTIONS_DEFERRED_LOADING_TEXT),
    },
}