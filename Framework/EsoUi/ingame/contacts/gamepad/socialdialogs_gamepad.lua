--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local function SetupRequestEntry(control, data, selected, reselectingDuringRebuild, enabled, active)
    local isValid = enabled
    if data.validInput then
        isValid = data.validInput()
        data.disabled = not isValid
        data:SetEnabled(isValid)
    end

    ZO_SharedGamepadEntry_OnSetup(control, data, selected, reselectingDuringRebuild, isValid, active)
end

local function IsValidInput(inputString)
    return inputString and inputString ~= ""
end

local function SetActiveEdit(dialog)
    local data = dialog.entryList:GetTargetData()
    local edit = data.control.editBoxControl

    edit:TakeFocus()
end

local function ReleaseDialog(dialogName)
    ZO_Dialogs_ReleaseDialogOnButtonPress(dialogName)
end

local function PrimaryButtonCallback(dialog)
    local targetData = dialog.entryList:GetTargetData()
    if(targetData and targetData.callback) then
        targetData.callback(dialog)
    end
end

local function IsButtonEnabled(dialog, localizedString, textEntryValue)
    local isEnabled = true

    local targetData = dialog.entryList:GetTargetData()
    if targetData.text == GetString(localizedString) then
        isEnabled = IsValidInput(textEntryValue)
    end

    return isEnabled
end

-------------------
-- ZO_GamepadSocialDialogs object
-------------------

local ZO_GamepadSocialDialogs = ZO_InitializingObject:Subclass()

function ZO_GamepadSocialDialogs:Initialize()
    self:InitializeSocialOptionsDialog()
    self:InitializeEditNoteDialog()
    self:InitializeAddFriendDialog()
    self:InitializeAddIgnoreDialog()
    self:InitializeInviteMemberDialog()
    self:InitializeGroupInviteDialog()
end

-------------------
-- Social Options
-------------------

function ZO_GamepadSocialDialogs:InitializeSocialOptionsDialog()
    local dialogName = "GAMEPAD_SOCIAL_OPTIONS_DIALOG"

    local finishedCallback = nil

    ZO_Dialogs_RegisterCustomDialog(dialogName,
    {
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
            local data = dialog.data
            if data.setupFunction then
                data.setupFunction(dialog)
            end

            dialog.info.parametricList = data.parametricList
            finishedCallback = nil
            dialog:setupFunc()
        end,
        finishedCallback = function(dialog)
            if finishedCallback then
                finishedCallback()
            end
        end,
        title =
        {
            text = SI_GAMEPAD_CONTACTS_OPTIONS_TITLE,
        },
        blockDialogReleaseOnPress = true,
        buttons =
        {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback =  function(dialog)
                    local data = dialog.entryList:GetTargetData()
                    if data.callback then
                        data.callback()
                    end
                    finishedCallback = data.finishedCallback
                    ReleaseDialog(dialogName)
                end,
            },

            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback = function()
                    ReleaseDialog(dialogName)
                end,
            },
        }
    })

end

-------------------
-- Edit Note
-------------------

