--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

------------------
-- Guild Finder --
------------------

ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_COMBOBOX_INDENT_X = ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_INDENT_X
ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_COMBOBOX_INDENT_Y = 5
ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_COMBOBOX_INDENTS = (ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_COMBOBOX_INDENT_X * 2)
ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_COMBOBOX_ENTRY_WIDTH = ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_COLUMN_WIDTH
ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_COMBOBOX_ENTRY_HEIGHT = 90
ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_START_TIME_COMBOBOX_ENTRY_WIDTH = ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_COMBOBOX_ENTRY_WIDTH + 20
ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_COMBOBOX_LONG_ENTRY_WIDTH = (ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_COLUMN_WIDTH * 2) - 5
ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_COMBOBOX_WIDTH = ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_COMBOBOX_ENTRY_WIDTH - ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_COMBOBOX_INDENTS
ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_COMBOBOX_HEIGHT = 50
ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_COMBOBOX_TEXT_HEIGHT = ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_COMBOBOX_HEIGHT - ZO_GUILD_RECRUITMENT_GUILD_LISTING_GAMEPAD_COMBOBOX_INDENTS

-- Primary logic class must be subclassed after the platform class so that platform specific functions will have priority over the logic class functionality
ZO_GuildRecruitment_AttributeSelectionTile_Gamepad = ZO_Object.MultiSubclass(ZO_Tile_Gamepad, ZO_ActivationTile)

function ZO_GuildRecruitment_AttributeSelectionTile_Gamepad:New(...)
    return ZO_ActivationTile.New(self, ...)
end

function ZO_GuildRecruitment_AttributeSelectionTile_Gamepad:Initialize(...)
    ZO_ActivationTile.Initialize(self, ...)

    self.selectorControl = self.control:GetNamedChild("SelectorBox")
    local comboBoxControl = self.control:GetNamedChild("ComboBox")
    local comboBox = ZO_ComboBox_ObjectFromContainer(comboBoxControl)
    self.comboBox = comboBox

    self.comboBox:SetNormalColor(ZO_GAMEPAD_COMPONENT_COLORS.UNSELECTED_INACTIVE:UnpackRGB())
    self.comboBox:SetHighlightedColor(ZO_GAMEPAD_COMPONENT_COLORS.SELECTED_ACTIVE:UnpackRGB())
end

function ZO_GuildRecruitment_AttributeSelectionTile_Gamepad:OnSelectionChanged()
    ZO_Tile_Gamepad.OnSelectionChanged(self)

    self:UpdateVisualDisplay()

    self.selectorControl:SetHidden(not self:IsSelected())
end

function ZO_GuildRecruitment_AttributeSelectionTile_Gamepad:Activate()
    self.comboBox:Activate()
end

function ZO_GuildRecruitment_AttributeSelectionTile_Gamepad:Deactivate()
    self.comboBox:Deactivate()
end

function ZO_GuildRecruitment_AttributeSelectionTile_Gamepad:SetDeactivateCallback(deactivateCallback)
    ZO_ActivationTile.SetDeactivateCallback(self, deactivateCallback)

    self.comboBox:SetDeactivatedCallback(deactivateCallback)
end

function ZO_GuildRecruitment_AttributeSelectionTile_Gamepad:Layout(attributeData)
    ZO_ActivationTile.Layout(self, attributeData)

    self.attribute = attributeData.attribute
    self.titleLabel:SetText(attributeData.headerText)

    local function OnComboBoxSelection()
        if attributeData.onSelectionCallback then
            local selectedData = self.comboBox:GetSelectedItemData();
            attributeData.onSelectionCallback(self.attribute, selectedData.value)
        end
    end

    if attributeData.isTimeSelection then
        ZO_PopulateHoursSinceMidnightPerHourComboBox(self.comboBox, OnComboBoxSelection, attributeData.currentValue)
    else
        GUILD_RECRUITMENT_MANAGER.PopulateDropdown(self.comboBox, attributeData.iterBegin, attributeData.iterEnd, attributeData.stringPrefix, OnComboBoxSelection, attributeData, attributeData.omittedIndex)
    end

    self:UpdateVisualDisplay()
end

function ZO_GuildRecruitment_AttributeSelectionTile_Gamepad:UpdateVisualDisplay()
    self.comboBox:SetSelectedItemTextColor(self:IsSelected())
end

-- XML functions
----------------

function ZO_GuildRecruitment_AttributeSelectionTile_Gamepad_OnInitialized(control)
    ZO_GuildRecruitment_AttributeSelectionTile_Gamepad:New(control)
end