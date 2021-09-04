--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_MarketCurrency_Gamepad = ZO_Object.MultiSubclass(ZO_MarketCurrency_Shared, ZO_CallbackObject)

local MARKET_BUY_CROWNS_BUTTON =
{
    alignment = KEYBIND_STRIP_ALIGN_RIGHT,
    gamepadOrder = 1,
    name = GetString(SI_MARKET_BUY_CROWNS),
    keybind = "UI_SHORTCUT_SECONDARY",
    callback = ZO_ShowBuyCrownsPlatformDialog,
}

function ZO_MarketCurrency_Gamepad:Initialize(control)
    ZO_MarketCurrency_Shared.Initialize(self, control)

    MARKET_CURRENCY_GAMEPAD_FRAGMENT = ZO_FadeSceneFragment:New(control)
end

function ZO_MarketCurrency_Gamepad:InitializeControls()
    self.currencyControls = {}
    for index, data in ipairs(self.marketCurrencyTypes) do
        local marketCurrencyType = data.marketCurrencyType
        local control = CreateControlFromVirtual("$(parent)Currency"..tostring(index), self.control, "ZO_MarketCurrencyLabel_Gamepad")
        self.currencyControls[marketCurrencyType] = control

        control:GetNamedChild("Label"):SetText(ZO_Currency_GetAmountLabel(data.currencyType))
        control:SetHandler("OnEffectivelyShown", function() self:OnMarketCurrencyUpdated(marketCurrencyType) end)
    end
end

function ZO_MarketCurrency_Gamepad:Show()
    self.control:SetHidden(false)
end

function ZO_MarketCurrency_Gamepad:Hide()
    self.control:SetHidden(true)
end

function ZO_MarketCurrency_Gamepad:GetBuyCrownsKeybind(keybind)
    local keybindInfo = ZO_ShallowTableCopy(MARKET_BUY_CROWNS_BUTTON)
    if keybind then
        keybindInfo.keybind = keybind
    end
    return keybindInfo
end

function ZO_MarketCurrency_Gamepad:ModifyKeybindStripStyleForCurrency(originalStyle)
    local style = ZO_ShallowTableCopy(originalStyle)
    style.rightAnchorRelativeToControl = self.control
    style.rightAnchorRelativePoint = LEFT
    style.rightAnchorOffset = 0
    return style
end

function ZO_MarketCurrency_Gamepad:OnMarketCurrencyTypeVisibilityUpdated()
    local previousControl
    for index, data in ipairs(self.marketCurrencyTypes) do
        local control = self.currencyControls[data.marketCurrencyType]
        local visible = self:IsMarketCurrencyTypeVisible(data.marketCurrencyType)
        if visible then
            if previousControl then
                control:SetAnchor(BOTTOMRIGHT, previousControl, BOTTOMLEFT, -10)
            else
                control:SetAnchor(BOTTOMRIGHT)
            end
            previousControl = control
        end

        control:SetHidden(not visible)
    end
end

function ZO_MarketCurrency_Gamepad:OnMarketCurrencyUpdated(marketCurrencyType)
    local control = self.currencyControls[marketCurrencyType]
    if not control:IsControlHidden() then
        local currencyData = self.marketCurrencyTypeMap[marketCurrencyType]
        local currencyAmount = GetPlayerMarketCurrency(marketCurrencyType)
        local currencyString = ZO_Currency_FormatGamepad(currencyData.currencyType, currencyAmount, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
        control:GetNamedChild("Amount"):SetText(currencyString)
    end

    self:FireCallbacks("OnCurrencyUpdated")
end

function ZO_MarketCurrency_Gamepad_OnInitialized(control)
    MARKET_CURRENCY_GAMEPAD = ZO_MarketCurrency_Gamepad:New(control)
end