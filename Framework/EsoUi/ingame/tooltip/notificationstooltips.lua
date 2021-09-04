--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

function ZO_Tooltip:LayoutNotification(note, messageText)
    local bodySection = self:AcquireSection(self:GetStyle("bodySection"))

    if messageText then
        bodySection:AddLine(messageText, self:GetStyle("bodyDescription"))
    end

    if note then
        bodySection:AddLine(note, self:GetStyle("notificationNote"))
    end

    self:AddSection(bodySection)
end