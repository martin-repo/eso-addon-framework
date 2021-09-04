--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

--Layout consts, defining the widths of the list's columns as provided by design--
ZO_GAMEPAD_GUILD_ROSTER_RANK_WIDTH = 90 - ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_HEADER_DOUBLE_PADDING_X
ZO_GAMEPAD_GUILD_ROSTER_USER_FACING_NAME_WIDTH = 310 - ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_HEADER_DOUBLE_PADDING_X
ZO_GAMEPAD_GUILD_ROSTER_CHARACTER_NAME_WIDTH = 165 - ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_HEADER_DOUBLE_PADDING_X
ZO_GAMEPAD_GUILD_ROSTER_ZONE_WIDTH = 210 - ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_HEADER_DOUBLE_PADDING_X

ZO_GAMEPAD_CONFIRM_REMOVE_GUILD_MEMBER_DIALOG_NAME = "GUILD_REMOVE_MEMBER_GAMEPAD"

-----------------
-- Guild Roster
-----------------

ZO_GamepadGuildRosterManager = ZO_GamepadSocialListPanel:Subclass()

function ZO_GamepadGuildRosterManager:New(...)
    return ZO_GamepadSocialListPanel.New(self, ...)
end

function ZO_GamepadGuildRosterManager:Initialize(control)
    ZO_GamepadSocialListPanel.Initialize(self, control, GUILD_ROSTER_MANAGER, "ZO_GamepadGuildRosterRow")

    --Need to call SetEmptyText so the empty text label is created and have the text be properly set by InteractiveSortFilterList the filters returns no result
    --GuildRoster will never be empty unless it was filtered out
    self:SetEmptyText("")

    self:SetupSort(GUILD_ROSTER_ENTRY_SORT_KEYS, "status", ZO_SORT_ORDER_UP)

    local function OnGuildMemberInfoChanged(eventId, guildId, displayName, note)
        if GUILD_ROSTER_GAMEPAD.listFragment:IsShowing() and GUILD_ROSTER_MANAGER:MatchesGuild(guildId) then
            self:RefreshTooltip()
        end
    end

    control:RegisterForEvent(EVENT_GUILD_MEMBER_NOTE_CHANGED, OnGuildMemberInfoChanged)
    control:RegisterForEvent(EVENT_GUILD_MEMBER_RANK_CHANGED, OnGuildMemberInfoChanged)

    self:InitializeConfirmRemoveDialog()
    self:InitializeSetRankDialog()
end

function ZO_GamepadGuildRosterManager:InitializeHeader()
    local contentHeaderData = 
    {
        titleText = GetString(SI_GAMEPAD_GUILD_ROSTER_HEADER),
        data1HeaderText = GetString(SI_GAMEPAD_GUILD_HUB_GUILD_NAME_HEADER),
        data2HeaderText = GetString(SI_GAMEPAD_GUILD_HEADER_GUILD_MASTER_LABEL),
    }
    ZO_GamepadInteractiveSortFilterList.InitializeHeader(self, contentHeaderData)
end

function ZO_GamepadGuildRosterManager:PerformDeferredInitialization()
    if self.initialized then return end
    self.initialized = true

    if GetUIPlatform() == UI_PLATFORM_XBOX then
        local keybind  =
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,

            name = GetString(SI_GAMEPAD_GUILD_ADD_FRIEND),

            keybind = "UI_SHORTCUT_TERTIARY",

            callback = function() ZO_ShowConsoleInviteToGuildFromUserListSelector(GUILD_ROSTER_MANAGER:GetGuildId()) end,

            visible = function()
                return GetNumberConsoleFriends() > 0 and DoesPlayerHaveGuildPermission(GUILD_ROSTER_MANAGER:GetGuildId(), GUILD_PERMISSION_INVITE)
            end
        }

        self:AddUniversalKeybind(keybind)
    end
end

