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

ZO_GuildBrowser_GuildInfo_Shared = ZO_Object:Subclass()

function ZO_GuildBrowser_GuildInfo_Shared:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function ZO_GuildBrowser_GuildInfo_Shared:Initialize(control)
    self.control = control

    self.currentGuildId = 0
    self.guildRequested = nil

    local function OnGuildDataReady(guildId)
        local guildRequested = self.guildRequested
        if guildRequested then
            if guildId == guildRequested then
                self.guildRequested = nil
                self:RefreshInfoPanel()
            end
        end
    end

    local function OnGuildFinderSearchResultsReady()
        if self:IsShown() then
            self:RefreshInfoPanel()
        end
    end

    GUILD_BROWSER_MANAGER:RegisterCallback("OnGuildDataReady", OnGuildDataReady)
    GUILD_BROWSER_MANAGER:RegisterCallback("OnGuildFinderSearchResultsReady", OnGuildFinderSearchResultsReady)
end

function ZO_GuildBrowser_GuildInfo_Shared:SetGuildToShow(guildId)
    self.currentGuildId = guildId
    local guildData = GUILD_BROWSER_MANAGER:GetGuildData(guildId)
    if not guildData then
        if GUILD_BROWSER_MANAGER:RequestGuildData(guildId) then
            self.guildRequested = guildId
        else
            internalassert(false, "can't have no data and can't fetch data simultaneously")
        end
    end
end

function ZO_GuildBrowser_GuildInfo_Shared:RefreshInfoPanel()
    local guildData = GUILD_BROWSER_MANAGER:GetGuildData(self.currentGuildId)
    if guildData then
        local guildId = self.currentGuildId
        GUILD_BROWSER_MANAGER:BuildGuildHeraldryControl(self.heraldry, guildData)

        self.guildNameLabel:SetText(guildData.guildName)
        self.allianceIcon:SetTexture(self:GetAllianceIcon(guildData.alliance))

        self.headerMessageLabel:SetText(guildData.headerMessage)
        self.recruitmentMessageLabel:SetText(guildData.recruitmentMessage)
    end

    local isListed = GetGuildRecruitmentStatusAttribute(self.currentGuildId) == GUILD_RECRUITMENT_STATUS_ATTRIBUTE_VALUE_LISTED
    local shouldHide = not isListed
    self:SetInLoadingMode(shouldHide)
    self:UpdateRefreshMessage(guildData ~= nil)
end

function ZO_GuildBrowser_GuildInfo_Shared:UpdateRefreshMessage(hasGuildData)
    if hasGuildData and GetGuildRecruitmentStatusAttribute(self.currentGuildId) == GUILD_RECRUITMENT_STATUS_ATTRIBUTE_VALUE_NOT_LISTED then
        self.refreshMessageLabel:SetText(GetString(SI_GUILD_INFO_DATA_UNAVAILABLE))
    else
        self.refreshMessageLabel:SetText(GetString(SI_GUILD_INFO_FETCHING_DATA))
    end
end

function ZO_GuildBrowser_GuildInfo_Shared:GetCurrentGuildId()
    return self.currentGuildId
end

function ZO_GuildBrowser_GuildInfo_Shared:ShowWithGuild(guildId, closeCallback)
    assert(false) -- must be overridden
end

function ZO_GuildBrowser_GuildInfo_Shared:GetAllianceIcon(alliance)
    assert(false) -- must be overridden
end

function ZO_GuildBrowser_GuildInfo_Shared:SetInLoadingMode(shouldHide)
    assert(false) -- must be overridden
end

function ZO_GuildBrowser_GuildInfo_Shared:OnShowing()
    self:RefreshInfoPanel()
end

function ZO_GuildBrowser_GuildInfo_Shared:OnHidden()
    self.currentGuildId = 0
end

function ZO_GuildBrowser_GuildInfo_Shared:IsShown()
    asset(false) -- To be overridden
end