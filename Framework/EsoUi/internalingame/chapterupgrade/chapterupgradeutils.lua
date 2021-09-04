--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-- InternalIngame

function ZO_ShowChapterUpgradePlatformScreen(marketOpenSource, chapterUpgradeId)
    chapterUpgradeId = chapterUpgradeId or GetCurrentChapterUpgradeId()
    if IsInGamepadPreferredMode() then
        RequestShowGamepadChapterUpgrade(chapterUpgradeId)
    else
        SYSTEMS:GetObject(ZO_MARKET_NAME):RequestShowMarket(marketOpenSource, OPEN_MARKET_BEHAVIOR_SHOW_CHAPTER_UPGRADE, chapterUpgradeId)
    end
end
