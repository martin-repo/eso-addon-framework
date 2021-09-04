--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

function ZO_Tooltip:LayoutCrownCrateReward(rewardIndex)
    local rewardProductType, rewardReferenceDataId = GetCrownCrateRewardProductReferenceData(rewardIndex)

    if rewardProductType == MARKET_PRODUCT_TYPE_COLLECTIBLE then
        local params =
        {
            collectibleId = rewardReferenceDataId,
            showNickname = true,
        }
        self:LayoutCollectibleWithParams(params)
    elseif rewardProductType == MARKET_PRODUCT_TYPE_ITEM then
        local itemLink = GetCrownCrateRewardItemLink(rewardIndex)
        if itemLink and itemLink ~= "" then
            self:LayoutItem(itemLink)
        end
    elseif rewardProductType == MARKET_PRODUCT_TYPE_CURRENCY then
        local stackCount = GetCrownCrateRewardStackCount(rewardIndex)
        self:LayoutCurrency(rewardReferenceDataId, stackCount)
    else
        internalassert(false, "Unsupported crown crate reward type")
    end
end