function ZO_GamepadGuildRosterManager:GetAddKeybind()
    local keybind  =  {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,

        name = GetString(SI_GUILD_INVITE_ACTION),

        keybind = "UI_SHORTCUT_SECONDARY",

        callback = function()
            local guildId = GUILD_ROSTER_MANAGER:GetGuildId()
            if ZO_IsPlaystationPlatform() then
                ZO_ShowConsoleInviteToGuildFromUserListSelector(guildId)
            else
                local name = GetGuildName(guildId)
                local dialogData = {guildId = guildId} 
                ZO_Dialogs_ShowGamepadDialog("GAMEPAD_GUILD_INVITE_DIALOG", dialogData, {mainTextParams = {name}})
            end
        end,

        enabled = function()
            local numMembers, _, _, numInvitees = GetGuildInfo(GUILD_ROSTER_MANAGER:GetGuildId())
            local totalPlayers = numMembers + numInvitees
            if totalPlayers >= MAX_GUILD_MEMBERS then
                return false, GetString("SI_SOCIALACTIONRESULT", SOCIAL_RESULT_GUILD_IS_FULL)
            end
            return true
        end,

        visible = function()
            return DoesPlayerHaveGuildPermission(GUILD_ROSTER_MANAGER:GetGuildId(), GUILD_PERMISSION_INVITE)
        end
    }
    return keybind
end

function ZO_GamepadGuildRosterManager:ShouldShowData(data)
    return ZO_GamepadSocialListPanel.ShouldShowData(self, data) or data.rankId == DEFAULT_INVITED_RANK
end

function ZO_GamepadGuildRosterManager:GetBackKeybindCallback()
    return function()
        GAMEPAD_GUILD_HUB:SetEnterInSingleGuildList(true)
        SCENE_MANAGER:HideCurrentScene()
    end
end

function ZO_GamepadGuildRosterManager:RefreshTooltip()
    local data = self:GetSelectedData()

    if data and (zo_strlen(data.characterName) > 0 or data.rankId == DEFAULT_INVITED_RANK) then
        GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
        self:LayoutTooltip(GAMEPAD_TOOLTIPS, GAMEPAD_RIGHT_TOOLTIP, data)
        GAMEPAD_TOOLTIPS:ShowBg(GAMEPAD_RIGHT_TOOLTIP)
    else
        self:ClearTooltip()
    end
end

function ZO_GamepadGuildRosterManager:LayoutTooltip(tooltipManager, tooltip, data)
    local guildId = GUILD_ROSTER_MANAGER:GetGuildId()
    if data.rankId == DEFAULT_INVITED_RANK then
        tooltipManager:LayoutGuildInvitee(tooltip, ZO_FormatUserFacingDisplayName(data.displayName), data.characterName)
    else
        tooltipManager:LayoutGuildMember(tooltip, ZO_FormatUserFacingDisplayName(data.displayName), data.characterName, data.class, data.gender, guildId, data.rankIndex, data.note, data.level, data.championPoints, data.formattedAllianceName, data.formattedZone, not data.online, data.secsSinceLogoff, data.timeStamp)
    end
end

function ZO_GamepadGuildRosterManager:ColorRow(control, data, selected)
    local textColor, iconColor, textColor2 = self:GetRowColors(data, selected)
    GUILD_ROSTER_MANAGER:ColorRow(control, data, textColor, iconColor, textColor2)
end

function ZO_GamepadGuildRosterManager:OnShowing()
    GAMEPAD_GUILD_HOME:SetHeaderHidden(true)
    GAMEPAD_GUILD_HOME:SetContentHeaderHidden(true)
    self:PerformDeferredInitialization()
    self:Activate()
    ZO_GamepadSocialListPanel.OnShowing(self)
end

function ZO_GamepadGuildRosterManager:OnHidden()
    GAMEPAD_GUILD_HOME:SetHeaderHidden(false)
    GAMEPAD_GUILD_HOME:SetContentHeaderHidden(false)
    ZO_GamepadSocialListPanel.OnHidden(self)
end

-----------------
-- Options
-----------------

function ZO_GamepadGuildRosterManager:SetupOptions(socialData)
    ZO_SocialOptionsDialogGamepad.SetupOptions(self, socialData)
    self.playerData = GUILD_ROSTER_MANAGER:GetPlayerData()
    self.guildId = GUILD_ROSTER_MANAGER:GetGuildId()
    self.guildName = GUILD_ROSTER_MANAGER:GetGuildName()
    self.guildAlliance = GUILD_ROSTER_MANAGER:GetGuildAlliance()
    self.noteChangedCallback = GUILD_ROSTER_MANAGER:GetNoteEditedFunction()
