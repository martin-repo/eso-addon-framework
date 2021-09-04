--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_SelectGuildDialog = ZO_Object:Subclass()

function ZO_SelectGuildDialog:New(...)
    local dialog = ZO_Object.New(self)
    dialog:Initialize(...)
    return dialog
end

function ZO_SelectGuildDialog:Initialize(control, dialogName, acceptFunction, declineFunction)
    self.control = control
    self.updateGuildListWhileShown = true
    self.dialogName = dialogName
    self.acceptButton = GetControl(control, "Accept")
    self.cancelButton = GetControl(control, "Cancel")
    self.dialogInfo =
    {
        customControl = control,
        setup = function(dialogControl) self:Setup(dialogControl) end,
        noChoiceCallback = declineFunction,
        buttons =
        {
            [1] =
            {
                control =   self.acceptButton,
                text =      SI_DIALOG_ACCEPT,
                callback =  function(dialog)
                                acceptFunction(self.selectedGuildId)
                            end,
            },

            [2] =
            {
                control = self.cancelButton,
                text =      SI_DIALOG_CANCEL,
                callback = declineFunction,
            }
        }
    }

    ZO_Dialogs_RegisterCustomDialog(dialogName, self.dialogInfo)

    local guildComboBoxControl = GetControl(control, "Guild")
    self.guildComboBox = ZO_ComboBox_ObjectFromContainer(guildComboBoxControl)
    self.guildComboBox:SetSortsItems(false)
    self.guildComboBox:SetFont("ZoFontHeader")
    self.guildComboBox:SetSpacing(4)
    self.OnGuildSelectedCallback = function(_, _, entry)
        self:OnGuildSelected(entry)
    end

    control:RegisterForEvent(EVENT_GUILD_DATA_LOADED, function() self:OnGuildInformationChanged() end)
    control:RegisterForEvent(EVENT_GUILD_RANK_CHANGED, function() self:OnGuildInformationChanged() end)
    control:RegisterForEvent(EVENT_GUILD_RANKS_CHANGED, function() self:OnGuildInformationChanged() end)
    control:RegisterForEvent(EVENT_GUILD_MEMBER_RANK_CHANGED, function() self:OnGuildInformationChanged() end)
end

function ZO_SelectGuildDialog:GetSelectedGuildId()
    return self.selectedGuildId
end

function ZO_SelectGuildDialog:OnGuildSelected(entry)
    self.selectedGuildId = entry.guildId
    self.guildComboBox:SetSelectedItemText(entry.guildText)
    if self.selectedCallback then
        self.selectedCallback(entry.guildId)
    end
end

function ZO_SelectGuildDialog:SelectGuildById(guildId)
    local guildEntry = guildId ~= nil and self.entries[guildId]
    if guildEntry then
        self.guildComboBox:SelectItem(guildEntry)
    else
        self:SelectFirstGuild()
    end
end

function ZO_SelectGuildDialog:SelectFirstGuild()
    self.guildComboBox:SelectFirstItem()
end

function ZO_SelectGuildDialog:SetTitle(title)
    self.dialogInfo.title =
    {
        text = title,
    }
end

function ZO_SelectGuildDialog:SetButtonText(index, text)
    self.dialogInfo.buttons[index].text = text
    self.dialogInfo.buttons[index].control:SetText(text)
end

function ZO_SelectGuildDialog:SetPrompt(prompt)
    GetControl(self.control, "GuildHeader"):SetText(prompt)
end

function ZO_SelectGuildDialog:SetGuildFilter(filterFunction)
    self.filterFunction = filterFunction
end

function ZO_SelectGuildDialog:SetCurrentStateSource(currentStateFunction)
    self.currentStateFunction = currentStateFunction
end

function ZO_SelectGuildDialog:SetSelectedCallback(selectedCallback)
    self.selectedCallback = selectedCallback
end

function ZO_SelectGuildDialog:SetDialogUpdateFn(updateFunction)
    self.dialogInfo.updateFn = updateFunction
end

function ZO_SelectGuildDialog:SetUpdateGuildListWhileShown(updateGuildListWhileShown)
    self.updateGuildListWhileShown = updateGuildListWhileShown
end

function ZO_SelectGuildDialog:HasEntries()
    return self.entries ~= nil and next(self.entries) ~= nil
end

function ZO_SelectGuildDialog:RefreshGuildList()
    self.entries = {}
    self.guildComboBox:ClearItems()
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        if not self.filterFunction or self.filterFunction(guildId) then
            local guildName = GetGuildName(guildId)
            local guildAlliance = GetGuildAlliance(guildId)
            local guildText = zo_iconTextFormat(GetPlatformAllianceSymbolIcon(guildAlliance), 24, 24, guildName)
            local entry = self.guildComboBox:CreateItemEntry(guildText, self.OnGuildSelectedCallback)
            entry.guildId = guildId
            entry.guildText = guildText
            self.entries[guildId] = entry
            self.guildComboBox:AddItem(entry)
        end
    end

    if next(self.entries) == nil then
        return false
    end

    return true
end

function ZO_SelectGuildDialog:OnGuildInformationChanged()
    if ZO_Dialogs_IsShowing(self.dialogName) and self.updateGuildListWhileShown then
        if self:RefreshGuildList() then
            self:SelectGuildById(self.selectedGuildId)
        else
            ZO_Dialogs_ReleaseDialog(self.dialogName)
        end
    end
end

function ZO_SelectGuildDialog:Setup(control)
    if self:RefreshGuildList() then
        if self.currentStateFunction then
            local guildId = self.currentStateFunction()
            if guildId then
                self:SelectGuildById(guildId)
                return
            end
        end

        self:SelectFirstGuild()
    end
end