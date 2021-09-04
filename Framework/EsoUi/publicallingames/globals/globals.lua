--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-- This allows us to make the same function in InGames and Pregame while changing exactly what it calls,
-- so shared code doesn't need to know which state its in
function ZO_Disconnect()
    Disconnect()
end

MARKET_PRODUCT_DISPLAY_STATE_NOT_PURCHASED = 0
MARKET_PRODUCT_DISPLAY_STATE_PURCHASED = 1
MARKET_PRODUCT_DISPLAY_STATE_INELIGIBLE = 2

function ZO_GetMarketProductDisplayState(marketProductId)
    if IsMarketProductPurchased(marketProductId) then
        return MARKET_PRODUCT_DISPLAY_STATE_PURCHASED
    end

    local expectedClaimResult = CouldAcquireMarketProduct(marketProductId)
    if expectedClaimResult == MARKET_PURCHASE_RESULT_FAIL_INSTANT_UNLOCK_REQ_LIST then
        return MARKET_PRODUCT_DISPLAY_STATE_INELIGIBLE
    end

    if not DoesMarketProductPassPurchasableReqList(marketProductId) then
        return MARKET_PRODUCT_DISPLAY_STATE_INELIGIBLE
    end

    return MARKET_PRODUCT_DISPLAY_STATE_NOT_PURCHASED
end
