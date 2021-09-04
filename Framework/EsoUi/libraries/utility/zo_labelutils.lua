--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local g_labelControl = nil

local function GetLabelControl()
    if not g_labelControl then
        g_labelControl = WINDOW_MANAGER:CreateControl("ZO_LabelUtils_UtilityLabel", GuiRoot, CT_LABEL)
    end
    return g_labelControl
end

local function GetConfiguredLabelControl(text, fontDescriptor, optionalLabelWidth, optionalLabelHeight)
    local control = GetLabelControl()
    control:SetFont(fontDescriptor)
    control:SetWidth(optionalLabelWidth)
    control:SetHeight(optionalLabelHeight)
    control:SetText(text)
    return control
end

function ZO_LabelUtils_GetNumLines(text, fontDescriptor, optionalLabelWidth, optionalLabelHeight)
    local control = GetConfiguredLabelControl(text, fontDescriptor, optionalLabelWidth, optionalLabelHeight)
    return control:GetNumLines()
end

function ZO_LabelUtils_GetTextDimensions(text, fontDescriptor, optionalLabelWidth, optionalLabelHeight)
    local control = GetConfiguredLabelControl(text, fontDescriptor, optionalLabelWidth, optionalLabelHeight)
    return control:GetTextDimensions()
end

function ZO_LabelUtils_GetFontHeight(fontDescriptor)
    local NO_TEXT = nil
    local control = GetConfiguredLabelControl(NO_TEXT, fontDescriptor)
    return control:GetFontHeight()
end