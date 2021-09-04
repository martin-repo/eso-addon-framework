--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local allianceToIcon =
{
    [ALLIANCE_DAGGERFALL_COVENANT] = "EsoUI/Art/CharacterWindow/allianceBadge_daggerfall.dds",
    [ALLIANCE_ALDMERI_DOMINION] = "EsoUI/Art/CharacterWindow/allianceBadge_aldmeri.dds",
    [ALLIANCE_EBONHEART_PACT] = "EsoUI/Art/CharacterWindow/allianceBadge_ebonheart.dds",
}

function ZO_GetAllianceIcon(alliance)
    return allianceToIcon[alliance] or allianceToIcon[ALLIANCE_DAGGERFALL_COVENANT]
end
