--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_ItemPreviewListHelper_Gamepad = ZO_ItemPreviewListHelper_Shared:Subclass()

function ZO_ItemPreviewListHelper_Gamepad:New(...)
    return ZO_ItemPreviewListHelper_Shared.New(self, ...)
end

function ZO_ItemPreviewListHelper_Gamepad:Initialize(...)
    ZO_ItemPreviewListHelper_Shared.Initialize(self, ...)

    self:InitializeKeybinds()
end

function ZO_ItemPreviewListHelper_Gamepad:InitializeKeybinds()
    self.keybindStripDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,

        {
            name = GetString(SI_GAMEPAD_PREVIEW_PREVIOUS),
            keybind = "UI_SHORTCUT_LEFT_TRIGGER",
            callback = function()
                self:PreviewPrevious()
            end,
            visible = function() return self:HasMultiplePreviewDatas() end,
            enabled = function() return ITEM_PREVIEW_GAMEPAD:CanChangePreview() and self:CanPreviewPrevious() end,
        },

        {
            name = GetString(SI_GAMEPAD_PREVIEW_NEXT),
            keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
            callback = function()
                self:PreviewNext()
            end,
            visible = function() return self:HasMultiplePreviewDatas() end,
            enabled = function() return ITEM_PREVIEW_GAMEPAD:CanChangePreview() and self:CanPreviewNext() end,
        },
    }
end

function ZO_ItemPreviewListHelper_Gamepad:RefreshActions()
    ZO_ItemPreviewListHelper_Shared.RefreshActions(self)

    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
end

function ZO_ItemPreviewListHelper_Gamepad:GetPreviewObject()
    return ITEM_PREVIEW_GAMEPAD
end

function ZO_ItemPreviewListHelper_Gamepad:OnShowing()
    ZO_ItemPreviewListHelper_Shared.OnShowing(self)

    KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
end

function ZO_ItemPreviewListHelper_Gamepad:OnHidden()
    ZO_ItemPreviewListHelper_Shared.OnHidden(self)

    KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
end

function ZO_ItemPreviewListHelper_Gamepad_OnInitialize(control)
    ITEM_PREVIEW_LIST_HELPER_GAMEPAD = ZO_ItemPreviewListHelper_Gamepad:New(control)
end