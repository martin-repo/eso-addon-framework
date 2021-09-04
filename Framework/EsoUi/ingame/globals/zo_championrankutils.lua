--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

do
    local CHAMPION_CAP = GetMaxSpendableChampionPointsInAttribute() * 3
    function GetLevelOrChampionPointsStringNoIcon(level, championPoints)
        if championPoints and championPoints > 0 then
            if championPoints > CHAMPION_CAP then
                return tostring(CHAMPION_CAP)
            else
                return tostring(championPoints)
            end
        elseif level and level > 0 then
            return tostring(level)
        else
            return ""
        end
    end
end

function GetChampionIconMarkupString(iconSize)
    if iconSize then
        local championIcon
        if IsInGamepadPreferredMode() then
            championIcon = GetGamepadChampionPointsIcon()
        else
            championIcon = GetChampionPointsIconSmall()
        end

        return zo_iconFormat(championIcon, iconSize, iconSize)
    end
end

function GetChampionIconMarkupStringInheritColor(iconSize)
    if iconSize then
        local championIcon
        if IsInGamepadPreferredMode() then
            championIcon = GetGamepadChampionPointsIcon()
        else
            championIcon = GetChampionPointsIconSmall()
        end

        return zo_iconFormatInheritColor(championIcon, iconSize, iconSize)
    end
end

function GetLevelOrChampionPointsString(level, championPoints, iconSize)
    local iconString = ""
    
    if championPoints and championPoints > 0 and iconSize then
        iconString = GetChampionIconMarkupString(iconSize)
    end
    
    return iconString .. GetLevelOrChampionPointsStringNoIcon(level, championPoints)
end

function GetLevelOrChampionPointsRangeString(minLevel, maxLevel, isChampionPoints, iconSize)
    local iconString = ""
    
    if isChampionPoints and iconSize then
        iconString = GetChampionIconMarkupString(iconSize)
    end

    return string.format("%s%s-%s", iconString, minLevel, maxLevel)
end
