--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

function ZO_Tooltip:LayoutAvABonus(data)
    local headerSection = self:AcquireSection(self:GetStyle("bodyHeader"))
    headerSection:AddLine(data.name, self:GetStyle("title"))
    self:AddSection(headerSection)
    
    local bodySection = self:AcquireSection(self:GetStyle("bodySection"))

    local bonusIcon
    if IsInGamepadPreferredMode() then
        bonusIcon = zo_iconFormat(data.typeIconGamepad, 32, 32)
    else
        bonusIcon = zo_iconFormat(data.typeIcon, 40, 40)
    end

    -- emperor does't have a count, just an icon
    if data.countText then
        bodySection:AddLine(zo_strformat(SI_GAMEPAD_CAMPAIGN_BONUSES_DESCRIPTION_HEADER_WITH_AMOUNT, bonusIcon, data.countText), self:GetStyle("bodyHeader"))
    else
        bodySection:AddLine(zo_strformat(SI_GAMEPAD_CAMPAIGN_BONUSES_DESCRIPTION_HEADER_WITHOUT_AMOUNT, bonusIcon), self:GetStyle("bodyHeader"))
    end

    bodySection:AddLine(data.description, self:GetStyle("bodyDescription"))
    self:AddSection(bodySection)
end