end

function ZO_GamepadGuildRosterManager:BuildOptionsList()
    local groupId = self:AddOptionTemplateGroup(ZO_SocialOptionsDialogGamepad.GetDefaultHeader)

    local function WouldPromoteToGuildMaster()
        local theirNewRankIndex = self.socialData.rankIndex - 1
        return IsGuildRankGuildMaster(self.guildId, theirNewRankIndex)
    end
    local function ShouldAddPromoteOption()
        return not WouldPromoteToGuildMaster() and ZO_GuildRosterManager.CanPromotePlayer(self.guildId, self.playerData.rankIndex, self.socialData.rankIndex, self.socialData.rankId)
    end
    local function ShouldAddPromoteToGuildMasterOption()
        return WouldPromoteToGuildMaster() and ZO_GuildRosterManager.CanPromotePlayer(self.guildId, self.playerData.rankIndex, self.socialData.rankIndex, self.socialData.rankId)
    end
    self:AddOptionTemplate(groupId, ZO_GamepadGuildRosterManager.BuildPromoteOption, ShouldAddPromoteOption)
    self:AddOptionTemplate(groupId, ZO_GamepadGuildRosterManager.BuildPromoteToGuildMasterOption, ShouldAddPromoteToGuildMasterOption)
    
    local function ShouldAddDemoteOption()
        return ZO_GuildRosterManager.CanDemotePlayer(self.guildId, self.playerData.rankIndex, self.socialData.rankIndex, self.socialData.rankId)
    end
    self:AddOptionTemplate(groupId, ZO_GamepadGuildRosterManager.BuildDemoteOption, ShouldAddDemoteOption)

    local function ShouldAddSetRankOption()
        return ZO_GuildRosterManager.CanSetPlayerRank(self.guildId, self.playerData.rankIndex, self.socialData.rankIndex, self.socialData.rankId)
    end
    self:AddOptionTemplate(groupId, ZO_GamepadGuildRosterManager.BuildSetRankOption, ShouldAddSetRankOption)

    local function ShouldAddRemoveOption()
        local socialData = self.socialData
        local playerData = self.playerData
        return DoesPlayerHaveGuildPermission(self.guildId, GUILD_PERMISSION_REMOVE) and 
                playerData.rankIndex < socialData.rankIndex and 
                playerData.index ~= socialData.index and
                socialData.rankId ~= DEFAULT_INVITED_RANK
    end
    self:AddOptionTemplate(groupId, ZO_GamepadGuildRosterManager.BuildRemoveOption, ShouldAddRemoveOption)

    local function ShouldAddUninviteOption()
        local socialData = self.socialData
        return DoesPlayerHaveGuildPermission(self.guildId, GUILD_PERMISSION_REMOVE) and
                socialData.rankId == DEFAULT_INVITED_RANK
    end
    self:AddOptionTemplate(groupId, ZO_GamepadGuildRosterManager.BuildUninviteOption, ShouldAddUninviteOption)

    local function ShouldAddEditNoteOption()
        return DoesPlayerHaveGuildPermission(self.guildId, GUILD_PERMISSION_NOTE_EDIT) and self.socialData.rankId ~= DEFAULT_INVITED_RANK
    end
    self:AddOptionTemplate(groupId, ZO_GamepadGuildRosterManager.BuildEditNoteOption, ShouldAddEditNoteOption)

    local function SelectedIndexIsPlayerIndex()
        return self.socialData.index == self.playerData.index
    end
    self:AddOptionTemplate(groupId, ZO_GamepadGuildRosterManager.BuildLeaveGuildOption, SelectedIndexIsPlayerIndex)
    self:AddOptionTemplate(groupId, ZO_SocialOptionsDialogGamepad.BuildWhisperOption, ZO_SocialOptionsDialogGamepad.ShouldAddWhisperOption)
    self:AddOptionTemplate(groupId, ZO_SocialOptionsDialogGamepad.BuildInviteToGroupOption, ZO_SocialOptionsDialogGamepad.ShouldAddInviteToGroupOptionAndCanSelectedDataBeInvited)

    local function BuildTravelToGuildPlayerOption()
        if self.socialData.rankId ~= DEFAULT_INVITED_RANK then
            return self:BuildTravelToPlayerOption(JumpToGuildMember)
        end
    end

    local function CanJumpToPlayerHouse()
       return not self:SelectedDataIsPlayer() and self.socialData.rankId ~= DEFAULT_INVITED_RANK
    end

    self:AddOptionTemplate(groupId, BuildTravelToGuildPlayerOption, ZO_SocialOptionsDialogGamepad.SelectedDataIsLoggedIn)
    self:AddOptionTemplate(groupId, ZO_SocialOptionsDialogGamepad.BuildVisitPlayerHouseOption, CanJumpToPlayerHouse)
    self:AddOptionTemplate(groupId, ZO_SocialOptionsDialogGamepad.BuildSendMailOption, function() return not SelectedIndexIsPlayerIndex() and self.socialData.rankId ~= DEFAULT_INVITED_RANK end)
    self:AddOptionTemplate(groupId, ZO_SocialOptionsDialogGamepad.BuildAddFriendOption, ZO_SocialOptionsDialogGamepad.ShouldAddFriendOption)
    self:AddOptionTemplate(groupId, ZO_GamepadGuildRosterManager.BuildShowGamerCardOption, IsConsoleUI)
