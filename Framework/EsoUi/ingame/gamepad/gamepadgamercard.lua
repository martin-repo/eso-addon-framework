--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

function GetGamerCardStringId()
    return ZO_IsPlaystationPlatform() and SI_PLAYER_TO_PLAYER_VIEW_PSN_PROFILE
           or SI_PLAYER_TO_PLAYER_VIEW_GAMER_CARD
end