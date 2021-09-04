--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

function ZO_Tooltip:LayoutGuildApplicationDetails(applicationData)
    local primaryName = ZO_GetPrimaryPlayerName(applicationData.name, applicationData.characterName)
    local secondaryName = ZO_GetSecondaryPlayerName(applicationData.name, applicationData.characterName)
    
    -- Primary Name Header
    local headerSection = self:AcquireSection(self:GetStyle("socialTitle"))
    headerSection:AddLine(primaryName)
    self:AddSection(headerSection)

    -- Secondary Name 
    local characterSection = self:AcquireSection(self:GetStyle("characterNameSection"))
    characterSection:AddLine(secondaryName, self:GetStyle("socialStatsValue"))
    self:AddSection(characterSection)

    local statsSection = self:AcquireSection(self:GetStyle("socialStatsSection"))

    -- Player Level
    local statValuePair = statsSection:AcquireStatValuePair(self:GetStyle("statValuePair"), self:GetStyle("fullWidth"))
    statValuePair:SetStat(GetString(SI_GUILD_RECRUITMENT_APPLICATIONS_SORT_HEADER_LEVEL), self:GetStyle("statValuePairStat"))
    local ICON_SIZE = 40
    local levelText = GetLevelOrChampionPointsString(applicationData.level, applicationData.championPoints, ICON_SIZE)
    statValuePair:SetValue(levelText, self:GetStyle("socialStatsValue"))
    statsSection:AddStatValuePair(statValuePair)

    -- Player Class
    statValuePair = statsSection:AcquireStatValuePair(self:GetStyle("statValuePair"), self:GetStyle("fullWidth"))
    statValuePair:SetStat(GetString(SI_GUILD_RECRUITMENT_CLASS_HEADER), self:GetStyle("statValuePairStat"))
    statValuePair:SetValue(zo_strformat(SI_CLASS_NAME, GetClassName(GENDER_MALE, applicationData.class)), self:GetStyle("socialStatsValue"))
    statsSection:AddStatValuePair(statValuePair)

    -- Player Alliance
    statValuePair = statsSection:AcquireStatValuePair(self:GetStyle("statValuePair"), self:GetStyle("fullWidth"))
    statValuePair:SetStat(GetString("SI_GUILDMETADATAATTRIBUTE", GUILD_META_DATA_ATTRIBUTE_ALLIANCE), self:GetStyle("statValuePairStat"))
    statValuePair:SetValue(ZO_CachedStrFormat(SI_ALLIANCE_NAME, GetAllianceName(applicationData.alliance)), self:GetStyle("socialStatsValue"))
    statsSection:AddStatValuePair(statValuePair)

    -- Player Achievement Points
    statValuePair = statsSection:AcquireStatValuePair(self:GetStyle("statValuePair"), self:GetStyle("fullWidth"))
    statValuePair:SetStat(GetString(SI_GAMEPAD_ACHIEVEMENTS_POINTS_LABEL), self:GetStyle("statValuePairStat"))
    statValuePair:SetValue(zo_strformat(SI_NUMBER_FORMAT, applicationData.achievementPoints), self:GetStyle("socialStatsValue"))
    statsSection:AddStatValuePair(statValuePair)

    self:AddSection(statsSection)

    local bodySection = self:AcquireSection(self:GetStyle("bodySection"))
    bodySection:AddLine(applicationData.message, self:GetStyle("flavorText"))
    self:AddSection(bodySection)
end

do
    local TEXTURE_SCALE_PERCENT = 100
    function ZO_Tooltip:LayoutGuildLink(link)
        local guildName, color, linkType = ZO_LinkHandler_ParseLink(link)

        local headerSection = self:AcquireSection(self:GetStyle("topSection"))
        headerSection:AddLine(guildName, self:GetStyle("title"))
        self:AddSection(headerSection)

        local keybindString
        local key, mod1, mod2, mod3, mod4 = GetHighestPriorityActionBindingInfoFromName("UI_SHORTCUT_SECONDARY", IsInGamepadPreferredMode())
        if key ~= KEY_INVALID then
            keybindString = ZO_Keybindings_GetBindingStringFromKeys(key, mod1, mod2, mod3, mod4, KEYBIND_TEXT_OPTIONS_FULL_NAME, KEYBIND_TEXTURE_OPTIONS_EMBED_MARKUP, TEXTURE_SCALE_PERCENT)
        else
            keybindString = ZO_Keybindings_GenerateTextKeyMarkup(GetString(SI_ACTION_IS_NOT_BOUND))
        end

        local bodySection = self:AcquireSection(self:GetStyle("bodySection"))
        bodySection:AddLine(zo_strformat(SI_GAMEPAD_GUILD_LINK_TOOLTIP_DESCRIPTION, keybindString, ZO_WHITE:Colorize(guildName)), self:GetStyle("flavorText"))
        self:AddSection(bodySection)
    end
end

function ZO_Tooltip:LayoutGuildAlert(text)
    local bodySection = self:AcquireSection(self:GetStyle("bodySection"))
    bodySection:AddLine(text, self:GetStyle("failed"), self:GetStyle("flavorText"))
    self:AddSection(bodySection)
end