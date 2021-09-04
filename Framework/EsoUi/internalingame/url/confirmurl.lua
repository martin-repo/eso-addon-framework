--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_Dialogs_RegisterCustomDialog(
        "CONFIRM_UNSAFE_URL",
        {
            gamepadInfo =
            {
                dialogType = GAMEPAD_DIALOGS.BASIC,
            },
            title =
            {
                text = SI_CONFIRM_UNSAFE_URL_TITLE,
            },
            mainText =
            {
                text = SI_CONFIRM_UNSAFE_URL_TEXT,
            },
            buttons =
            {
                [1] =
                {
                    text = SI_DIALOG_YES,
                    callback =  function(dialog)
                                    ConfirmOpenURL(dialog.data.URL)
                                end,
                },
        
                [2] =
                {
                    text = SI_DIALOG_NO,
                }
            }
        }
    )

EVENT_MANAGER:RegisterForEvent("ZoConfirmURL", EVENT_CONFIRM_UNSAFE_URL, function(eventCode, URL)
    ZO_Dialogs_ReleaseDialog("CONFIRM_UNSAFE_URL")
    ZO_Dialogs_ShowPlatformDialog("CONFIRM_UNSAFE_URL", { URL = URL }, {mainTextParams = { URL }})
end)