end

function ZO_GamepadGuildRosterManager:BuildPromoteOption()
    local callback = function()
        GuildPromote(self.guildId, self.socialData.displayName)
        PlaySound(SOUNDS.GUILD_ROSTER_PROMOTE)
    end
    return self:BuildOptionEntry(nil, SI_GUILD_PROMOTE, callback)
end

function ZO_GamepadGuildRosterManager:BuildPromoteToGuildMasterOption()
    local callback = function()
        local guildInfo = ZO_AllianceIconNameFormatter(self.guildAlliance, self.guildName)
        local rankName = GetFinalGuildRankName(self.guildId, 2)
        ZO_Dialogs_ShowGamepadDialog("PROMOTE_TO_GUILDMASTER", { guildId = self.guildId, displayName = self.socialData.displayName }, { mainTextParams = { ZO_FormatUserFacingDisplayName(self.socialData.displayName), "", guildInfo, rankName } })
    end
    return self:BuildOptionEntry(nil, SI_GUILD_PROMOTE, callback)
end

function ZO_GamepadGuildRosterManager:BuildDemoteOption()
    local callback = function()
        GuildDemote(self.guildId, self.socialData.displayName)
        PlaySound(SOUNDS.GUILD_ROSTER_DEMOTE)
    end
    return self:BuildOptionEntry(nil, SI_GUILD_DEMOTE, callback)
end

function ZO_GamepadGuildRosterManager:BuildSetRankOption()
    local callback = function()
        ZO_Dialogs_ShowGamepadDialog("GUILD_SET_RANK_GAMEPAD", { guildId = self.guildId, targetData = self.socialData, playerData = self.playerData })
    end
    return self:BuildOptionEntry(nil, SI_GUILD_SET_RANK, callback)
end

function ZO_GamepadGuildRosterManager:BuildRemoveOption()
    local callback = function()
        ZO_Dialogs_ShowGamepadDialog(ZO_GAMEPAD_CONFIRM_REMOVE_GUILD_MEMBER_DIALOG_NAME, { guildId = self.guildId,  displayName = self.socialData.displayName }, { mainTextParams = { ZO_FormatUserFacingDisplayName(self.socialData.displayName) }})
    end
    return self:BuildOptionEntry(nil, SI_GUILD_REMOVE, callback)
end

