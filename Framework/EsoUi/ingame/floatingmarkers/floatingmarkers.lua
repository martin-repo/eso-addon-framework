--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local function OnPlayerActivated()
    SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION, 32, "EsoUI/Art/FloatingMarkers/quest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door_assisted.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION, 32, "EsoUI/Art/FloatingMarkers/quest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door_assisted.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_ENDING, 32, "EsoUI/Art/FloatingMarkers/quest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door_assisted.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION, 32, "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door_assisted.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION, 32, "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door_assisted.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING, 32, "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door_assisted.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION, 32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door_assisted.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_OPTIONAL_CONDITION, 32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door_assisted.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_ENDING, 32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door_assisted.dds")

    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_CONDITION, 32, "EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION, 32, "EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_ENDING, 32, "EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION, 32, "EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION, 32, "EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING, 32, "EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_CONDITION, 32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_OPTIONAL_CONDITION, 32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_ENDING, 32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door.dds")

    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_CONDITION, 32, "EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION, 32, "EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_ENDING, 32, "EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_REPEATABLE_CONDITION, 32, "EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_REPEATABLE_OPTIONAL_CONDITION, 32, "EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_REPEATABLE_ENDING, 32, "EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_ZONE_STORY_CONDITION, 32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_ZONE_STORY_OPTIONAL_CONDITION, 32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_ZONE_STORY_ENDING, 32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door.dds")

    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_OFFER_ZONE_STORY, 32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_available_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_available_icon_door.dds", PULSES)

    SetFloatingMarkerInfo(MAP_PIN_TYPE_TIMELY_ESCAPE_NPC, 32, "EsoUI/Art/FloatingMarkers/timely_escape_npc.dds", "EsoUI/Art/FloatingMarkers/timely_escape_npc.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_DARK_BROTHERHOOD_TARGET, 32, "EsoUI/Art/FloatingMarkers/darkbrotherhood_target.dds", "EsoUI/Art/FloatingMarkers/darkbrotherhood_target.dds")

    local PULSES = true
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_OFFER, 32, "EsoUI/Art/FloatingMarkers/quest_available_icon.dds", "", PULSES)
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_OFFER_REPEATABLE, 32, "EsoUI/Art/FloatingMarkers/repeatableQuest_available_icon.dds", "", PULSES)
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_OFFER_ZONE_STORY, 32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_available_icon.dds", "", PULSES)
end

EVENT_MANAGER:RegisterForEvent("ZO_FloatingMarkers", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

SetFloatingMarkerGlobalAlpha(0)