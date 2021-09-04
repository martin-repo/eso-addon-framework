--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local SPAM_WARNING_PERIOD_SECONDS = 600
local g_lastSpamWarnings = {}

function OnSpamWarningReceived(eventCode, spamType)
    local currentTime = GetFrameTimeSeconds()
    local spamTypeTime = g_lastSpamWarnings[spamType]

    if spamTypeTime == nil or currentTime - spamTypeTime > SPAM_WARNING_PERIOD_SECONDS then
        ZO_Dialogs_ShowPlatformDialog("SPAM_WARNING")
        g_lastSpamWarnings[spamType] = currentTime
    end
end

EVENT_MANAGER:RegisterForEvent("SpamWarning", EVENT_SPAM_WARNING, OnSpamWarningReceived)