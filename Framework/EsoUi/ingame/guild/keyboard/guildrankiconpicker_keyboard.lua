--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

---------------------------
--Guild Rank Icon Picker --
---------------------------

ZO_GUILD_RANK_RANK_ICON_PICKER_PICK_KEYBOARD_SIZE = 60
ZO_GUILD_RANK_RANK_ICON_PICKER_PICK_KEYBOARD_PADDING = 0
ZO_GUILD_RANK_RANK_ICON_PICKER_ICON_KEYBOARD_SIZE = 48
ZO_GUILD_RANK_RANK_ICON_PICKER_ICON_KEYBOARD_OFFSET = 10

ZO_GuildRankIconPicker_Keyboard = ZO_GuildRankIconPicker_Shared:Subclass()

function ZO_GuildRankIconPicker_Keyboard:New(...)
    return ZO_GuildRankIconPicker_Shared.New(self, ...)
end

function ZO_GuildRankIconPicker_Keyboard:Initialize(control)
    local templateData =
    {
        gridListClass = ZO_GridScrollList_Keyboard,
        entryTemplate = "ZO_GuildRank_RankIconPickerIcon_Keyboard_Control",
        entryWidth = ZO_GUILD_RANK_RANK_ICON_PICKER_PICK_KEYBOARD_SIZE,
        entryHeight = ZO_GUILD_RANK_RANK_ICON_PICKER_PICK_KEYBOARD_SIZE,
        entryPaddingX = ZO_GUILD_RANK_RANK_ICON_PICKER_PICK_KEYBOARD_PADDING,
        entryPaddingY = ZO_GUILD_RANK_RANK_ICON_PICKER_PICK_KEYBOARD_PADDING,
    }

    ZO_GuildRankIconPicker_Shared.Initialize(self, control, templateData)

    self:InitializeRankIconPickerGridList()
end

function ZO_GuildRankIconPicker_Keyboard:OnRankIconPickerEntrySetup(control, data)
    local iconContainer = control:GetNamedChild("IconContainer")
    local checkButton = iconContainer:GetNamedChild("Frame")

    local isCurrent = data.isCurrent
    if type(isCurrent) == "function" then
        isCurrent = isCurrent()
    end

    local function OnClick()
        self:OnRankIconPickerGridListEntryClicked(data.iconIndex)
    end

    iconContainer:GetNamedChild("Icon"):SetTexture(GetGuildRankLargeIcon(data.iconIndex))
    ZO_CheckButton_SetCheckState(checkButton, isCurrent)
    ZO_CheckButton_SetToggleFunction(checkButton, OnClick)
end

function ZO_GuildRankIconPicker_Keyboard:OnRankIconPickerGridListEntryClicked(newIconIndex)
    if self.rankIconPickedCallback then
        self.rankIconPickedCallback(newIconIndex)
    end
end