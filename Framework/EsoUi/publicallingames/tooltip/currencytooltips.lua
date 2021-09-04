--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

function ZO_Tooltip:LayoutCurrency(currencyType, amount)
    if currencyType ~= CURT_NONE then
        --things added to the topSection stack upwards
        local topSection = self:AcquireSection(self:GetStyle("topSection"))
        local location = GetCurrencyPlayerStoredLocation(currencyType)
        local heldAmount = GetCurrencyAmount(currencyType, location)
        local topSubsection = topSection:AcquireSection(self:GetStyle("topSubsectionItemDetails"))
        local heldCurrencyString = ZO_Currency_FormatGamepad(currencyType, heldAmount, ZO_CURRENCY_FORMAT_AMOUNT_ICON, {
            showCap = true,
            currencyLocation = location,
        })
        topSubsection:AddLine(zo_strformat(SI_GAMEPAD_CURRENCY_INDICATOR, heldCurrencyString))
        topSection:AddSection(topSubsection)

        self:AddSection(topSection)

        -- Name
        local IS_UPPER = false
        local displayName
        if amount and amount > 1 then
            local IS_PLURAL = false
            local currencyName = GetCurrencyName(currencyType, IS_PLURAL, IS_UPPER)
            displayName = zo_strformat(SI_TOOLTIP_ITEM_NAME_WITH_QUANTITY, currencyName, amount)
        else
            local IS_SINGULAR = true
            local currencyName = GetCurrencyName(currencyType, IS_SINGULAR, IS_UPPER)
            displayName = zo_strformat(SI_TOOLTIP_ITEM_NAME, currencyName)
        end
        self:AddLine(displayName, self:GetStyle("title"))

        -- Description
        local bodySection = self:AcquireSection(self:GetStyle("collectionsInfoSection"))
        local description = GetCurrencyDescription(currencyType)
        bodySection:AddLine(description, self:GetStyle("bodyDescription"))
        self:AddSection(bodySection)
    end
end
