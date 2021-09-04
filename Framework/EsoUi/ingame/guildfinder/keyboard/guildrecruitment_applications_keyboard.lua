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

ZO_GuildRecruitment_Applications_Keyboard = ZO_Object.MultiSubclass(ZO_GuildFinder_Applications_Keyboard, ZO_GuildRecruitment_Shared)

function ZO_GuildRecruitment_Applications_Keyboard:New(...)
    return ZO_GuildFinder_Applications_Keyboard.New(self, ...)
end

function ZO_GuildRecruitment_Applications_Keyboard:Initialize(control)
    ZO_GuildFinder_Applications_Keyboard.Initialize(self, control)
    ZO_GuildRecruitment_Shared.Initialize(self, control)
end

function ZO_GuildRecruitment_Applications_Keyboard:SetGuildId(guildId)
    ZO_GuildRecruitment_Shared.SetGuildId(self, guildId)

    for _, manager in pairs(self.subcategoryManagers) do
        manager:SetGuildId(guildId)
    end
end

GUILD_RECRUITMENT_APPLICATIONS_KEYBOARD = ZO_GuildRecruitment_Applications_Keyboard:New(control)