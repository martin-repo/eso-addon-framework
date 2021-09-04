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

ZO_GuildRankIconPicker_Shared = ZO_Object:Subclass()

function ZO_GuildRankIconPicker_Shared:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function ZO_GuildRankIconPicker_Shared:Initialize(control, templateData)
    self.control = control

    -- This is platform specific data that needs to be overridden by the inheriting classes as it
    -- specifies the platform specific data to use.
    --[[ Expected Attributes for Icon Picker
        gridListClass - The class object from which self.rankIconPickerGridList will be created,
        entryTemplate - The name of the template control to be used for an icon in the view that allows a guild rank to select its icon,
        entryWidth - The width to be used for the the entryTemplate,
        entryHeight - The height to be used for the entryTemplate,
        entryPaddingX - The padding in pixels between icons horizontally,
        entryPaddingY - The padding in pixels between icons vertically,
    ]]
    self.templateData = templateData
end

function ZO_GuildRankIconPicker_Shared:OnRankIconPickerEntrySetup(control, data)
    assert(false) -- override in derived function
end

function ZO_GuildRankIconPicker_Shared:InitializeRankIconPickerGridList()
    local templateData = self.templateData

    self.rankIconPickerGridList = templateData.gridListClass:New(self.control)

    local function rankIconPickerEntrySetup(control, data)
        self:OnRankIconPickerEntrySetup(control, data)
    end

    local HIDE_CALLBACK = nil
    self.rankIconPickerGridList:AddEntryTemplate(templateData.entryTemplate, templateData.entryWidth, templateData.entryHeight, rankIconPickerEntrySetup, HIDE_CALLBACK, nil, templateData.entryPaddingX, templateData.entryPaddingY)

    self:BuildRankIconPickerGridList()
end

function ZO_GuildRankIconPicker_Shared:OnRankIconPickerGridListEntryClicked()
    assert(false) -- override in derived function
end

function ZO_GuildRankIconPicker_Shared:SetGetSelectedRankFunction(func)
    self.getSelectedRankFunc = func
end

function ZO_GuildRankIconPicker_Shared:SetRankIconPickedCallback(callback)
    self.rankIconPickedCallback = callback
end

function ZO_GuildRankIconPicker_Shared:CreateRankIconPickerDataObject(index)
    local data =
    {
        iconIndex = index,
        isCurrent = function()
            local selectedRank = self.getSelectedRankFunc and self.getSelectedRankFunc()
            return selectedRank and selectedRank:GetIconIndex() == index or false
        end
    }
    return data
end

function ZO_GuildRankIconPicker_Shared:BuildRankIconPickerGridList()
    self.rankIconPickerGridList:ClearGridList()

    local templateData = self.templateData
    for i = 1, GetNumGuildRankIcons() do
        local data = self:CreateRankIconPickerDataObject(i)
        self.rankIconPickerGridList:AddEntry(data, templateData.entryTemplate)
    end

    self.rankIconPickerGridList:CommitGridList()
end

function ZO_GuildRankIconPicker_Shared:RefreshGridList()
    self.rankIconPickerGridList:RefreshGridList()
end