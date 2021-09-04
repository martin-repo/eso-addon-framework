--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local GAMEPAD_GUILD_HUB_SCENE_NAME = "gamepad_guild_hub"

local GUILD_CREATE_GAMEPAD_DIALOG = "GUILD_CREATE_GAMEPAD"
local CHANGE_ABOUT_US_GAMEPAD_DIALOG = "CHANGE_ABOUT_US_GAMEPAD"
local CHANGE_MOTD_GAMEPAD_DIALOG = "CHANGE_MOTD_GAMEPAD"

local GAMEPAD_OPTIONS_LIST_ENTRY = "ZO_GamepadMenuEntryTemplate"
local GAMEPAD_GUILD_LIST_ENTRY = "ZO_GamepadSubMenuEntryTemplate"

local GAMEPAD_CREATE_GUILD_LIST_ENTRY = "ZO_GamepadSubMenuEntryTemplate"

local GUILD_HUB_DISPLAY_MODE =
{
    GUILDS_LIST = 1,
    SINGLE_GUILD_LIST = 2,
}

local GUILD_HUB_SINGLE_GUILD_LIST_OPTION = {
    ROSTER = 1,
    RANKS = 2,
    RECRUITMENT = 3,
    HERALDRY = 4,
    HISTORY = 5,
}

local function SetupRequestEntry(control, data, selected, reselectingDuringRebuild, enabled, active)
    local isValid = enabled
    if data.validInput then
        isValid = data.validInput()
        data.disabled = not isValid
        data:SetEnabled(isValid)
    end

    ZO_SharedGamepadEntry_OnSetup(control, data, selected, reselectingDuringRebuild, isValid, active)
end

local function EqualityFunction(leftData, rightData)
    return leftData.optionId == rightData.optionId 
end

ZO_GamepadGuildHub = ZO_Gamepad_ParametricList_Screen:Subclass()

function ZO_GamepadGuildHub_OnInitialize(control)
    GAMEPAD_GUILD_HUB = ZO_GamepadGuildHub:New(control)

    local sectionThree = control:GetNamedChild("RightPaneContainerCreateGuildExplanationScrollContainerScrollChildSection3")
    sectionThree:SetText(zo_strformat(SI_GUILD_CONCLUSION, ZO_GetPlatformAccountLabel()))
end

function ZO_GamepadGuildHub:New(...)
    return ZO_Gamepad_ParametricList_Screen.New(self, ...)
end

function ZO_GamepadGuildHub:Initialize(control)
    ZO_Gamepad_ParametricList_Screen.Initialize(self, control)

    GAMEPAD_GUILD_HUB_SCENE = ZO_Scene:New(GAMEPAD_GUILD_HUB_SCENE_NAME, SCENE_MANAGER)
    GAMEPAD_GUILD_HUB_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            self:OnSceneShowing()
        elseif newState == SCENE_HIDDEN then
            self:OnSceneHidden()
        end

        ZO_Gamepad_ParametricList_Screen.OnStateChanged(self, oldState, newState)
    end)
end

------------
-- Screen --
------------

local function SetupOptionsList(list)
    list:AddDataTemplate(GAMEPAD_OPTIONS_LIST_ENTRY, ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction, EqualityFunction, "ZO_GamepadMenuEntryHeaderTemplate")
    list:AddDataTemplateWithHeader(GAMEPAD_OPTIONS_LIST_ENTRY, ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction, EqualityFunction, "ZO_GamepadMenuEntryHeaderTemplate")
end

function ZO_GamepadGuildHub:PerformDeferredInitializationHub()
    if self.deferredInitialized then return end
    self.deferredInitialized = true

    self.guildList = self:GetMainList()
    self.singleGuildList = self:AddList("SingleGuild", SetupOptionsList)

    self:InitializeHeader()
    self:InitializeGuildBrowserExplanation()
    self:InitializeCreateGuildExplanation()
    self:InitializeCreateGuildDialog()
    self:InitializeChangeAboutUsDialog()
    self:InitializeChangeMotdDialog()
end

function ZO_GamepadGuildHub:PerformUpdate()
    self:UpdateLists()
    self:UpdateContent()

    if self.optionsGuildId ~= nil then
        self:ValidateOptionsGuildId()
    end
end

