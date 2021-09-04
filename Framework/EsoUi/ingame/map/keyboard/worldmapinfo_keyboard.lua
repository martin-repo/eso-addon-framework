--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local WorldMapInfo = ZO_WorldMapInfo_Shared:Subclass()

function WorldMapInfo:New(...)
    local object = ZO_WorldMapInfo_Shared.New(self, ...)
    return object
end

function WorldMapInfo:Initialize(control)
    ZO_WorldMapInfo_Shared.Initialize(self, control, ZO_FadeSceneFragment)

    WORLD_MAP_INFO_FRAGMENT = self.worldMapInfoFragment
end

function WorldMapInfo:InitializeTabs()
    local function CreateButtonData(normal, pressed, highlight, visibleFunction)
        return {
            normal = normal,
            pressed = pressed,
            highlight = highlight,
            visible = visibleFunction,
        }
    end
    
    self.modeBar = ZO_SceneFragmentBar:New(self.control:GetNamedChild("MenuBar"))
    self.modeBar:SetStartingFragment(SI_MAP_INFO_MODE_QUESTS)

    --Quests Button
    local questButtonData = CreateButtonData("EsoUI/Art/WorldMap/map_indexIcon_quests_up.dds",
                                             "EsoUI/Art/WorldMap/map_indexIcon_quests_down.dds",
                                             "EsoUI/Art/WorldMap/map_indexIcon_quests_over.dds")
    self.modeBar:Add(SI_MAP_INFO_MODE_QUESTS, { WORLD_MAP_QUESTS_FRAGMENT }, questButtonData)

    --Key Button
    local keyButtonData = CreateButtonData("EsoUI/Art/WorldMap/map_indexIcon_key_up.dds",
                                           "EsoUI/Art/WorldMap/map_indexIcon_key_down.dds",
                                           "EsoUI/Art/WorldMap/map_indexIcon_key_over.dds")
    self.modeBar:Add(SI_MAP_INFO_MODE_KEY, { WORLD_MAP_KEY_FRAGMENT }, keyButtonData)

    --Filters Button
    local filtersButtonData = CreateButtonData("EsoUI/Art/WorldMap/map_indexIcon_filters_up.dds",
                                           "EsoUI/Art/WorldMap/map_indexIcon_filters_down.dds",
                                           "EsoUI/Art/WorldMap/map_indexIcon_filters_over.dds")
    self.modeBar:Add(SI_MAP_INFO_MODE_FILTERS, { WORLD_MAP_KEY_FILTERS_FRAGMENT }, filtersButtonData) 

    --Locations Button
    local locationButtonData = CreateButtonData("EsoUI/Art/WorldMap/map_indexIcon_locations_up.dds",
                                                "EsoUI/Art/WorldMap/map_indexIcon_locations_down.dds",
                                                "EsoUI/Art/WorldMap/map_indexIcon_locations_over.dds")
    self.modeBar:Add(SI_MAP_INFO_MODE_LOCATIONS, { WORLD_MAP_LOCATIONS_FRAGMENT }, locationButtonData)

    --Houses Button
    local housesButtonData = CreateButtonData("EsoUI/Art/WorldMap/map_indexIcon_housing_up.dds",
                                                "EsoUI/Art/WorldMap/map_indexIcon_housing_down.dds",
                                                "EsoUI/Art/WorldMap/map_indexIcon_housing_over.dds")
    self.modeBar:Add(SI_MAP_INFO_MODE_HOUSES, { WORLD_MAP_HOUSES:GetFragment() }, housesButtonData)

    --Antiquities Button
    local antiquitiesButtonData = CreateButtonData("EsoUI/Art/Journal/journal_tabIcon_antiquities_up.dds",
                                                "EsoUI/Art/Journal/journal_tabIcon_antiquities_down.dds",
                                                "EsoUI/Art/Journal/journal_tabIcon_antiquities_over.dds",
                                                AreAntiquitySkillLinesDiscovered)
    self.modeBar:Add(SI_MAP_INFO_MODE_ANTIQUITIES, { WORLD_MAP_ANTIQUITIES_KEYBOARD:GetFragment() }, antiquitiesButtonData)
end

function WorldMapInfo:SelectTab(name)
    if WORLD_MAP_INFO_FRAGMENT:IsShowing() then
        self.modeBar:SelectFragment(name)
    else
        self.modeBar:SetStartingFragment(name)
    end
end

function WorldMapInfo:OnShowing()
    self.modeBar:UpdateButtons()
    self.modeBar:ShowLastFragment()
end

function WorldMapInfo:OnHidden()
    self.modeBar:Clear()
end

--Global

function ZO_WorldMapInfo_Initialize()
    WORLD_MAP_INFO = WorldMapInfo:New(ZO_WorldMapInfo)
end