function ZO_GamepadGuildRosterManager:BuildUninviteOption()
    local callback = function()
        local guildInfo = ZO_AllianceIconNameFormatter(self.guildAlliance, self.guildName)
        ZO_Dialogs_ShowGamepadDialog("UNINVITE_GUILD_PLAYER", {guildId = self.guildId,  displayName = self.socialData.displayName}, { mainTextParams = { ZO_FormatUserFacingDisplayName(self.socialData.displayName), "", guildInfo }})
    end
    return self:BuildOptionEntry(nil, SI_GUILD_UNINVITE, callback)
end

function ZO_GamepadGuildRosterManager:BuildLeaveGuildOption()
    local callback = function()
        local data = {
            hideSceneOnLeave = true
        }   
        local IS_GAMEPAD = true
        ZO_ShowLeaveGuildDialog(self.guildId, data, IS_GAMEPAD)
    end
    return self:BuildOptionEntry(nil, SI_GUILD_LEAVE, callback)
end

function ZO_GamepadGuildRosterManager:BuildAddFriendOption()
    local callback = function()      
        if IsConsoleUI() then
             ZO_ShowConsoleAddFriendDialogFromDisplayNameOrFallback(self.socialData.displayName, ZO_ID_REQUEST_TYPE_GUILD_INFO, self.guildId, self.socialData.index)
        else
            local data = { displayName = self.socialData.displayName, }
            ZO_Dialogs_ShowGamepadDialog("GAMEPAD_SOCIAL_ADD_FRIEND_DIALOG", data)
        end
    end
    local HEADER = nil
    return self:BuildOptionEntry(HEADER, SI_SOCIAL_MENU_ADD_FRIEND, callback)
end

function ZO_GamepadGuildRosterManager:BuildShowGamerCardOption()
    if(IsConsoleUI()) then
        local callback = function()
            ZO_ShowGamerCardFromDisplayNameOrFallback(self.socialData.displayName, ZO_ID_REQUEST_TYPE_GUILD_INFO, self.guildId, self.socialData.index)
        end
        return self:BuildOptionEntry(nil, GetGamerCardStringId(), callback)
    end
end