function ZO_GamepadGuildHub:OnSceneShowing(oldState, newState)
    self.displayMode = self.enterInSingleGuildList and GUILD_HUB_DISPLAY_MODE.SINGLE_GUILD_LIST or GUILD_HUB_DISPLAY_MODE.GUILDS_LIST
    self.enterInSingleGuildList = false

    self.displayedGuildId = nil
    self.displayedCreateGuild = nil
    self.displayGuildBrowser = nil
    self.filteredGuildId = nil

    self:PerformDeferredInitializationHub()
    self:Update()

    local OnRefreshMatchGuildId = function(_, guildId)
        if self.optionsGuildId == guildId then
            self:Update()
        end
    end

    local control = self.control
    control:RegisterForEvent(EVENT_GUILD_DATA_LOADED, function() self:Update() end)
    control:RegisterForEvent(EVENT_PLAYER_STATUS_CHANGED, function() self:Update() end)
    control:RegisterForEvent(EVENT_LEVEL_UPDATE, function() self:Update() end)
    control:AddFilterForEvent(EVENT_LEVEL_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
    control:RegisterForEvent(EVENT_GUILD_MOTD_CHANGED, OnRefreshMatchGuildId)
    control:RegisterForEvent(EVENT_GUILD_DESCRIPTION_CHANGED, OnRefreshMatchGuildId)
    control:RegisterForEvent(EVENT_GUILD_RANK_CHANGED, OnRefreshMatchGuildId)
    control:RegisterForEvent(EVENT_GUILD_RANKS_CHANGED, OnRefreshMatchGuildId)
    control:RegisterForEvent(EVENT_GUILD_MEMBER_RANK_CHANGED, OnRefreshMatchGuildId)
    control:RegisterForEvent(EVENT_GUILD_KEEP_CLAIM_UPDATED, OnRefreshMatchGuildId)
    control:RegisterForEvent(EVENT_GUILD_TRADER_HIRED_UPDATED, OnRefreshMatchGuildId)
    TriggerTutorial(TUTORIAL_TRIGGER_GUILDS_HOME_OPENED)
end

function ZO_GamepadGuildHub:OnSceneHidden(oldState, newState)
    local control = self.control
    control:UnregisterForEvent(EVENT_GUILD_DATA_LOADED)
    control:UnregisterForEvent(EVENT_PLAYER_STATUS_CHANGED)
    control:UnregisterForEvent(EVENT_LEVEL_UPDATE)
    control:UnregisterForEvent(EVENT_GUILD_MOTD_CHANGED)
    control:UnregisterForEvent(EVENT_GUILD_DESCRIPTION_CHANGED)
    control:UnregisterForEvent(EVENT_GUILD_RANK_CHANGED)
    control:UnregisterForEvent(EVENT_GUILD_RANKS_CHANGED)
    control:UnregisterForEvent(EVENT_GUILD_MEMBER_RANK_CHANGED)
    control:UnregisterForEvent(EVENT_GUILD_KEEP_CLAIM_UPDATED)
    control:UnregisterForEvent(EVENT_GUILD_TRADER_HIRED_UPDATED)
end

function ZO_GamepadGuildHub:UpdateLists()
    if self.displayMode == GUILD_HUB_DISPLAY_MODE.GUILDS_LIST then
        self:SetCurrentList(self.guildList)
        self:RefreshGuildList()
    elseif self.displayMode == GUILD_HUB_DISPLAY_MODE.SINGLE_GUILD_LIST then
        self:SetCurrentList(self.singleGuildList)
        self:RefreshSingleGuildList()
    end
end

function ZO_GamepadGuildHub:UpdateContent()
    self:RefreshHeader()

    self:RefreshCreateGuildExplanation()
    self:RefreshGuildBrowserExplanation()
    self:RefreshGuildInfo()

    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
end

function ZO_GamepadGuildHub:ValidateOptionsGuildId()
    if not ZO_ValidatePlayerGuildId(self.optionsGuildId) then
        self.optionsGuildId = nil
        self:ActivateMainList()
    end
end

-------------
-- Dialogs --
-------------

function ZO_GamepadGuildHub:InitializeChangeMotdDialog()
    local dialogName = CHANGE_MOTD_GAMEPAD_DIALOG
    local parametricDialog = ZO_GenericGamepadDialog_GetControl(GAMEPAD_DIALOGS.PARAMETRIC)

    local function UpdateSelectedMotd(aboutUs)
        if self.selectedMotd ~= aboutUs then
            self.selectedMotd = aboutUs
        end
    end

    local function ReleaseDialog()
        ZO_Dialogs_ReleaseDialogOnButtonPress(dialogName)
    end

    local function SetupDialog(dialog)
        self.selectedMotd = nil
        UpdateSelectedMotd(GetGuildMotD(self.optionsGuildId))
        dialog:setupFunc()
    end

    ZO_Dialogs_RegisterCustomDialog(dialogName,
    {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },

        setup = SetupDialog,
        blockDialogReleaseOnPress = true, -- We'll handle Dialog Releases ourselves since we don't want DIALOG_PRIMARY to release the dialog on press.

        title =
        {
            text = SI_GAMEPAD_GUILD_INFO_CHANGE_MOTD,
        },
        parametricList =
        {
            -- motd edit box
            {
                template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem_Multiline",

                templateData = {
                    nameField = true,
                    textChangedCallback = function(control)
                        local newMotd = control:GetText()
                        UpdateSelectedMotd(newMotd)
                    end,

                    setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
                        control.highlight:SetHidden(not selected)

                        control.editBoxControl.textChangedCallback = data.textChangedCallback

                        ZO_EditDefaultText_Initialize(control.editBoxControl, GetString(SI_GAMEPAD_GUILD_MOTD_EMPTY_TEXT))
                        control.editBoxControl:SetMaxInputChars(MAX_GUILD_MOTD_LENGTH)
                        control.editBoxControl:SetText(self.selectedMotd)
                    end,
                },
            },

            -- accept
            {
                template = "ZO_GamepadTextFieldSubmitItem",
                templateData = {
                    finishedSelector = true,
                    text = GetString(SI_DIALOG_ACCEPT),
                    setup = SetupRequestEntry,
                    validInput = function()
                        return self.selectedMotd and self.selectedMotd ~= ""
                    end,
                }
            },
        },
       
        buttons =
        {
            -- Cancel Button
            {
                keybind = "DIALOG_NEGATIVE",
                text = GetString(SI_DIALOG_CANCEL),
                callback = function()
                    ReleaseDialog()
                end,
            },

            -- Select Button (used for entering name and selected alliance)
            {
                keybind = "DIALOG_PRIMARY",
                text = GetString(SI_GAMEPAD_SELECT_OPTION),
                callback = function(dialog)
                    local selectedData = dialog.entryList:GetTargetData()
                    local targetControl = dialog.entryList:GetTargetControl()
                    if selectedData.nameField and targetControl then
                        targetControl.editBoxControl:TakeFocus()
                    elseif selectedData.finishedSelector then
                        if self.selectedMotd and self.selectedMotd ~= "" then
                            SetGuildMotD(self.optionsGuildId, self.selectedMotd)
                        end

                        ReleaseDialog()
                    end
                end,
                enabled = function()
                    local selectedData = parametricDialog.entryList:GetTargetData()
                    local enabled = true

                    if selectedData.finishedSelector then
                        enabled = self.selectedMotd and self.selectedMotd ~= ""
                    end

                    return enabled
                end,
            },
        },

        noChoiceCallback = function(dialog)
            ReleaseDialog()
        end,
    })
