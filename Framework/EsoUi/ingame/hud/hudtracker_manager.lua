--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local HUDTracker_Manager = ZO_CallbackObject:Subclass()

function HUDTracker_Manager:New(...)
    local manager = ZO_CallbackObject.New(self)
    manager:Initialize(...)
    return manager
end

function HUDTracker_Manager:Initialize()
    local function UpdateVisibility()
        self:UpdateVisibility()
    end

    EVENT_MANAGER:RegisterForEvent("HUDTrackerManager", EVENT_ZONE_STORY_ACTIVITY_TRACKED, UpdateVisibility)
    EVENT_MANAGER:RegisterForEvent("HUDTrackerManager", EVENT_ZONE_STORY_ACTIVITY_UNTRACKED, UpdateVisibility)
    EVENT_MANAGER:RegisterForEvent("HUDTrackerManager", EVENT_ZONE_STORY_ACTIVITY_TRACKING_INIT, UpdateVisibility)

    self:UpdateVisibility()
end

function HUDTracker_Manager:UpdateVisibility()
    local isZoneStoryTracking = IsZoneStoryActivelyTracking()

    FOCUSED_QUEST_TRACKER:GetFragment():SetHiddenForReason("TrackingZoneStory", isZoneStoryTracking, DEFAULT_HUD_DURATION, DEFAULT_HUD_DURATION)
    ZONE_STORY_TRACKER:GetFragment():SetHiddenForReason("NoTrackedZoneStory", not isZoneStoryTracking, DEFAULT_HUD_DURATION, DEFAULT_HUD_DURATION)
end

HUD_TRACKER_MANAGER = HUDTracker_Manager:New()