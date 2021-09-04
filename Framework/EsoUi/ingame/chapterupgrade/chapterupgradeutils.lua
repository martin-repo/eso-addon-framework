--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-- Ingame

function ZO_ShowChapterUpgradePlatformScreen(marketOpenSource, chapterUpgradeId)
    chapterUpgradeId = chapterUpgradeId or GetCurrentChapterUpgradeId()
    if IsInGamepadPreferredMode() then
        ZO_CHAPTER_UPGRADE_GAMEPAD:RequestShowChapterUpgrade(chapterUpgradeId)
    else
        RequestShowMarketChapterUpgrade(marketOpenSource, chapterUpgradeId)
    end
end