end

function ZO_GamepadGuildHub:InitializeChangeAboutUsDialog()
    local dialogName = CHANGE_ABOUT_US_GAMEPAD_DIALOG
    local parametricDialog = ZO_GenericGamepadDialog_GetControl(GAMEPAD_DIALOGS.PARAMETRIC)

    local function UpdateSelectedAboutUs(aboutUs)
        if self.selectedAboutUs ~= aboutUs then
            self.selectedAboutUs = aboutUs
        end
    end

    local function ReleaseDialog()
        ZO_Dialogs_ReleaseDialogOnButtonPress(dialogName)
    end

    local function SetupDialog(dialog)
        self.selectedAboutUs = nil
        UpdateSelectedAboutUs(GetGuildDescription(self.optionsGuildId))
        dialog:setupFunc()
    end

    ZO_Dialogs_RegisterCustomDialog(dialogName,
    {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },

        setup = SetupDialog,
        blockDialogReleaseOnPress = true, -- We'll handle Dialog Releases ourselves since we don't want DIALOG_PRIMARY to release the dialog on press.

        title =
        {
            text = SI_GAMEPAD_GUILD_INFO_CHANGE_ABOUT_US,
        },
        parametricList =
        {
            -- about us edit box
            {
                template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem_Multiline",

                templateData = {
                    nameField = true,
                    textChangedCallback = function(control)
                        local newAboutUs = control:GetText()
                        UpdateSelectedAboutUs(newAboutUs)
                    end,

                    setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
                        control.highlight:SetHidden(not selected)

                        control.editBoxControl.textChangedCallback = data.textChangedCallback

                        ZO_EditDefaultText_Initialize(control.editBoxControl, GetString(SI_GUILD_DESCRIPTION_HEADER))
                        control.editBoxControl:SetMaxInputChars(MAX_GUILD_DESCRIPTION_LENGTH)
                        control.editBoxControl:SetText(self.selectedAboutUs)
                    end,
                },
            },

            -- accept
            {
                template = "ZO_GamepadTextFieldSubmitItem",
                templateData = {
                    finishedSelector = true,
                    text = GetString(SI_DIALOG_ACCEPT),
                    setup = SetupRequestEntry,
                    validInput = function()
                        return self.selectedAboutUs and self.selectedAboutUs ~= ""
                    end,
                }
            },
        },
       
        buttons =
        {
            -- Cancel Button
            {
                keybind = "DIALOG_NEGATIVE",
                text = GetString(SI_DIALOG_CANCEL),
                callback = function()
                    ReleaseDialog()
                end,
            },

            -- Select Button (used for entering name and selected alliance)
            {
                keybind = "DIALOG_PRIMARY",
                text = GetString(SI_GAMEPAD_SELECT_OPTION),
                callback = function(dialog)
                    local selectedData = dialog.entryList:GetTargetData()
                    local targetControl = dialog.entryList:GetTargetControl()
                    if selectedData.nameField and targetControl then
                        targetControl.editBoxControl:TakeFocus()
                    elseif selectedData.finishedSelector then
                        if self.selectedAboutUs and self.selectedAboutUs ~= "" then
                            SetGuildDescription(self.optionsGuildId, self.selectedAboutUs)
                        end

                        ReleaseDialog()
                    end
                end,
                enabled = function()
                    local selectedData = parametricDialog.entryList:GetTargetData()
                    local enabled = true

                    if selectedData.finishedSelector then
                        enabled = self.selectedAboutUs and self.selectedAboutUs ~= ""
                    end

                    return enabled
                end,
            },
        },

        noChoiceCallback = function(dialog)
            ReleaseDialog()
        end,
    })
end

