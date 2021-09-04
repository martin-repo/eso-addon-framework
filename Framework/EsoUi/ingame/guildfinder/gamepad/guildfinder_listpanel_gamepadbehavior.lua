--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-----------------------------------------
-- Guild Finder List Panel Gamepad Behavior --
-----------------------------------------

ZO_GuildFinder_ListPanel_GamepadBehavior = ZO_Object.MultiSubclass(ZO_GuildFinder_Panel_GamepadBehavior, ZO_GamepadInteractiveSortFilterList)

function ZO_GuildFinder_ListPanel_GamepadBehavior:New(...)
    return ZO_GuildFinder_Panel_GamepadBehavior.New(self, ...)
end

function ZO_GuildFinder_ListPanel_GamepadBehavior:Initialize(control)
    ZO_GamepadInteractiveSortFilterList.Initialize(self, control)
    ZO_GuildFinder_Panel_GamepadBehavior.Initialize(self, control)

    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_GamepadInteractiveSortFilterList:SetMasterList(scrollData)
end

function ZO_GuildFinder_ListPanel_GamepadBehavior:InitializeKeybinds()
    ZO_GuildFinder_Panel_GamepadBehavior.InitializeKeybinds(self)
    ZO_GamepadInteractiveSortFilterList.InitializeKeybinds(self)
end

function ZO_GuildFinder_ListPanel_GamepadBehavior:CanBeActivated()
    return ZO_ScrollList_HasVisibleData(self.list)
end

function ZO_GuildFinder_ListPanel_GamepadBehavior:Activate()
    ZO_GamepadInteractiveSortFilterList.Activate(self)
    ZO_GuildFinder_Panel_GamepadBehavior.Activate(self)
end

function ZO_GuildFinder_ListPanel_GamepadBehavior:Deactivate()
    ZO_GamepadInteractiveSortFilterList.Deactivate(self)
    ZO_GuildFinder_Panel_GamepadBehavior.Deactivate(self)
    self:EndSelection()
end

function ZO_GuildFinder_ListPanel_GamepadBehavior:CommitScrollList()
    ZO_GamepadInteractiveSortFilterList.CommitScrollList(self)

    self:OnCommitComplete()
end

function ZO_GuildFinder_ListPanel_GamepadBehavior:GetBackKeybindCallback()
    return function()
        PlaySound(SOUNDS.GAMEPAD_MENU_BACK)
        self:EndSelection()
    end
end

function ZO_GuildFinder_ListPanel_GamepadBehavior:OnCommitComplete()
    -- To be overridden
end