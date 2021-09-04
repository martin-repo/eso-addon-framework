--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

function GetFinalGuildRankTextureSmall(guildId, rankIndex)
    local iconIndex = GetGuildRankIconIndex(guildId, rankIndex)
    return GetGuildRankSmallIcon(iconIndex)
end

function GetFinalGuildRankTextureLarge(guildId, rankIndex)
    local iconIndex = GetGuildRankIconIndex(guildId, rankIndex)
    return GetGuildRankLargeIcon(iconIndex)
end

function GetFinalGuildRankHighlight(guildId, rankIndex)
    local iconIndex = GetGuildRankIconIndex(guildId, rankIndex)
    return GetGuildRankListHighlightIcon(iconIndex)
end

function GetFinalGuildRankTextureListDown(guildId, rankIndex)
    local iconIndex = GetGuildRankIconIndex(guildId, rankIndex)
    return GetGuildRankListDownIcon(iconIndex)
end

function GetFinalGuildRankTextureListUp(guildId, rankIndex)
    local iconIndex = GetGuildRankIconIndex(guildId, rankIndex)
    return GetGuildRankListUpIcon(iconIndex)
end

function GetDefaultGuildRankName(guildId, rankIndex)
    local rankId = GetGuildRankId(guildId, rankIndex)
    return GetString("SI_GUILDRANKS", rankId)
end

function GetFinalGuildRankName(guildId, rankIndex)
    local customName = GetGuildRankCustomName(guildId, rankIndex)
    if(customName ~= "") then
        return customName
    else
        return GetDefaultGuildRankName(guildId, rankIndex)
    end
end