function ZO_GamepadGuildHub:InitializeCreateGuildDialog()
    local dialogName = GUILD_CREATE_GAMEPAD_DIALOG
    local errorTitle = ZO_ERROR_COLOR:Colorize(GetString(SI_INVALID_NAME_DIALOG_TITLE))
    local defaultTitle = GetString(SI_GAMEPAD_GUILD_CREATE_DIALOG_NEW_GUILD_DEFAULT_HEADER)

    local function UpdateSelectedName(name)
        self.selectedName = name
        self.guildNameViolations = { IsValidGuildName(self.selectedName) }
        self.noViolations = #self.guildNameViolations == 0

        if (not self.noViolations) and self.createGuildEditBoxSelected then
            local HIDE_UNVIOLATED_RULES = true
            self.creatingGuildInfoLabel:SetText(ZO_ValidNameInstructions_GetViolationString(self.selectedName, self.guildNameViolations, HIDE_UNVIOLATED_RULES))
            self.creatingGuildTitle = errorTitle
        else
            self.creatingGuildInfoLabel:SetText(self.createGuildWithSelectedAllianceMessageText)
            self.creatingGuildTitle = self.noViolations and name or defaultTitle
        end

        KEYBIND_STRIP:UpdateCurrentKeybindButtonGroups()
        self:RefreshHeader()
    end

    local function UpdateSelectedAllianceIndex(index)
        self.selectedAllianceIndex = index
    end

    local function OnAllianceSelected(_, _, entry, _)
        UpdateSelectedAllianceIndex(entry.allianceIndex)
    end

    local function ReleaseDialog(dialog)
        self.creatingGuild = false
        if self.allianceDropDown and self.allianceDropDown:IsActive() then
            local BLOCK_CALLBACK = true
            self.allianceDropDown:Deactivate(BLOCK_CALLBACK)
        end
        ZO_GenericGamepadDialog_HideTooltip(dialog)
        ZO_Dialogs_ReleaseDialogOnButtonPress(dialogName)
        self:RefreshHeader()
        self:RefreshCreateGuildExplanation()

        self.creatingGuildInfoLabel:SetHidden(true)
    end

    local function SetupDialog(dialog)
        self.creatingGuild = true
        self.createGuildEditBoxSelected = false
        self.selectedName = nil
        local playerAlliance = GetUnitAlliance("player")
        self.createGuildWithSelectedAllianceMessageText = zo_strformat(SI_GUILD_CREATE_DIALOG_ALLIANCE_RULES, GetAllianceName(playerAlliance))
        self:RefreshCreateGuildExplanation()
        UpdateSelectedName("")
        UpdateSelectedAllianceIndex(playerAlliance)
        dialog:setupFunc()

        self.creatingGuildInfoLabel:SetHidden(false)
    end

    local function GuildNameValidationCallback(isValid)
        if isValid then
            GuildCreate(self.selectedName, self.selectedAllianceIndex)
        else
            ZO_AlertEvent(EVENT_SOCIAL_ERROR, SOCIAL_RESULT_INVALID_GUILD_NAME)
        end
    end

    ZO_Dialogs_RegisterCustomDialog(dialogName,
    {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },

        setup = SetupDialog,
        blockDialogReleaseOnPress = true, -- We'll handle Dialog Releases ourselves since we don't want DIALOG_PRIMARY to release the dialog on press.

        title =
        {
            text = SI_PROMPT_TITLE_GUILD_CREATE,
        },
        parametricList =
        {
            -- alliance icon selector entry
            {
                header = GetString(SI_GAMEPAD_GUILD_CREATE_DIALOG_ALLIANCE_SELECTOR_HEADER),
                template = "ZO_GamepadDropdownItem",

                templateData = {
                    setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
                        local dropDown = control.dropdown
                        self.allianceDropDown = dropDown

                        dropDown:SetSortsItems(false)
                        dropDown:ClearItems()

                        for i = 1, NUM_ALLIANCES do
                            local allianceText = zo_iconTextFormat(GetLargeAllianceSymbolIcon(i), 32, 32, GetAllianceName(i))
                            local entry = dropDown:CreateItemEntry(allianceText, OnAllianceSelected)
                            entry.allianceIndex = i
                            dropDown:AddItem(entry)
                        end

                        dropDown:SelectItemByIndex(self.selectedAllianceIndex)
                        dropDown:SetHighlightedItem(self.selectedAllianceIndex)
                    end,
                    
                    callback = function()
                        self.allianceDropDown:Activate()
                        self.allianceDropDown:SetHighlightedItem(self.selectedAllianceIndex)
                    end
                },
            },

            -- guild name edit box
            {
                template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem",
                templateData = {
                    textChangedCallback = function(control)
                        local newName = control:GetText()
                        UpdateSelectedName(newName)

                        if self.noViolations or self.selectedName == ""  then
                            control:SetColor(ZO_SELECTED_TEXT:UnpackRGB())
                        else
                            control:SetColor(ZO_ERROR_COLOR:UnpackRGB())
                        end
                    end,   

                    setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
                        control.editBoxControl.textChangedCallback = data.textChangedCallback

                        if self.selectedName == "" then
                            ZO_EditDefaultText_Initialize(control.editBoxControl, GetString(SI_GUILD_CREATE_DIALOG_NAME_DEFAULT_TEXT))
                        end

                        control.editBoxControl:SetMaxInputChars(MAX_GUILD_NAME_LENGTH)
                        control.editBoxControl:SetText(self.selectedName)
                        self.createGuildEditBoxSelected = selected
                        self.createGuildEditBox = control.editBoxControl
                        UpdateSelectedName(self.selectedName)
                    end,

                    callback = function(dialog)
                        local targetControl = dialog.entryList:GetTargetControl()
                        targetControl.editBoxControl:TakeFocus()
                        UpdateSelectedName(self.selectedName)
                    end
                },

                controlReset = function(control, pool)
                    control.editBoxControl:SetColor(ZO_SELECTED_TEXT:UnpackRGB())
                end,
            },

            -- Finish
            {
                template = "ZO_GamepadTextFieldSubmitItem",
                templateData = {
                    text = GetString(SI_GAMEPAD_GUILD_CREATE_DIALOG_FINISH),
                    setup = SetupRequestEntry,
                    callback = function(dialog)
                        if self.noViolations then
                            if IsConsoleUI() then
                                PLAYER_CONSOLE_INFO_REQUEST_MANAGER:RequestNameValidation(self.selectedName, GuildNameValidationCallback)
                            else
                                GuildCreate(self.selectedName, self.selectedAllianceIndex)
                            end
                            ReleaseDialog(dialog)
                        end
                    end,
                    validInput = function()
                        return self.noViolations
                    end,
                }
            },
        },
       
        buttons =
        {
            -- Cancel Button
            {
                keybind = "DIALOG_NEGATIVE",
                text = GetString(SI_DIALOG_CANCEL),
                callback = function(dialog)
                    ReleaseDialog(dialog)
                end,
            },

            -- Select Button (used for entering name and selected alliance)
            {
                keybind = "DIALOG_PRIMARY",
                text = GetString(SI_GAMEPAD_SELECT_OPTION),
                enabled = function(dialog)
                    local targetData = dialog.entryList:GetTargetData()
                    if targetData and targetData.validInput then
                        return targetData.validInput()
                    end

                    return true
                end,
                callback = function(dialog)
                    local targetData = dialog.entryList:GetTargetData()
                    if targetData and targetData.callback then
                        targetData.callback(dialog)
                    end
                end,
            },
        },

        noChoiceCallback = function(dialog)
            ReleaseDialog(dialog)
        end,
    })
