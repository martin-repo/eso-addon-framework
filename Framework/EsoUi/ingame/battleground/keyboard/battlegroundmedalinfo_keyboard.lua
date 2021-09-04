--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

---------------------
-- Match Info Panel --
----------------------

ZO_BATTLEGROUND_MATCH_INFO_MEDAL_ANCHOR_PADDING_Y_KEYBOARD = 10

ZO_BattlegroundMatchInfo_Keyboard = ZO_BattlegroundMatchInfo_Shared:Subclass()

function ZO_BattlegroundMatchInfo_Keyboard:New(...)
    return ZO_BattlegroundMatchInfo_Shared.New(self, ...)
end

function ZO_BattlegroundMatchInfo_Keyboard:Initialize(...)
    ZO_BattlegroundMatchInfo_Shared.Initialize(self, ...)
    BATTLEGROUND_MATCH_INFO_KEYBOARD_FRAGMENT = self:GetFragment()
    SYSTEMS:RegisterKeyboardObject("matchInfo", self)
end

function ZO_BattlegroundMatchInfo_Keyboard_OnInitialize(...)
    BATTLEGROUND_MATCH_INFO_KEYBOARD = ZO_BattlegroundMatchInfo_Keyboard:New(...)
end