function ZO_GamepadSocialDialogs:InitializeEditNoteDialog()
    local dialogName = "GAMEPAD_SOCIAL_EDIT_NOTE_DIALOG"
    local parametricDialog = ZO_GenericGamepadDialog_GetControl(GAMEPAD_DIALOGS.PARAMETRIC)

    ZO_Dialogs_RegisterCustomDialog(dialogName,
    {
        gamepadInfo = 
        {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        canQueue = true,
        setup = function(dialog)
            dialog:setupFunc()
        end,

        title =
        {
            text = SI_EDIT_NOTE_DIALOG_TITLE,
        },
        parametricList =
        {
            -- note
            {
                template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem",
                templateData = {
                    nameField = true,
                    textChangedCallback = function(control)
                        parametricDialog.data.note = control:GetText()
                    end,

                    setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
                        control.highlight:SetHidden(not selected)
                        control.editBoxControl.textChangedCallback = data.textChangedCallback
                        control.editBoxControl:SetMaxInputChars(254)
                        ZO_EditDefaultText_Initialize(control.editBoxControl, GetString(SI_EDIT_NOTE_DEFAULT_TEXT))
                        if parametricDialog.data.note then
                            control.editBoxControl:SetText(parametricDialog.data.note)
                        end
                        data.control = control
                    end,
                    callback = function(dialog)
                        SetActiveEdit(dialog)
                    end,
                },
            },

            -- save
            {
                template = "ZO_GamepadTextFieldSubmitItem",
                templateData = {
                    text = GetString(SI_GAMEPAD_CONTACTS_EDIT_NOTE_CONFIRM),
                    setup = SetupRequestEntry,
                    callback = function(dialog)
                        if dialog.data.noteChangedCallback then
                            dialog.data.noteChangedCallback(dialog.data.displayName, dialog.data.note)
                            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, SI_GAMEPAD_CONTACTS_NOTE_SAVED)
                            ReleaseDialog(dialogName)
                        end
                    end,
                },
            },
        },
        blockDialogReleaseOnPress = true,
        buttons =
        {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = function(dialog)
                    PrimaryButtonCallback(dialog)
                end,
            },

            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback = function()
                    ReleaseDialog(dialogName)
                end,
            },
        }
    })

end

-------------------
-- Add Friend
-------------------

function ZO_GamepadSocialDialogs:InitializeAddFriendDialog()
    local dialogName = "GAMEPAD_SOCIAL_ADD_FRIEND_DIALOG"

    local nameText = ""
    local noteText = ""

    local userIdControl = nil
    local messageControl = nil

    local function ReleaseAddFriendDialog()
        userIdControl.editBoxControl.isInScreen = false
        if messageControl then
            messageControl.editBoxControl.isInScreen = false
        end
        ReleaseDialog(dialogName)
    end

    --What's in the list varies based on platform
    local friendParametricList = 
    {
        -- user name
        {
            template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem",
            templateData = {
                textChangedCallback = function(control) 
                    nameText = control:GetText()
                end,
                setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
                    control.highlight:SetHidden(not selected)

                    userIdControl = control
                    control.editBoxControl.textChangedCallback = data.textChangedCallback
                    control.editBoxControl.isInScreen = true
                    data.control = control

                    if nameText == "" then
                        ZO_EditDefaultText_Initialize(control.editBoxControl, ZO_GetInviteInstructions())
                        control.resetFunction = function()
                            control.editBoxControl.textChangedCallback = nil
                            if not control.editBoxControl.isInScreen then
                                control.editBoxControl:SetText("")
                            end
                        end
                    else
                        control.editBoxControl:SetText(nameText)
                    end
                end,
                callback = function(dialog)
                    SetActiveEdit(dialog)
                end,
            },
        },
        -- request
        {
            template = "ZO_GamepadTextFieldSubmitItem",
            templateData = {
                text = GetString(SI_GAMEPAD_REQUEST_OPTION),
                setup = SetupRequestEntry,
                callback = function(dialog)
                    if IsValidInput(nameText) then
                        RequestFriend(ZO_FormatManualNameEntry(nameText), noteText)
                        ReleaseAddFriendDialog()
                    end
                end,
                validInput = function()
                    return IsValidInput(nameText)
                end,
            }
        },
    }

    if not IsConsoleUI() then
        table.insert(friendParametricList, 2, 
        -- note
        {
            template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem",
            templateData = {
                textChangedCallback = function(control) 
                    noteText = control:GetText()
                end,
                setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
                    control.highlight:SetHidden(not selected)

                    messageControl = control
                    control.editBoxControl.textChangedCallback = data.textChangedCallback
                    control.editBoxControl.isInScreen = true
                    data.control = control

                    if noteText == "" then
                        ZO_EditDefaultText_Initialize(control.editBoxControl, GetString(SI_REQUEST_FRIEND_MESSAGE_DEFAULT_TEXT))
                        control.resetFunction = function()
                            control.editBoxControl.textChangedCallback = nil
                            if not control.editBoxControl.isInScreen then
                                control.editBoxControl:SetText("")
                            end
                        end
                    end
                end,
                callback = function(dialog)
                    SetActiveEdit(dialog)
                end,
            },
            visible = IsConsoleUI,
        })
    end

    ZO_Dialogs_RegisterCustomDialog(dialogName,
    {
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        canQueue = true,
        setup = function(dialog)
            if dialog.data then
                nameText = dialog.data.displayName
            else
                nameText = ""
            end
            dialog:setupFunc()
        end,

        title =
        {
            text = SI_REQUEST_FRIEND_DIALOG_TITLE,
        },

        parametricList = friendParametricList,

        blockDialogReleaseOnPress = true,
        buttons =
        {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = function(dialog)
                    PrimaryButtonCallback(dialog)
                end,
                enabled = function(dialog)
                    return IsButtonEnabled(dialog, SI_GAMEPAD_REQUEST_OPTION, nameText)
                end,
            },

            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback =  function(dialog)
                    ReleaseAddFriendDialog()
                end,
            },
        }
    })

