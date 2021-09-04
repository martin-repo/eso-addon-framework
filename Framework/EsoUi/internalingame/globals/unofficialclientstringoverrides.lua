--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

--This file contains overrides to our strings for unofficial translations since we don't allow loading custom language client string files in
--internal ingame.

local language = GetCVar("Language.2")

if language == "ru" then
    EsoStrings[SI_MARKET_PRODUCT_NAME_FORMATTER] = "<<1>>"
end