--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-----------------------
-- ZO_EditBox
-----------------------

ZO_EditBox = ZO_CallbackObject:Subclass()

function ZO_EditBox:New(...)
    local object = ZO_CallbackObject.New(self)
    object:Initialize(...)
    return object
end

function ZO_EditBox:Initialize(control)
    self.control = control

    self.edit = control:GetNamedChild("Edit")
    self.empty = control:GetNamedChild("Empty")

    self.edit:SetHandler("OnTextChanged", function() self:Refresh() end)
end

function ZO_EditBox:SetDefaultText(defaultText)
    ZO_EditDefaultText_Initialize(self.edit, defaultText)
end

function ZO_EditBox:SetEmptyText(emptyText)
    self.empty:SetText(emptyText)
end

function ZO_EditBox:GetText()
    return self.edit:GetText()
end

function ZO_EditBox:SetText(text)
    local hideEmptyText = text ~= ""
    self.empty:SetHidden(hideEmptyText)

    self.edit:SetText(text)
end

function ZO_EditBox:Refresh()
    local hideEmptyText = self:GetText() ~= ""
    self.empty:SetHidden(hideEmptyText)
end

function ZO_EditBox:GetControl()
    return self.control
end

function ZO_EditBox:GetEditControl()
    return self.edit
end

function ZO_EditBox:TakeFocus()
    return self.edit:TakeFocus()
end

function ZO_EditBox:LoseFocus()
    return self.edit:LoseFocus()
end

function ZO_EditBox:OnTextChanged()
    ZO_EditDefaultText_OnTextChanged(self.edit)
end