end

-------------------
-- Add Ignore
-------------------

function ZO_GamepadSocialDialogs:InitializeAddIgnoreDialog()
    local dialogName = "GAMEPAD_SOCIAL_ADD_IGNORE_DIALOG"
    local parametricDialog = ZO_GenericGamepadDialog_GetControl(GAMEPAD_DIALOGS.PARAMETRIC)

    local nameText = ""

    ZO_Dialogs_RegisterCustomDialog(dialogName,
    {
        gamepadInfo = 
        {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        canQueue = true,
        setup = function(dialog)
            dialog:setupFunc()
        end,
        title =
        {
            text = SI_PROMPT_TITLE_ADD_IGNORE,
        },
        parametricList =
        {
            -- user name
            {
                template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem",
                templateData = {
                    nameField = true,
                    textChangedCallback = function(control) 
                        nameText = control:GetText()
                    end,
                    setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
                        control.highlight:SetHidden(not selected)

                        control.editBoxControl.textChangedCallback = data.textChangedCallback
                        data.control = control

                        if parametricDialog.data and data.nameField then
                            control.editBoxControl:SetText(parametricDialog.data.displayName)
                        else
                            local validInput = IsValidInput(nameText)
                            if validInput then
                                control.editBoxControl:SetText(nameText)
                            else
                                ZO_EditDefaultText_Initialize(control.editBoxControl, ZO_GetInviteInstructions())
                            end
                        end
                    end,
                    callback = function(dialog)
                        SetActiveEdit(dialog)
                    end,
                },
            },
             -- ignore
            {
                template = "ZO_GamepadTextFieldSubmitItem",
                templateData = {
                    text = GetString(SI_FRIEND_MENU_IGNORE),
                    setup = SetupRequestEntry,
                    callback = function(dialog)
                        if IsValidInput(nameText) then
                            AddIgnore(nameText)
                            ReleaseDialog(dialogName)
                        end
                    end,
                    validInput = function()
                        return IsValidInput(nameText)
                    end,
                }
            },
        },
        blockDialogReleaseOnPress = true,
        buttons =
        {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = function(dialog)
                    PrimaryButtonCallback(dialog)
                end,
                enabled = function(dialog)
                    return IsButtonEnabled(dialog, SI_FRIEND_MENU_IGNORE, nameText)
                end,
            },

            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback =  function(dialog)
                    ReleaseDialog(dialogName)
                end,
            },
        }
    })

end

----------------------
-- Add Member To Guild
----------------------

