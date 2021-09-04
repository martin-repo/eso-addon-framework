--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

function ZO_Tooltip:LayoutGuildKioskInfo(title, body)
    self:AddLine(title, self:GetStyle("title"))

    local bodyStyle = self:GetStyle("bodySection")

    local descriptionSection = self:AcquireSection(bodyStyle)

    descriptionSection:AddLine(body, self:GetStyle("bodyDescription"))
    self:AddSection(descriptionSection)
end