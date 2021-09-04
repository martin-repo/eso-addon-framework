--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-----------------
-- Base Leaderboard Object
-----------------

ZO_LeaderboardBase_Shared = ZO_Object:Subclass()

function ZO_LeaderboardBase_Shared:New(...)
    local manager = ZO_Object.New(self)
    manager:Initialize(...)
    return manager
end

function ZO_LeaderboardBase_Shared:Initialize(control, leaderboardSystem, leaderboardScene, fragment)
    self.control = control
    self.leaderboardSystem = leaderboardSystem
    self.leaderboardScene = leaderboardScene
    self.fragment = fragment
    self.scoringInfoText = ""
    self.timerLabelIdentifier = nil
    self.currentScoreData = nil
    self.currentRankData = nil
    self.timerLabelData = nil   
end

function ZO_LeaderboardBase_Shared:OnDataChanged()
    self.leaderboardSystem:UpdateCategories()
    self.leaderboardSystem:OnLeaderboardDataChanged(self)
end

function ZO_LeaderboardBase_Shared:OnSelected()
    self.leaderboardScene:AddFragment(self.fragment)
end

function ZO_LeaderboardBase_Shared:OnUnselected()
    self.leaderboardScene:RemoveFragment(self.fragment)
end

function ZO_LeaderboardBase_Shared:OnSubtypeSelected(subType)
    self.selectedSubType = subType
end

function ZO_LeaderboardBase_Shared:GetKeybind()
    return self.keybind
end
