--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

function ZO_Tooltip:LayoutDefaultAccessTooltip(defaultAccess)
    local headerSection = self:AcquireSection(self:GetStyle("title"))
    headerSection:AddLine(GetString(SI_HOUSING_FURNITURE_SETTINGS_GENERAL_DEFAULT_ACCESS_TEXT))
    self:AddSection(headerSection)

    local bodySection = self:AcquireSection(self:GetStyle("attributeBody"))
    bodySection:AddLine(GetString(SI_HOUSING_FURNITURE_SETTINGS_GENERAL_DEFAULT_ACCESS_TOOLTIP_TEXT))
    self:AddSection(bodySection)

    local defaultVisitorAccessTitleSection = self:AcquireSection(self:GetStyle("defaultAccessTopSection"))
    local defaultVisitorAccessBodySection = self:AcquireSection(self:GetStyle("defaultAccessBody"))

    defaultVisitorAccessTitleSection:AddLine(GetString("SI_HOUSEPERMISSIONDEFAULTACCESSSETTING",  defaultAccess), self:GetStyle("defaultAccessTitle"))
    defaultVisitorAccessBodySection:AddLine(GetString("SI_HOUSEPERMISSIONDEFAULTACCESSSETTING_DESCRIPTION", defaultAccess))

    self:AddSection(defaultVisitorAccessTitleSection)
    self:AddSection(defaultVisitorAccessBodySection)
end