function ZO_GamepadGuildRosterManager:InitializeConfirmRemoveDialog()
    local function ReleaseDialog()
        GAMEPAD_TOOLTIPS:ClearLines(GAMEPAD_LEFT_TOOLTIP)
        ZO_Dialogs_ReleaseDialogOnButtonPress(ZO_GAMEPAD_CONFIRM_REMOVE_GUILD_MEMBER_DIALOG_NAME)
    end

    local function OnGuildPermissionChangedCallback(guildId)
        if guildId == self.guildId then
            if not DoesPlayerHaveGuildPermission(self.guildId, GUILD_PERMISSION_REMOVE) then
                ReleaseDialog()
            elseif self.canAddToBlacklist and not DoesPlayerHaveGuildPermission(self.guildId, GUILD_PERMISSION_MANAGE_BLACKLIST) then
                ReleaseDialog()
            end
        end
    end

    ZO_Dialogs_RegisterCustomDialog(ZO_GAMEPAD_CONFIRM_REMOVE_GUILD_MEMBER_DIALOG_NAME,
    {
        blockDialogReleaseOnPress = true,

        canQueue = true,

        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
            allowRightStickPassThrough = true,
        },

        setup = function(dialog)
            self.canAddToBlacklist = DoesPlayerHaveGuildPermission(self.guildId, GUILD_PERMISSION_MANAGE_BLACKLIST)
            self.addToBlacklist = false
            self.blacklistNote = nil
            GUILD_RECRUITMENT_MANAGER:RegisterCallback("GuildPermissionsChanged", OnGuildPermissionChangedCallback)

            dialog:setupFunc()

            -- Select Remove button if no blacklist permissions
            if not DoesPlayerHaveGuildPermission(self.guildId, GUILD_PERMISSION_MANAGE_BLACKLIST) then
                local REMOVE_ENTRY_INDEX = 2
                dialog.entryList:SetSelectedIndex(REMOVE_ENTRY_INDEX)
            end
        end,

        finishedCallback = function(dialog)
            GUILD_RECRUITMENT_MANAGER:UnregisterCallback("GuildPermissionsChanged", OnGuildPermissionChangedCallback)
        end,

        title =
        {
            text = SI_PROMPT_TITLE_GUILD_REMOVE_MEMBER,
        },

        mainText = 
        {
            text = SI_GUILD_REMOVE_MEMBER_WARNING,
        },
        parametricList =
        {
            -- Backlist checkbox
            {
                template = "ZO_CheckBoxTemplate_WithoutIndent_Gamepad",
                templateData = {
                    text = GetString(SI_GUILD_RECRUITMENT_ADD_TO_BLACKLIST_ACTION),
                    setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
                        data.enabled = self.canAddToBlacklist
                        ZO_SharedGamepadEntry_OnSetup(control, data, selected, reselectingDuringRebuild, enabled, active)

                        local checkboxControl = control.checkBox

                        if self.addToBlacklist then
                            ZO_CheckButton_SetChecked(checkboxControl)
                        else
                            ZO_CheckButton_SetUnchecked(checkboxControl)
                        end

                        if self.canAddToBlacklist then
                            ZO_CheckButton_Enable(checkboxControl)
                        else
                            ZO_CheckButton_Disable(checkboxControl)

                            if selected then
                                local NO_TOOLTIP_TITLE = nil
                                GAMEPAD_TOOLTIPS:LayoutTitleAndDescriptionTooltip(GAMEPAD_LEFT_TOOLTIP, NO_TOOLTIP_TITLE, GetString(SI_GUILD_RECRUITMENT_NO_BLACKLIST_PERMISSION))
                            else
                                GAMEPAD_TOOLTIPS:ClearLines(GAMEPAD_LEFT_TOOLTIP)
                            end
                        end
                    end,
                    callback = function(dialog)
                        local targetControl = dialog.entryList:GetTargetControl()
                        ZO_GamepadCheckBoxTemplate_OnClicked(targetControl)
                        self.addToBlacklist = ZO_GamepadCheckBoxTemplate_IsChecked(targetControl)

                        local RESELECT_ENTRY = true
                        ZO_GenericParametricListGamepadDialogTemplate_RebuildEntryList(dialog, nil, RESELECT_ENTRY)
                    end,
                },
            },
            -- Blacklist Note
            {
                template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem_Multiline",
                templateData = {
                    textChangedCallback = function(control)
                        local blacklistNote = control:GetText()
                        self.blacklistNote = blacklistNote
                    end,
                    setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
                        control.highlight:SetHidden(not selected)

                        control.editBoxControl.textChangedCallback = data.textChangedCallback
                        data.control = control

                        ZO_EditDefaultText_Initialize(control.editBoxControl, GetString(SI_GUILD_RECRUITMENT_BLACKLIST_NOTE_DEFAULT_TEXT))
                        control.editBoxControl:SetMaxInputChars(MAX_GUILD_BLACKLIST_MESSAGE_LENGTH)
                        if self.blacklistNote then
                            control.editBoxControl:SetText(self.blacklistNote)
                        end
                    end,
                    visible = function()
                        return self.addToBlacklist
                    end,
                    callback = function(dialog)
                        local targetControl = dialog.entryList:GetTargetControl()
                        targetControl.editBoxControl:TakeFocus()
                    end,
                },
            },
            -- Remove applicant
            {
                template = "ZO_GamepadTextFieldSubmitItem",
                templateData = {
                    text = GetString(SI_DIALOG_REMOVE),
                    setup = ZO_SharedGamepadEntry_OnSetup,
                    callback = function(dialog)
                        if self.addToBlacklist then
                            local blacklistResult = AddToGuildBlacklistByDisplayName(dialog.data.guildId, dialog.data.displayName, self.blacklistNote)
                            if not ZO_GuildRecruitment_Manager.IsAddedToBlacklistSuccessful(blacklistResult) then
                                ZO_Dialogs_ShowPlatformDialog("GUILD_FINDER_BLACKLIST_FAILED", nil, { mainTextParams = { blacklistResult } })
                            end
                        else
                            GuildRemove(dialog.data.guildId, dialog.data.displayName)
                        end
                        ReleaseDialog()
                    end,
                },
            },
        },
        buttons =
        {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback =  function(dialog)
                    local data = dialog.entryList:GetTargetData()
                    data.callback(dialog)
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback = function(dialog)
                    ReleaseDialog()
                end,
            },
        }
    })
