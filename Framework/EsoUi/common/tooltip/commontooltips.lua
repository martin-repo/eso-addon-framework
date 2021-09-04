--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-- These are tooltips that are generic enough to be used by multiple UIs for various purposes
-- do not add layout functions that are specific to one UI

--If there are three or more functions for one system move it to its own file

function ZO_Tooltip:LayoutTextBlockTooltip(text)
    local section = self:AcquireSection(self:GetStyle("bodySection"))
    section:AddLine(text, self:GetStyle("bodyDescription"))
    self:AddSection(section)
end
