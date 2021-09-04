--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local UICombatOverlay = ZO_Object:Subclass()

function UICombatOverlay:New(control)
    local overlay = ZO_Object.New(self)
    overlay.show = false
    overlay.control = GetControl(control, "Overlay")
    overlay.pulseTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_UICombatOverlayAnimation", overlay.control)
    overlay.fadeOutTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_UICombatOverlayFadeOut", overlay.control)

    local function Refresh()
        overlay:Refresh()
    end

    control:RegisterForEvent(EVENT_PLAYER_COMBAT_STATE, Refresh)
    control:RegisterForEvent(EVENT_PLAYER_DEAD, Refresh)
    control:RegisterForEvent(EVENT_PLAYER_ALIVE, Refresh)
    control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, Refresh)

    return overlay
end

function UICombatOverlay:Refresh()
    local show = IsUnitInCombat("player") and not IsUnitDead("player")

    if(show ~= self.show) then
        self.show = show 
        
        if(show) then
            self.fadeOutTimeline:Stop()
            self.control:SetHidden(false)
            self.pulseTimeline:PlayFromStart()
        else
            self.pulseTimeline:Stop()
            self.fadeOutTimeline:PlayFromStart()
        end
    end
end

function ZO_UICombatOverlay_OnInitialized(control)
    UICombatOverlay:New(control)
end