end

----------------
-- Guild Info --
----------------

function ZO_GamepadGuildHub:RefreshGuildInfo()
    local targetData = self.guildList:GetTargetData()
    if targetData == nil or targetData.isCreateGuild or targetData.isGuildBrowser then
        GAMEPAD_GUILD_HUB_SCENE:RemoveFragment(GUILD_INFO_GAMEPAD_FRAGMENT)
        GAMEPAD_GUILD_HUB_SCENE:RemoveFragment(GAMEPAD_GENERIC_FOOTER_FRAGMENT)
    else
        if self.displayedGuildId == nil then
            if targetData and targetData.guildId ~= nil then
                GAMEPAD_GUILD_INFO:SetGuildId(targetData.guildId)
            end
        end

        GAMEPAD_GUILD_HUB_SCENE:AddFragment(GAMEPAD_GENERIC_FOOTER_FRAGMENT)
        GAMEPAD_GUILD_HUB_SCENE:AddFragment(GUILD_INFO_GAMEPAD_FRAGMENT)
        GAMEPAD_GUILD_INFO:RefreshScreen()
    end
end

-------------------------------
-- Guild Create Explaination --
-------------------------------

function ZO_GamepadGuildHub:InitializeCreateGuildExplanation()
    local hubContainer = self.control:GetNamedChild("RightPaneContainer")

    self.creatingGuildInfoLabel = hubContainer:GetNamedChild("CreatingGuildInfo")

    self.createGuildExplanationControl = hubContainer:GetNamedChild("CreateGuildExplanation")
    
    self.createGuildExplainationFragment = ZO_FadeSceneFragment:New(self.createGuildExplanationControl, true)
end

function ZO_GamepadGuildHub:RefreshCreateGuildExplanation()
    local targetData = self.guildList:GetTargetData()
    local shouldShowCreateGuildExplanation = not targetData or targetData.isCreateGuild

    if shouldShowCreateGuildExplanation and not self.creatingGuild then
        GAMEPAD_GUILD_HUB_SCENE:AddFragment(self.createGuildExplainationFragment)
    else
        GAMEPAD_GUILD_HUB_SCENE:RemoveFragment(self.createGuildExplainationFragment)
    end
end

-------------------------------
-- Guild Browser Explanation --
-------------------------------

function ZO_GamepadGuildHub:InitializeGuildBrowserExplanation()
    local hubContainer = self.control:GetNamedChild("RightPaneContainer")

    self.guildBrowserExplanationControl = hubContainer:GetNamedChild("GuildBrowserExplanation")

    self.guildBrowserExplainationFragment = ZO_FadeSceneFragment:New(self.guildBrowserExplanationControl, true)
end

function ZO_GamepadGuildHub:RefreshGuildBrowserExplanation()
    local targetData = self.guildList:GetTargetData()
    local shouldShowGuildBrowserExplanation = not targetData or targetData.isGuildBrowser

    if shouldShowGuildBrowserExplanation and not self.isGuildBrowser then
        GAMEPAD_GUILD_HUB_SCENE:AddFragment(self.guildBrowserExplainationFragment)
    else
        GAMEPAD_GUILD_HUB_SCENE:RemoveFragment(self.guildBrowserExplainationFragment)
    end
end

------------
-- Header --
------------

function ZO_GamepadGuildHub:InitializeHeader()
    self.headerData = {
        titleText = GetString(SI_GAMEPAD_GUILD_HEADER_GUILDS_TITLE),
    }

    local rightPane = self.control:GetNamedChild("RightPaneContainer")
    local contentContainer = rightPane:GetNamedChild("ContentHeader")
    self.contentHeader = contentContainer:GetNamedChild("Header")
    ZO_GamepadGenericHeader_Initialize(self.contentHeader, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE, ZO_GAMEPAD_HEADER_LAYOUTS.DATA_PAIRS_TOGETHER)

    local function GenerateContentHeaderText()
        if self.creatingGuild then
            return self.creatingGuildTitle
        else
            local targetData = self.guildList:GetTargetData()
            if targetData then
                if targetData.isCreateGuild then
                    return GetString(SI_GUILD_CREATE_TITLE)
                elseif targetData.isGuildBrowser then
                    return GetString(SI_GAMEPAD_GUILD_GUILD_FINDER)
                end
            end
        end
    end

    local function GenerateContentHeaderDataHeaderText()
        if not self.creatingGuild then
            local targetData = self.guildList:GetTargetData()
            if targetData then
                if not targetData.isCreateGuild then
                    return GetString(SI_GAMEPAD_GUILD_FINDER_APPLICATIONS_HEADER)
                end
            end
        end
    end

    local function GenerateContentHeaderDataText()
        if not self.creatingGuild then
            local targetData = self.guildList:GetTargetData()
            if targetData then
                if not targetData.isCreateGuild then
                    return zo_strformat(SI_GUILD_BROWSER_APPLICATIONS_QUANTITY_FORMATTER, GetGuildFinderNumAccountApplications(), MAX_GUILD_FINDER_APPLICATIONS_PER_ACCOUNT)
                end
            end
        end
    end

    self.contentHeaderData = {
        titleText = GenerateContentHeaderText,
        data1HeaderText = GenerateContentHeaderDataHeaderText,
        data1Text = GenerateContentHeaderDataText,
    }
end

