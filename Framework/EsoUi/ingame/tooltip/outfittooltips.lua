--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

function ZO_Tooltip:LayoutClearOutfitSlot(outfitSlot)
    --Title
    local headerSection = self:AcquireSection(self:GetStyle("bodyHeader"))
    headerSection:AddLine(GetString(SI_OUTFIT_CLEAR_OPTION_TITLE), self:GetStyle("title"))
    self:AddSection(headerSection)

    --Body
    local bodySection = self:AcquireSection(self:GetStyle("bodySection"))
    local bodyDescriptionStyle = self:GetStyle("bodyDescription")
    bodySection:AddLine(GetString(SI_OUTFIT_CLEAR_OPTION_DESCRIPTION), bodyDescriptionStyle)

    --Application cost
    local applyCost = GetOutfitSlotClearCost(outfitSlot)
    local applyCostString = ZO_Currency_FormatGamepad(CURT_MONEY, applyCost, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
    local statValuePair = bodySection:AcquireStatValuePair(self:GetStyle("statValuePair"))
    statValuePair:SetStat(GetString(SI_TOOLTIP_COLLECTIBLE_OUTFIT_STYLE_APPLICATION_COST_GAMEPAD), self:GetStyle("statValuePairStat"))
    statValuePair:SetValue(applyCostString, bodyDescriptionStyle, self:GetStyle("currencyStatValuePairValue"))
    bodySection:AddStatValuePair(statValuePair)

    self:AddSection(bodySection)
end
