--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

------------------
-- Guild Finder --
------------------

ZO_GuildBrowser_Applications_Keyboard = ZO_GuildFinder_Applications_Keyboard:Subclass()

function ZO_GuildBrowser_Applications_Keyboard:New(...)
    return ZO_GuildFinder_Applications_Keyboard.New(self, ...)
end

function ZO_GuildBrowser_Applications_Keyboard:Initialize(control)
    ZO_GuildFinder_Applications_Keyboard.Initialize(self, control)
end

GUILD_BROWSER_APPLICATIONS_KEYBOARD = ZO_GuildBrowser_Applications_Keyboard:New(control)