end

function ZO_GamepadGuildRosterManager:InitializeSetRankDialog()
    local function OnRankSelected(dialog, entry)
        local data = dialog.data
        local newRankIndex = entry.rankIndex
        if newRankIndex ~= data.targetData.rankIndex then
            if newRankIndex == 1 then
                local guildInfo = ZO_AllianceIconNameFormatter(self.guildAlliance, self.guildName)
                local rankName = GetFinalGuildRankName(self.guildId, data.targetData.rankIndex)
                ZO_Dialogs_ShowGamepadDialog("PROMOTE_TO_GUILDMASTER", { guildId = self.guildId, displayName = data.targetData.displayName }, { mainTextParams = { ZO_FormatUserFacingDisplayName(data.targetData.displayName), "", guildInfo, rankName } })
            else
                if newRankIndex < data.targetData.rankIndex then
                    PlaySound(SOUNDS.GUILD_ROSTER_PROMOTE)
                else
                    PlaySound(SOUNDS.GUILD_ROSTER_DEMOTE)
                end
                GuildSetRank(data.guildId, data.targetData.displayName, newRankIndex)
            end
        end
    end

    ZO_Dialogs_RegisterCustomDialog("GUILD_SET_RANK_GAMEPAD",
    {
        canQueue = true,

        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },

        setup = function(dialog, data)
            EVENT_MANAGER:RegisterForEvent("SetRankDialogGamepad", EVENT_GUILD_MEMBER_RANK_CHANGED, function(_, guildId, displayName)
                if guildId == data.guildId and displayName == data.targetData.displayName or displayName == data.playerData.displayName then
                    ZO_Dialogs_ReleaseDialog("GUILD_SET_RANK_GAMEPAD")
                end
            end)
            EVENT_MANAGER:RegisterForEvent("SetRankDialogGamepad", EVENT_GUILD_RANK_CHANGED, function(_, guildId)
                if guildId == data.guildId then
                    ZO_Dialogs_ReleaseDialog("GUILD_SET_RANK_GAMEPAD")
                end
            end)

            dialog.info.parametricList = {}
            local targetRankIndex = data.targetData.rankIndex
            local IS_GAMEPAD = true
            local entries = ZO_GuildRosterManager.ComputeSetRankEntries(data.guildId, data.playerData.rankIndex, targetRankIndex, IS_GAMEPAD)
            for rankIndex, entry in ipairs(entries) do
                local rankEntry = ZO_GamepadEntryData:New(entry.rankName, entry.rankIcon)
                rankEntry:SetEnabled(entry.enabled)
                if rankIndex == targetRankIndex then
                    rankEntry:SetSelected(true)
                end
                rankEntry.rankIndex = rankIndex
                rankEntry.setup = ZO_SharedGamepadEntry_OnSetup
                rankEntry.callback = OnRankSelected
                
                table.insert(dialog.info.parametricList,
                {
                    template = "ZO_GamepadSubMenuEntryTemplateWithStatus",
                    entryData = rankEntry,
                })
            end
            
            dialog:setupFunc()
            dialog.entryList:SetSelectedIndexWithoutAnimation(targetRankIndex)
        end,

        finishedCallback = function(dialog)
            EVENT_MANAGER:UnregisterForEvent("SetRankDialogGamepad", EVENT_GUILD_MEMBER_RANK_CHANGED)
            EVENT_MANAGER:UnregisterForEvent("SetRankDialogGamepad", EVENT_GUILD_RANK_CHANGED)
        end,

        title =
        {
            text = SI_GUILD_SET_RANK_DIALOG_TITLE,
        },
        buttons =
        {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                enabled = function(dialog)
                    local entry = dialog.entryList:GetTargetData()
                    return entry.enabled
                end,
                callback =  function(dialog)
                    local entry = dialog.entryList:GetTargetData()
                    entry.callback(dialog, entry)
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
            },
        }
    })
end

function ZO_GamepadGuildRoster_Initialize(control)
    GUILD_ROSTER_GAMEPAD = ZO_GamepadGuildRosterManager:New(control)
end