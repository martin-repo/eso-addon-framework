--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_Dialogs_RegisterCustomDialog(
        "CONFIRM_MAIL",
        {
            gamepadInfo =
            {
                dialogType = GAMEPAD_DIALOGS.BASIC,
            },
            title =
            {
                text = SI_CONFIRM_MAIL_TITLE,
            },
            mainText =
            {
                text = SI_CONFIRM_MAIL_TEXT,
            },
            buttons =
            {
                [1] =
                {
                    text = SI_DIALOG_YES,
                    callback =  function(dialog)
                                    ConfirmSendMail(ZO_FormatManualNameEntry(dialog.data.to), dialog.data.subject, dialog.data.body)
                                end,
                },
        
                [2] =
                {
                    text = SI_DIALOG_NO,
                    callback = function(dialog)
                                    CancelSendMail()
                               end,
                }
            }
        }
    )

EVENT_MANAGER:RegisterForEvent("ZoConfirmMail", EVENT_CONFIRM_SEND_MAIL, function(eventCode, to, subject, body, numAttachments, attachedMoney)
    ZO_Dialogs_ReleaseDialog("CONFIRM_MAIL")
    local confirmText
    if numAttachments > 0 and attachedMoney > 0 then
        confirmText = zo_strformat(SI_CONFIRM_MAIL_GOLD_AND_ITEMS, ZO_Currency_FormatPlatform(CURT_MONEY, attachedMoney, ZO_CURRENCY_FORMAT_WHITE_AMOUNT_ICON), numAttachments, ZO_FormatUserFacingDisplayName(to))
    elseif numAttachments > 0 then
        confirmText = zo_strformat(SI_CONFIRM_MAIL_ITEMS, numAttachments, ZO_FormatUserFacingDisplayName(to))
    else
        confirmText = zo_strformat(SI_CONFIRM_MAIL_GOLD, ZO_Currency_FormatPlatform(CURT_MONEY, attachedMoney, ZO_CURRENCY_FORMAT_WHITE_AMOUNT_ICON), ZO_FormatUserFacingDisplayName(to))
    end
    ZO_Dialogs_ShowPlatformDialog("CONFIRM_MAIL", { to = to, subject = subject, body = body }, {mainTextParams = { confirmText }})
end)