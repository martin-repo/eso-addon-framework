--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local function SetupMainText(dialog, data)
    --ZO_OverflowDialogModalUnderlay:SetHidden(true)
    GetControl(dialog, "MainText"):SetText(zo_strformat(SI_OVERFLOW_DIALOG_TEXT, ZO_FormatTimeMilliseconds(data.waitTime, TIME_FORMAT_STYLE_DESCRIPTIVE)))
end

local function OverflowDialogInitialize(dialogControl)
    ZO_Dialogs_RegisterCustomDialog("PROVIDE_OVERFLOW_RESPONSE",
    {
        customControl = dialogControl,
        setup = SetupMainText,
        mustChoose = true,
        title =
        {
            text = SI_OVERFLOW_DIALOG_TITLE,
        },
        buttons =
        {
            {
                control = GetControl(dialogControl, "Cancel"),
                text = SI_OVERFLOW_DIALOG_CANCEL_BUTTON,
                keybind = false,
                callback =  function(dialog)
                                CancelLogin()
                                PregameStateManager_SetState("AccountLogin")
                            end,
            },

            {
                control = GetControl(dialogControl, "Overflow"),
                text = SI_OVERFLOW_DIALOG_OVERFLOW_BUTTON,
                keybind = false,
                callback =  function(dialog)
                                RespondToOverflowPrompt(true)
                                PregameStateManager_ShowLoginRequested()
                            end,
            },

            {
                control = GetControl(dialogControl, "Queue"),
                text = SI_OVERFLOW_DIALOG_QUEUE_BUTTON,
                keybind = false,
                callback =  function(dialog)
                                RespondToOverflowPrompt(false)
                                PregameStateManager_ShowLoginRequested()
                            end,
            },
        }                                   
    })
end

function ZO_OverflowDialogInitialize(self)
    OverflowDialogInitialize(self)
end