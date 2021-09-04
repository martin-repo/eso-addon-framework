--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

--Keep Upgrade Type

local KeepUpgrade = ZO_KeepUpgrade_Shared:Subclass()

--Resource Upgrade Type

local ResourceUpgrade = ZO_ResourceUpgrade_Shared:Subclass()

--World Map Keep Info

local WorldMapKeepInfo = ZO_WorldMapKeepInfo_Shared:Subclass()

function WorldMapKeepInfo:New(...)
    return ZO_WorldMapKeepInfo_Shared.New(self, ...)
end

function WorldMapKeepInfo:Initialize(control)
    self.modeBar = ZO_SceneFragmentBar:New(control:GetNamedChild("MenuBar"))

    ZO_WorldMapKeepInfo_Shared.Initialize(self, control, ZO_FadeSceneFragment)

    self.keepUpgrade = KeepUpgrade:New()
    self.resourceUpgrade = ResourceUpgrade:New()
end

function WorldMapKeepInfo:GetBackgroundFragment()
    return MEDIUM_LEFT_PANEL_BG_FRAGMENT
end

function WorldMapKeepInfo:PreShowKeep()
    ZO_WorldMapKeepInfo_Shared.PreShowKeep(self)

    self.modeBar:RemoveAll()
end

function WorldMapKeepInfo:PostShowKeep()
    self.modeBar:SelectFragment(SI_MAP_KEEP_INFO_MODE_SUMMARY)
end

function WorldMapKeepInfo:BeginBar()
end

function WorldMapKeepInfo:AddBar(text, fragments, buttonData)
    self.modeBar:Add(text, fragments, buttonData)
end

function WorldMapKeepInfo:FinishBar()
end

function WorldMapKeepInfo:OnHidden()
    ZO_WorldMapKeepInfo_Shared.OnHidden(self)

    self.keepUpgradeObject = nil
    self.modeBar:Clear()
end

--Global

function ZO_WorldMapKeepInfo_OnInitialize(control)
    WORLD_MAP_KEEP_INFO = WorldMapKeepInfo:New(control)
    SYSTEMS:RegisterKeyboardObject("world_map_keep_info", WORLD_MAP_KEEP_INFO)
end