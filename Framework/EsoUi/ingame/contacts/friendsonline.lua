--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local FriendsOnlineManager = ZO_Object:Subclass()

function FriendsOnlineManager:New(control)
    local manager = ZO_Object.New(self)
    manager.control = control
    manager:Update()
    return manager
end

function FriendsOnlineManager:Update()
    GetControl(self.control, "NumOnline"):SetText(zo_strformat(SI_FRIENDS_LIST_PANEL_NUM_ONLINE, FRIENDS_LIST_MANAGER:GetNumOnline(), GetNumFriends()))
end

function ZO_FriendsOnline_OnInitialized(self)
    FRIENDS_ONLINE = FriendsOnlineManager:New(self)
end