function ZO_GamepadSocialDialogs:InitializeInviteMemberDialog()
    local dialogName = "GAMEPAD_GUILD_INVITE_DIALOG"
    local nameText = ""

    ZO_Dialogs_RegisterCustomDialog(dialogName,
    {
        gamepadInfo = 
        {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
            nameText = ""
            dialog:setupFunc()
        end,

        title =
        {
            text = SI_PROMPT_TITLE_GUILD_INVITE,
        },
        parametricList =
        {
            -- user name
            {
                template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem",
                templateData = {
                    textChangedCallback = function(control) 
                        nameText = control:GetText()
                    end,
                    setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
                        control.highlight:SetHidden(not selected)
                        control.editBoxControl.textChangedCallback = data.textChangedCallback
                        data.control = control

                        local validInput = IsValidInput(nameText)
                        if validInput then
                            control.editBoxControl:SetText(nameText)
                        else
                            ZO_EditDefaultText_Initialize(control.editBoxControl, ZO_GetInviteInstructions())
                        end
                    end,
                    callback = function(dialog)
                        SetActiveEdit(dialog)
                    end,
                },
            },

            -- add
            {
                template = "ZO_GamepadTextFieldSubmitItem",
                templateData = {
                    text = GetString(SI_GAMEPAD_REQUEST_OPTION),
                    setup = SetupRequestEntry,
                    callback = function(dialog)
                        if IsValidInput(nameText) then
                            local guildId = dialog.data.guildId
                            ZO_TryGuildInvite(guildId, ZO_FormatManualNameEntry(nameText))
                            ReleaseDialog(dialogName)
                        end
                    end,
                    validInput = function()
                        return IsValidInput(nameText)
                    end,
                }
            },            
        },
        blockDialogReleaseOnPress = true,
        buttons =
        {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = function(dialog)
                    PrimaryButtonCallback(dialog)
                end,
                enabled = function(dialog)
                    return IsButtonEnabled(dialog, SI_GAMEPAD_REQUEST_OPTION, nameText)
                end,
            },

            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback =  function(dialog)
                    ReleaseDialog(dialogName)
                end,
            },
        }
    })
end

----------------------
-- Group Invite
----------------------

function ZO_GamepadSocialDialogs:InitializeGroupInviteDialog()
    local dialogName = "GAMEPAD_GROUP_INVITE_DIALOG"
    local nameText = ""

    ZO_Dialogs_RegisterCustomDialog(dialogName,
    {
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
            nameText = ""
            dialog:setupFunc()
        end,

        title =
        {
            text = SI_GROUP_WINDOW_INVITE_PLAYER,
        },
        parametricList =
        {
            -- user name
            {
                template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem",
                templateData = {
                    textChangedCallback = function(control) 
                        nameText = control:GetText()
                    end,
                    setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
                        control.highlight:SetHidden(not selected)

                        control.editBoxControl.textChangedCallback = data.textChangedCallback
                        data.control = control

                        local validInput = IsValidInput(nameText)
                        if validInput then
                            control.editBoxControl:SetText(nameText)
                        else
                            ZO_EditDefaultText_Initialize(control.editBoxControl, ZO_GetInviteInstructions())
                        end
                    end,
                    callback = function(dialog)
                        SetActiveEdit(dialog)
                    end,
                },
            },

            -- invite
            {
                template = "ZO_GamepadTextFieldSubmitItem",
                templateData = {
                    text = GetString(SI_GAMEPAD_REQUEST_OPTION),
                    setup = SetupRequestEntry,
                    callback = function(dialog)
                        if IsValidInput(nameText) then
                            local NOT_SENT_FROM_CHAT = false
                            local DISPLAY_INVITED_MESSAGE = true
                            TryGroupInviteByName(ZO_FormatManualNameEntry(nameText), NOT_SENT_FROM_CHAT, DISPLAY_INVITED_MESSAGE)
                            ReleaseDialog(dialogName)
                        end
                    end,
                    validInput = function()
                        return IsValidInput(nameText)
                    end,
                }
            },
        },
        blockDialogReleaseOnPress = true,
        buttons =
        {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = function(dialog)
                    PrimaryButtonCallback(dialog)
                end,
                enabled = function(dialog)
                    return IsButtonEnabled(dialog, SI_GAMEPAD_REQUEST_OPTION, nameText)
                end,
            },

            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback =  function(dialog)
                    ReleaseDialog(dialogName)
                end,
            },
        }
    })
end

-- A singleton that owns the dialogs
GAMEPAD_SOCIAL_DIALOGS = ZO_GamepadSocialDialogs:New()
