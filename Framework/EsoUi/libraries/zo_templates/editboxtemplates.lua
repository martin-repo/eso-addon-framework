--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local DEFAULT_EDIT_BOX_ENABLED_COLOR = ZO_ColorDef:New(1,1,1,1)
local DEFAULT_EDIT_BOX_DISABLED_COLOR = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED))

function ZO_DefaultEdit_SetEnabled(editBox, enabled)
    if(enabled) then
        editBox:SetHandler("OnMouseDown", function() editBox:TakeFocus() end)
        editBox:SetColor(DEFAULT_EDIT_BOX_ENABLED_COLOR:UnpackRGBA())
    else
        editBox:LoseFocus()
        editBox:SetColor(DEFAULT_EDIT_BOX_DISABLED_COLOR:UnpackRGBA())
        editBox:SetHandler("OnMouseDown", nil)
    end
end

do
    local function UpdateVisibility(self)
        local label = GetControl(self, "Text")
        if(self.defaultTextEnabled) then
            if(self:GetText() == "" and not self:IsComposingIMEText()) then
                label:SetHidden(false)
            else
                label:SetHidden(true)
            end
        else
            label:SetHidden(true)
        end
    end

    function ZO_EditDefaultText_Initialize(self, defaultText)
        local label = GetControl(self, "Text")
        label:SetText(defaultText)
        self:SetDefaultTextForVirtualKeyboard(defaultText)
        self.defaultTextEnabled = true
        UpdateVisibility(self)
    end

    function ZO_EditDefaultText_Disable(self)
        self.defaultTextEnabled = false
        UpdateVisibility(self)
    end

    function ZO_EditDefaultText_OnTextChanged(self)
        UpdateVisibility(self)
    end

    function ZO_EditDefaultText_OnIMECompositionChanged(self)
        UpdateVisibility(self)
    end
end