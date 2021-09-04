--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

----
-- ZO_DailyRewardsTile_Gamepad
----

local HEADER_TEXT_COLORS = {
    SELECTED_TEXT_COLOR = ZO_NORMAL_TEXT,
    UNSELECTED_TEXT_COLOR = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_GAMEPAD_CATEGORY_HEADER))
}

-- Primary logic class must be subclassed after the platform class so that platform specific functions will have priority over the logic class functionality
ZO_DailyRewardsTile_Gamepad = ZO_Object.MultiSubclass(ZO_ClaimTile_Gamepad, ZO_DailyRewardsTile)

function ZO_DailyRewardsTile_Gamepad:New(...)
    return ZO_DailyRewardsTile.New(self, ...)
end

function ZO_DailyRewardsTile_Gamepad:SetSelected(isSelected)
    ZO_ActionTile_Gamepad.SetSelected(self, isSelected)

    if isSelected then
        self:SetHeaderColor(HEADER_TEXT_COLORS.SELECTED_TEXT_COLOR)
        self:SetTitleColor(ZO_MARKET_PRODUCT_BACKGROUND_BRIGHTNESS_COLOR)
        self:SetBackgroundColor(ZO_MARKET_PRODUCT_BACKGROUND_BRIGHTNESS_COLOR)
    else
        self:SetHeaderColor(HEADER_TEXT_COLORS.UNSELECTED_TEXT_COLOR)
        self:SetTitleColor(ZO_MARKET_DIMMED_COLOR)
        self:SetBackgroundColor(ZO_MARKET_DIMMED_COLOR)
    end
end

function ZO_DailyRewardsTile_Gamepad:ShouldUseSelectedHeaderColor()
    return self:IsSelected()
end

-----
-- Global XML Functions
-----

function ZO_DailyRewardsTile_Gamepad_OnInitialized(control)
    ZO_DailyRewardsTile_Gamepad:New(control)
end
