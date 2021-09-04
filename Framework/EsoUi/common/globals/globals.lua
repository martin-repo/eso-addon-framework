--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-------------------------------------
-- Globals
--
-- Global functions specific to ESO
-------------------------------------

function ZO_ReanchorControlForLeftSidePanel(control)
    local function DoLayout()
        -- Since the control could have been resized by it's anchors clear the anchors before getting it's hieght
        control:ClearAnchors()

        local screenHeight = GuiRoot:GetHeight()
        local controlHeight = control:GetHeight()
        local offsetY = (screenHeight - controlHeight) / 2
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 245, offsetY)
    end

    control:RegisterForEvent(EVENT_SCREEN_RESIZED, DoLayout)
    DoLayout()
end

function ZO_ReanchorControlTopHorizontalMenu(control)
    local function DoLayout()
        local screenHeight = GuiRoot:GetHeight()
        local controlHeight = control:GetHeight()
        control:ClearAnchors()
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, -20, 20)
        control:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, -20, 20)
    end

    control:RegisterForEvent(EVENT_SCREEN_RESIZED, DoLayout)
    DoLayout()
end