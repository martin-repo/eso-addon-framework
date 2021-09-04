--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

function ZO_SetupInventoryItemOptionsCurrencyColor()
    if FENCE_MANAGER and SYSTEMS:GetObject("fence"):IsSellingStolenItems() and FENCE_MANAGER:HasBonusToSellingStolenItems() then
        return ZO_CURRENCY_HIGHLIGHT_TEXT
    end
end


ZO_GAMEPAD_CURRENCY_OPTIONS_LONG_FORMAT =
{
    showTooltips = false,
    font = "ZoFontGamepadHeaderDataValue",
    iconSide = RIGHT,
    isGamepad = true,
}

ZO_GAMEPAD_CURRENCY_OPTIONS = ZO_ShallowTableCopy(ZO_GAMEPAD_CURRENCY_OPTIONS_LONG_FORMAT)
ZO_GAMEPAD_CURRENCY_OPTIONS.useShortFormat = true

ZO_GAMEPAD_FENCE_CURRENCY_OPTIONS = ZO_ShallowTableCopy(ZO_GAMEPAD_CURRENCY_OPTIONS)
ZO_GAMEPAD_FENCE_CURRENCY_OPTIONS.color = ZO_SetupInventoryItemOptionsCurrencyColor

-- color value is added dynamically
ZO_BANKING_CURRENCY_LABEL_OPTIONS = ZO_ShallowTableCopy(ZO_GAMEPAD_CURRENCY_OPTIONS_LONG_FORMAT)