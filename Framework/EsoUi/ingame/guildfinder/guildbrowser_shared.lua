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

ZO_GUILD_BROWSER_CATEGORY_APPLICATIONS = 1
ZO_GUILD_BROWSER_CATEGORY_GUILD_LIST = 2

ZO_GuildBrowser_Shared = ZO_Object:Subclass()

function ZO_GuildBrowser_Shared:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function ZO_GuildBrowser_Shared:Initialize(control)
    self.control = control
end

function ZO_GuildBrowser_Shared:OnShowing()
    -- should be overridden
end

function ZO_GuildBrowser_Shared:OnHidden()
    -- should be overridden
end

do
    local IS_LANGUAGE_ATTRIBUTE_FILTER_DEFAULT = ZO_CreateSetFromArguments(GetDefaultsForGuildLanguageAttributeFilter())

    function ZO_GuildBrowser_IsGuildAttributeLanguageFilterDefault(language)
        return IS_LANGUAGE_ATTRIBUTE_FILTER_DEFAULT[language] == true -- coerce to bool
    end
end