function ZO_GamepadGuildHub:RefreshHeader()
    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)

    ZO_GamepadGenericHeader_Refresh(self.contentHeader, self.contentHeaderData)

    local targetData = self.guildList:GetTargetData()
    local shouldShowHeader = not targetData or targetData.isCreateGuild or targetData.isGuildBrowser
    self.contentHeader:SetHidden(not shouldShowHeader)
end

--------------------
-- Key Bind Strip --
--------------------

function ZO_GamepadGuildHub:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = { 
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        -- select or create guild
        {
            name = GetString(SI_GAMEPAD_SELECT_OPTION),

            keybind = "UI_SHORTCUT_PRIMARY",

            callback = function()
                if self.displayMode == GUILD_HUB_DISPLAY_MODE.SINGLE_GUILD_LIST then
                    local targetData = self.singleGuildList:GetTargetData()
                    if targetData.selectCallback ~= nil then
                        targetData.selectCallback()
                    end
                else
                    local targetData = self.guildList:GetTargetData()
                    if targetData.isCreateGuild == true then
                        ZO_Dialogs_ShowGamepadDialog(GUILD_CREATE_GAMEPAD_DIALOG)
                    elseif targetData.isGuildBrowser == true then
                        SCENE_MANAGER:Push("guildBrowserGamepad")
                    else
                        self.optionsGuildId = targetData.guildId
                        self:ActivateSingleGuildList()
                        PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
                    end
                end
            end,

            enabled = function()
                if self.displayMode == GUILD_HUB_DISPLAY_MODE.GUILDS_LIST then
                    local targetData = self.guildList:GetTargetData()
                    return targetData and targetData.enabled
                end
                return true
            end,
        },

        -- back
        {
            name = GetString(SI_GAMEPAD_BACK_OPTION),
            keybind = "UI_SHORTCUT_NEGATIVE",

            callback = function()
                if self.displayMode ~= GUILD_HUB_DISPLAY_MODE.GUILDS_LIST then
                    self:ActivateMainList()
                    PlaySound(SOUNDS.GAMEPAD_MENU_BACK)
                else
                    SCENE_MANAGER:Hide(GAMEPAD_GUILD_HUB_SCENE_NAME)
                end
            end,
        },
    }

    self:SetListsUseTriggerKeybinds(true)
end

-----------------
-- Option List --
-----------------
function ZO_GamepadGuildHub:SetupList(list)
    list:AddDataTemplate(GAMEPAD_GUILD_LIST_ENTRY, ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction, EqualityFunction)
    list:AddDataTemplateWithHeader(GAMEPAD_GUILD_LIST_ENTRY, ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction, EqualityFunction, "ZO_GamepadMenuEntryHeaderTemplate")
    list:AddDataTemplateWithHeader(GAMEPAD_CREATE_GUILD_LIST_ENTRY, ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction, EqualityFunction, "ZO_GamepadMenuEntryHeaderTemplate")
end

