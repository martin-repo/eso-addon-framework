--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ESO_Dialogs["ACCOUNT_MANAGEMENT_REQUEST_FAILED"] =
{
    setup = function(dialog)
        dialog:setupFunc()
    end,
    canQueue = true,
    gamepadInfo =
    {
        dialogType = GAMEPAD_DIALOGS.BASIC,
    },
    title =
    {
        text = SI_ACCOUNT_MANAGEMENT_REQUEST_FAILED_TITLE,
    },
    mainText =
    {
        text = function(dialog)
            return dialog.data.mainText
        end,
    },
    buttons =
    {
        {
            text = SI_DIALOG_CLOSE,
            keybind = "DIALOG_NEGATIVE",
        },
    }
}

ESO_Dialogs["ACCOUNT_MANAGEMENT_ACTIVATION_EMAIL_SENT"] =
{
    setup = function(dialog)
        dialog:setupFunc()
    end,
    canQueue = true,
    gamepadInfo =
    {
        dialogType = GAMEPAD_DIALOGS.BASIC,
    },
    title =
    {
        text = SI_ACCOUNT_MANAGEMENT_ACTIVATION_EMAIL_SENT_DIALOG_TITLE,
    },
    mainText =
    {
        text = function(dialog)
            return zo_strformat(SI_ACCOUNT_MANAGEMENT_ACTIVATION_EMAIL_SENT_DIALOG_BODY, GetUserPendingActivationEmailAddress());
        end,
    },
    buttons =
    {
        {
            text = SI_DIALOG_CLOSE,
            keybind = "DIALOG_NEGATIVE",
        },
    }
}

ESO_Dialogs["ACCOUNT_MANAGEMENT_EMAIL_CHANGED"] =
{
    canQueue = true,
    gamepadInfo =
    {
        dialogType = GAMEPAD_DIALOGS.BASIC,
    },
    title =
    {
        text = SI_ACCOUNT_MANAGEMENT_EMAIL_CHANGED_SUCCESS_DIALOG_TITLE,
    },
    mainText =
    {
        text = function(dialog)
            return zo_strformat(GetString("SI_ACCOUNTEMAILREQUESTRESULT", ACCOUNT_EMAIL_REQUEST_RESULT_SUCCESS_EMAIL_UPDATED), GetUserPendingActivationEmailAddress());
        end,
    },
    buttons =
    {
        {
            text = SI_OK,
        },
    }
}