do
    local ICON_INVITE = "EsoUI/Art/Guild/Gamepad/gp_guild_menuIcon_addMember.dds"
    local ICON_RELEASE_OWNERSHIP = "EsoUI/Art/Guild/Gamepad/gp_guild_menuIcon_releaseOwnership.dds"
    local ICON_CHANGE_MESSAGE = "EsoUI/Art/Guild/Gamepad/gp_guild_menuIcon_changeMessage.dds"
    local ICON_LEAVE = "EsoUI/Art/Guild/Gamepad/gp_guild_menuIcon_leaveGuild.dds"

    function ZO_GamepadGuildHub:AddOptionsToSingleGuildList()
        local firstEntry = true
        local function AddEntry(data)
            if firstEntry then
                data:SetHeader(GetString(SI_GAMEPAD_GUILD_OPTIONS_LIST_HEADER))
                self.singleGuildList:AddEntryWithHeader(GAMEPAD_OPTIONS_LIST_ENTRY, data)
                firstEntry = false
            else
                self.singleGuildList:AddEntry(GAMEPAD_OPTIONS_LIST_ENTRY, data)
            end
            data:SetIconTintOnSelection(true)
        end

        local data
        -- Options
        if DoesPlayerHaveGuildPermission(self.optionsGuildId, GUILD_PERMISSION_INVITE) then
            data = ZO_GamepadEntryData:New(GetString(SI_GUILD_INVITE_ACTION), ICON_INVITE)
            data.guildId = self.optionsGuildId
            data.selectCallback = function(optionsSelectedData)
                if ZO_IsPlaystationPlatform() then
                    ZO_ShowConsoleInviteToGuildFromUserListSelector(self.optionsGuildId)
                else
                    local name = GetGuildName(self.optionsGuildId)
                    local dialogData = {guildId = self.optionsGuildId} 
                    ZO_Dialogs_ShowGamepadDialog("GAMEPAD_GUILD_INVITE_DIALOG", dialogData, {mainTextParams = {name}})
                end
            end
            AddEntry(data)

            if GetUIPlatform() == UI_PLATFORM_XBOX and GetNumberConsoleFriends() > 0 then
                data = ZO_GamepadEntryData:New(GetString(SI_GAMEPAD_GUILD_ADD_FRIEND), ICON_INVITE)
                data.guildId = self.optionsGuildId
                data.selectCallback = function(optionsSelectedData)
                    ZO_ShowConsoleInviteToGuildFromUserListSelector(self.optionsGuildId)
                end
                AddEntry(data)
            end
        end

        if DoesGuildHaveClaimedKeep(self.optionsGuildId) and DoesPlayerHaveGuildPermission(self.optionsGuildId, GUILD_PERMISSION_RELEASE_AVA_RESOURCE) then
            data = ZO_GamepadEntryData:New(GetString(SI_GUILD_RELEASE_KEEP), ICON_RELEASE_OWNERSHIP)
            data.guildId = self.optionsGuildId
            data.selectCallback = function(optionsSelectedData)
                local keepId, campaignId = GetGuildClaimedKeep(self.optionsGuildId)
                ZO_Dialogs_ShowGamepadDialog(ZO_GAMEPAD_KEEP_RELEASE_DIALOG, { release = function() ReleaseKeepForGuild(self.optionsGuildId) end, keepId = keepId })
            end
            AddEntry(data)
        end

        if DoesPlayerHaveGuildPermission(self.optionsGuildId, GUILD_PERMISSION_SET_MOTD) then
            data = ZO_GamepadEntryData:New(GetString(SI_GAMEPAD_GUILD_INFO_CHANGE_MOTD), ICON_CHANGE_MESSAGE)
            data.guildId = self.optionsGuildId
            data.selectCallback = function(optionsSelectedData)
                ZO_Dialogs_ShowGamepadDialog(CHANGE_MOTD_GAMEPAD_DIALOG)
            end
            AddEntry(data)
        end

        if DoesPlayerHaveGuildPermission(self.optionsGuildId, GUILD_PERMISSION_DESCRIPTION_EDIT) then
            data = ZO_GamepadEntryData:New(GetString(SI_GAMEPAD_GUILD_INFO_CHANGE_ABOUT_US), ICON_CHANGE_MESSAGE)
            data.guildId = self.optionsGuildId
            data.selectCallback = function(optionsSelectedData)
                ZO_Dialogs_ShowGamepadDialog(CHANGE_ABOUT_US_GAMEPAD_DIALOG)
            end
            AddEntry(data)
        end

        if DoesPlayerHaveGuildPermission(self.optionsGuildId, GUILD_PERMISSION_GUILD_KIOSK_BID) then
            data = ZO_GamepadEntryData:New(GetString(SI_GUILD_WEEKLY_BIDS_VIEW), "EsoUI/Art/Guild/Gamepad/gp_guild_menuIcon_viewBids.dds")
            data.guildId = self.optionsGuildId
            data.selectCallback = self:GenerateShowGuildSubmenuCallback(function() GAMEPAD_GUILD_HOME:ShowWeeklyBids() end, GetString(SI_GUILD_WEEKLY_BIDS_VIEW))
            AddEntry(data)
        end

        data = ZO_GamepadEntryData:New(GetString(SI_GUILD_LEAVE), ICON_LEAVE)
        data.guildId = self.optionsGuildId
        data.selectCallback = function(optionsSelectedData)
            local function LeftGuildCallback(guildId)
                self.filteredGuildId = guildId
                self:ActivateMainList()
            end

            ZO_ShowLeaveGuildDialog(self.optionsGuildId, { leftGuildCallback = LeftGuildCallback }, true)
        end
        AddEntry(data)
    end
end

function ZO_GamepadGuildHub:ActivateMainList(blockUpdate)
    self.displayMode = GUILD_HUB_DISPLAY_MODE.GUILDS_LIST
    if blockUpdate ~= true then
        self:Update()
    end
end

---------------
-- Single Guild List --
---------------

function ZO_GamepadGuildHub:GenerateShowGuildSubmenuCallback(callback, title)
    return function()
        GAMEPAD_GUILD_HOME:SetGuildId(self.optionsGuildId)
        GAMEPAD_GUILD_HOME:SetActivateScreenInfo(callback, title)
        SCENE_MANAGER:Push("gamepad_guild_home")
    end
end

function ZO_GamepadGuildHub:RefreshSingleGuildList()
    self.singleGuildList:Clear()

    local guildId = self.optionsGuildId

    -- Guild Submenus
    local showEditRankHeaderTitle = GAMEPAD_GUILD_HOME:ShouldShowEditRankHeaderTitle()
    if not showEditRankHeaderTitle then
        local title = GetString(SI_WINDOW_TITLE_GUILD_ROSTER)
        local data = ZO_GamepadEntryData:New(title)
        data:SetIconTintOnSelection(true)
        data.optionId = GUILD_HUB_SINGLE_GUILD_LIST_OPTION.ROSTER
        data.selectCallback = self:GenerateShowGuildSubmenuCallback(function() GAMEPAD_GUILD_HOME:ShowRoster() end)
        self.singleGuildList:AddEntry(GAMEPAD_OPTIONS_LIST_ENTRY, data)
    end

    local title = SI_WINDOW_TITLE_GUILD_RANKS
    if showEditRankHeaderTitle then
        title = SI_GAMEPAD_GUILD_RANK_EDIT
    end

    title = GetString(title)
    local data = ZO_GamepadEntryData:New(title)
    data.optionId = GUILD_HUB_SINGLE_GUILD_LIST_OPTION.RANK
    data.selectCallback = self:GenerateShowGuildSubmenuCallback(function() GAMEPAD_GUILD_HOME:ShowRanks() end, title)
    self.singleGuildList:AddEntry(GAMEPAD_OPTIONS_LIST_ENTRY, data)

    title = GetString(SI_WINDOW_TITLE_GUILD_RECRUITMENT)
    data = ZO_GamepadEntryData:New(title)
    data.optionId = GUILD_HUB_SINGLE_GUILD_LIST_OPTION.RECRUITMENT
    data.selectCallback = self:GenerateShowGuildSubmenuCallback(function() GAMEPAD_GUILD_HOME:ShowRecruitment() end, title)
    self.singleGuildList:AddEntry(GAMEPAD_OPTIONS_LIST_ENTRY, data)

    if DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_HERALDRY) and IsPlayerAllowedToEditHeraldry(guildId) and not showEditRankHeaderTitle then
        title = GetString(SI_WINDOW_TITLE_GUILD_HERALDRY)
        data = ZO_GamepadEntryData:New(title)
        data.optionId = GUILD_HUB_SINGLE_GUILD_LIST_OPTION.HERALDRY
        data.selectCallback = self:GenerateShowGuildSubmenuCallback(function() GAMEPAD_GUILD_HOME:ShowHeraldry() end, title)
        self.singleGuildList:AddEntry(GAMEPAD_OPTIONS_LIST_ENTRY, data)
    end

    if not showEditRankHeaderTitle then
        title = GetString(SI_WINDOW_TITLE_GUILD_HISTORY)
        data = ZO_GamepadEntryData:New(title)
        data.optionId = GUILD_HUB_SINGLE_GUILD_LIST_OPTION.HISTORY
        data.selectCallback = self:GenerateShowGuildSubmenuCallback(function() GAMEPAD_GUILD_HOME:ShowHistory() end, title)
        self.singleGuildList:AddEntry(GAMEPAD_OPTIONS_LIST_ENTRY, data)
    end

    self:AddOptionsToSingleGuildList()

    self.singleGuildList:Commit()
end

function ZO_GamepadGuildHub:ActivateSingleGuildList()
    self.displayMode = GUILD_HUB_DISPLAY_MODE.SINGLE_GUILD_LIST
    self:Update()
end

function ZO_GamepadGuildHub:SetEnterInSingleGuildList(enterInSingleGuildList)
    -- If true, when the user next opens the Guild Hub, they will open on the single guild options submenu for the last selected guild
    -- If false, they will open on the guild selection list
    self.enterInSingleGuildList = enterInSingleGuildList
end

---------------
-- Guild Hub --
---------------

function ZO_GamepadGuildHub:OnTargetChanged(list, selectedData, oldSelectedData)
    if selectedData ~= nil then
        if self.displayMode == GUILD_HUB_DISPLAY_MODE.GUILDS_LIST then
            local refreshDueToCreateExplanation = (self.displayedCreateGuild ~= selectedData.isCreateGuild)
            local refreshDueToGuildId = (selectedData.guildId ~= nil and self.displayedGuildId ~= selectedData.guildId)
            local refreshDueToGuildBrowser = self.displayGuildBrowser ~= selectedData.isGuildBrowser

            if refreshDueToCreateExplanation or refreshDueToGuildId or refreshDueToGuildBrowser then
                if refreshDueToGuildId then
                    self.displayedGuildId = selectedData.guildId
                    GAMEPAD_GUILD_INFO:SetGuildId(self.displayedGuildId)
                end

                if refreshDueToGuildBrowser then
                    self.displayGuildBrowser = selectedData.isGuildBrowser
                end

                if refreshDueToCreateExplanation then
                    self.displayedCreateGuild = selectedData.isCreateGuild
                    if selectedData.isCreateGuild then
                        self.optionsGuildId = nil
                    end
                end

                self:UpdateContent()
            end
        end
    end
end

function ZO_GamepadGuildHub:RefreshGuildList()
    self.guildList:Clear()

    -- Entries
    local numGuilds = GetNumGuilds()
    for i = 1, numGuilds do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        local guildAlliance = GetGuildAlliance(guildId)

        local data = ZO_GamepadEntryData:New(guildName, GetLargeAllianceSymbolIcon(guildAlliance))
        data:SetFontScaleOnSelection(false)
        data:SetIconTintOnSelection(true)
        data.guildId = guildId
        if self.filteredGuildId ~= guildId then
            if i == 1 then
                data:SetHeader(GetString(SI_GAMEPAD_GUILD_LIST_MEMBERSHIP_HEADER))
                self.guildList:AddEntryWithHeader(GAMEPAD_GUILD_LIST_ENTRY, data)
            else
                self.guildList:AddEntry(GAMEPAD_GUILD_LIST_ENTRY, data)
            end
        end
    end

    local guildBrowserData = ZO_GamepadEntryData:New(GetString(SI_GAMEPAD_GUILD_GUILD_FINDER), "EsoUI/Art/GuildFinder/Gamepad/gp_guild_menuIcon_guildBrowser.dds")
    guildBrowserData:SetIconTintOnSelection(true)
    guildBrowserData:SetFontScaleOnSelection(false)
    guildBrowserData.isGuildBrowser = true
    guildBrowserData:SetHeader(GetString(SI_GAMEPAD_GUILD_LIST_NEW_HEADER))
    self.guildList:AddEntryWithHeader(GAMEPAD_GUILD_LIST_ENTRY, guildBrowserData)

    local createNewGuildData = ZO_GamepadEntryData:New(GetString(SI_GAMEPAD_GUILD_CREATE_NEW_GUILD), "EsoUI/Art/Buttons/Gamepad/gp_plus_large.dds")
    createNewGuildData:SetIconTintOnSelection(true)
    createNewGuildData:SetIconDisabledTintOnSelection(true)
    createNewGuildData:SetFontScaleOnSelection(false)
    createNewGuildData:SetEnabled(ZO_CanPlayerCreateGuild())

    createNewGuildData.isCreateGuild = true
    local createError
    if self.displayMode == GUILD_HUB_DISPLAY_MODE.GUILDS_LIST then
        createError = ZO_GetGuildCreateError()
    end
    createNewGuildData.subLabels = {createError}
    createNewGuildData.GetSubLabelColor = function() return ZO_ERROR_COLOR end
    self.guildList:AddEntry(GAMEPAD_CREATE_GUILD_LIST_ENTRY, createNewGuildData)

    self.guildList:Commit()

    self.filteredGuildId = nil
end
