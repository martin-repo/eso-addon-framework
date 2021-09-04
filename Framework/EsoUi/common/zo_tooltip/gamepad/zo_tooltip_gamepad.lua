--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_GamepadTooltip = {}

local function LayoutFunction(self, tooltipType, ...)
    local tooltipContainer = self:GetTooltipContainer(tooltipType)
    if tooltipContainer == nil then
        return
    end

    local tooltipContainerTip = self:GetAndInitializeTooltipContainerTip(tooltipType)

    local tooltipFunction = tooltipContainerTip.tooltip[self.currentLayoutFunctionName] or nil
    if tooltipFunction == nil then
        return nil -- if this line fired you called a function that does not exist on ZO_GamepadTooltip or ZO_Tooltip
    end

    -- Always default the border to hidden so that tooltips to which it is not relevant don't have to deal with it.
    self:SetBorderHidden(tooltipType, true)

    local tooltipInfo = self:GetTooltipInfo(tooltipType)
    tooltipContainerTip:ClearLines(tooltipInfo.resetScroll)
    local returnValue = tooltipFunction(tooltipContainerTip.tooltip, ...)
    local tooltipFragment = self:GetTooltipFragment(tooltipType)
    if tooltipContainerTip:HasControls() then
        SCENE_MANAGER:AddFragment(tooltipFragment)
        if self:DoesAutoShowTooltipBg(tooltipType) then
            SCENE_MANAGER:AddFragment(self:GetTooltipBgFragment(tooltipType))
        end
    else
        SCENE_MANAGER:RemoveFragment(tooltipFragment)
        if self:DoesAutoShowTooltipBg(tooltipType) then
            SCENE_MANAGER:RemoveFragment(self:GetTooltipBgFragment(tooltipType))
        end
    end
    return returnValue
end

ZO_GamepadTooltip.metaTable =
{
    __index = function(t, key)
        local value = ZO_GamepadTooltip[key]
        if value == nil then
            t.currentLayoutFunctionName = key
            return LayoutFunction
        end
        return value
    end,
}

GAMEPAD_LEFT_TOOLTIP = "GAMEPAD_LEFT_TOOLTIP"
GAMEPAD_RIGHT_TOOLTIP = "GAMEPAD_RIGHT_TOOLTIP"
GAMEPAD_MOVABLE_TOOLTIP = "GAMEPAD_MOVABLE_TOOLTIP"
GAMEPAD_LEFT_DIALOG_TOOLTIP = "GAMEPAD_LEFT_DIALOG_TOOLTIP"
GAMEPAD_QUAD3_TOOLTIP = "GAMEPAD_QUAD3_TOOLTIP"
GAMEPAD_QUAD1_TOOLTIP = "GAMEPAD_QUAD1_TOOLTIP"
GAMEPAD_QUAD_2_3_TOOLTIP = "GAMEPAD_QUAD_2_3_TOOLTIP"

GAMEPAD_TOOLTIP_NORMAL_BG = 1
GAMEPAD_TOOLTIP_DARK_BG = 2

function ZO_GamepadTooltip:New(...)
    local gamepadTooltip = {}
    setmetatable(gamepadTooltip, self.metaTable)
    gamepadTooltip:Initialize(...)
    return gamepadTooltip
end

function ZO_GamepadTooltip:Initialize(control, dialogControl)
    self.control = control
    self.dialogControl = dialogControl
    self.tooltips = {}

    local AUTO_SHOW_BG = true
    local DONT_AUTO_SHOW_BG = false
    self:InitializeTooltip(GAMEPAD_LEFT_TOOLTIP, self.control, "Left", AUTO_SHOW_BG, RIGHT)
    self:InitializeTooltip(GAMEPAD_RIGHT_TOOLTIP, self.control, "Right", AUTO_SHOW_BG, LEFT)
    self:InitializeTooltip(GAMEPAD_MOVABLE_TOOLTIP, self.control, "Movable", AUTO_SHOW_BG, RIGHT)
    self:InitializeTooltip(GAMEPAD_QUAD3_TOOLTIP, self.control, "Quadrant3", AUTO_SHOW_BG, RIGHT)
    self:InitializeTooltip(GAMEPAD_QUAD1_TOOLTIP, self.control, "Quadrant1", AUTO_SHOW_BG, RIGHT)
    self:InitializeTooltip(GAMEPAD_LEFT_DIALOG_TOOLTIP, self.dialogControl, "Left", AUTO_SHOW_BG, RIGHT)
    self:InitializeTooltip(GAMEPAD_QUAD_2_3_TOOLTIP, self.control, "Quadrant_2_3_", AUTO_SHOW_BG, RIGHT, "quadrant_2_3_Tooltip")
end

function ZO_GamepadTooltip:InitializeTooltip(tooltipType, baseControl, prefix, autoShowBg, scrollIndicatorSide, style)
    local control = baseControl:GetNamedChild(prefix.."Tooltip")
    local bgControl = baseControl:GetNamedChild(prefix.."TooltipBg")
    local darkBgControl = baseControl:GetNamedChild(prefix.."TooltipDarkBg")
    local headerContainerControl = baseControl:GetNamedChild(prefix.."HeaderContainer")

    local container = control:GetNamedChild("Container")

    container.tip = container:GetNamedChild("Tip")
    container.tip.initialized = false;

    container.gamepadTooltipContainerBorderControl = container:GetNamedChild("Border")
    container.statusLabel = container:GetNamedChild("StatusLabel")
    container.statusLabelValue = container:GetNamedChild("StatusLabelValue")
    container.statusLabelValueForVisualLayer = container:GetNamedChild("StatusLabelValueForVisualLayer")
    container.statusLabelVisualLayer = container:GetNamedChild("StatusLabelVisualLayer")
    container.bottomRail = container:GetNamedChild("BottomRail")
    control.container = container

    local bgFragment = ZO_FadeSceneFragment:New(bgControl, true)
    bgControl:SetAnchorFill(control)
    _G[tooltipType.."_BACKGROUND_FRAGMENT"] = bgFragment

    local darkBgFragment = ZO_FadeSceneFragment:New(darkBgControl, true)
    _G[tooltipType.."_DARK_BACKGROUND_FRAGMENT"] = darkBgFragment
    darkBgControl:SetAnchorFill(control)

    local headerControl = nil
    if headerContainerControl ~= nil then
        local headerContainer = headerContainerControl:GetNamedChild("ContentContainer")
        if headerContainer ~= nil then
            headerControl = headerContainer:GetNamedChild("Header")
            ZO_GamepadGenericHeader_Initialize(headerControl, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE)
        end
    end

    self.tooltips[tooltipType] =
    {
        control = control,
        bgControl = bgControl,
        darkBgControl = darkBgControl,
        headerContainerControl = headerContainerControl,
        headerControl = headerControl,
        gamepadTooltipContainerBorderControl = gamepadTooltipContainerBorderControl,

        fragment = ZO_FadeSceneFragment:New(control, true),
        bgFragment = bgFragment,
        darkBgFragment = darkBgFragment,
        autoShowBg = autoShowBg,
        defaultAutoShowBg = autoShowBg,
        bgType = GAMEPAD_TOOLTIP_NORMAL_BG,
        resetScroll = true,
        scrollIndicatorSide = scrollIndicatorSide,
        style = style,
    }

    self:SetScrollIndicatorSide(tooltipType, scrollIndicatorSide)
end

--Set retainFragment to true if you intend to re-layout this tooltip immediately after calling ClearTooltip
--This saves us the performance cost of removing the fragment just to add it right back in again
--Particularly when done in an update loop
function ZO_GamepadTooltip:ClearTooltip(tooltipType, retainFragment)
    local tooltipContainer = self:GetTooltipContainer(tooltipType)
    if tooltipContainer then
        local tooltipContainerTip = self:GetAndInitializeTooltipContainerTip(tooltipType)

        local tooltipInfo = self:GetTooltipInfo(tooltipType)
        tooltipContainerTip:ClearLines(tooltipInfo.resetScroll)
        if not retainFragment then
            SCENE_MANAGER:RemoveFragment(self:GetTooltipFragment(tooltipType))
            if self:DoesAutoShowTooltipBg(tooltipType) then
                SCENE_MANAGER:RemoveFragment(self:GetTooltipBgFragment(tooltipType))
            end
        end
        self:ClearStatusLabel(tooltipType)
    end
end

function ZO_GamepadTooltip:ResetScrollTooltipToTop(tooltipType)
    local tooltipContainerTip = self:GetAndInitializeTooltipContainerTip(tooltipType)
    if tooltipContainerTip then
        tooltipContainerTip:ResetToTop()
    end
end

function ZO_GamepadTooltip:SetBorderHidden(tooltipType, isHidden)
    local container = self:GetTooltipContainer(tooltipType)
    if container.gamepadTooltipContainerBorderControl then
        container.gamepadTooltipContainerBorderControl:SetHidden(isHidden)
    end
end

function ZO_GamepadTooltip:ClearStatusLabel(tooltipType)
    self:SetStatusLabelText(tooltipType)
end

function ZO_GamepadTooltip:SetStatusLabelText(tooltipType, stat, value, visualLayer)
    if stat == nil then stat = "" end
    if value == nil then value = "" end
    if visualLayer == nil then visualLayer = "" end

    local tooltipContainer = self:GetTooltipContainer(tooltipType)
    if tooltipContainer then
        tooltipContainer.statusLabel:SetText(stat)

        if visualLayer ~= "" then
            tooltipContainer.statusLabelValueForVisualLayer:SetText(value)
        else
            tooltipContainer.statusLabelValue:SetText(value)
        end

        tooltipContainer.statusLabelVisualLayer:SetText(visualLayer)

        local hidden = stat == "" and value == "" and visualLayer == ""

        tooltipContainer.statusLabel:SetHidden(hidden)
        tooltipContainer.statusLabelVisualLayer:SetHidden(hidden)
        tooltipContainer.bottomRail:SetHidden(hidden)

        tooltipContainer.statusLabelValue:SetHidden(hidden or (visualLayer ~= ""))
        tooltipContainer.statusLabelValueForVisualLayer:SetHidden(hidden or (visualLayer == ""))
    end
end

function ZO_GamepadTooltip:SetMovableTooltipVerticalRules(leftHidden, rightHidden)
    local bgControl = self:GetTooltipInfo(GAMEPAD_MOVABLE_TOOLTIP).bgControl:GetNamedChild("Bg")
    bgControl:GetNamedChild("LeftDivider"):SetHidden(leftHidden)
    bgControl:GetNamedChild("RightDivider"):SetHidden(rightHidden)
end

function ZO_GamepadTooltip:SetMovableTooltipAnchors(anchorTable)
    local movableTooltipContainer = self:GetTooltipInfo(GAMEPAD_MOVABLE_TOOLTIP).control
    movableTooltipContainer:ClearAnchors()
    for i, anchor in ipairs(anchorTable) do
        movableTooltipContainer:SetAnchor(anchor:GetMyPoint(), anchor:GetTarget(), anchor:GetRelativePoint(), anchor:GetOffsetX(), anchor:GetOffsetY())
    end
end

function ZO_GamepadTooltip:SetScrollIndicatorSide(tooltipType, side)
    local tooltipContainer = self:GetTooltipContainer(tooltipType)
    if tooltipContainer then
        local tooltipInfo = self:GetTooltipInfo(tooltipType)
        -- we don't want to initialize the tip at this point, because we don't need it to be yet
        -- and this is called in the class initialization, which defeats the point of deferring initialization of the tip
        local tooltipContainerTip = tooltipContainer.tip
        local scrollIndicator = tooltipContainerTip:GetNamedChild("ScrollIndicator")
        ZO_Scroll_Gamepad_SetScrollIndicatorSide(scrollIndicator, tooltipInfo.bgControl, side)
    end
end

function ZO_GamepadTooltip:ShowBg(tooltipType)
    SCENE_MANAGER:AddFragment(self:GetTooltipBgFragment(tooltipType))
end

function ZO_GamepadTooltip:HideBg(tooltipType)
    SCENE_MANAGER:RemoveFragment(self:GetTooltipBgFragment(tooltipType))
end

function ZO_GamepadTooltip:SetAutoShowBg(tooltipType, autoShowBg)
    self:GetTooltipInfo(tooltipType).autoShowBg = autoShowBg
end

function ZO_GamepadTooltip:SetBgType(tooltipType, bgType)
    self:GetTooltipInfo(tooltipType).bgType = bgType
end

function ZO_GamepadTooltip:SetBgAlpha(tooltipType, alpha)
    local tooltipInfo = self:GetTooltipInfo(tooltipType)
    tooltipInfo.bgControl:GetNamedChild("Bg"):SetAlpha(alpha)
    tooltipInfo.darkBgControl:GetNamedChild("Bg"):SetAlpha(alpha)
end

function ZO_GamepadTooltip:SetTooltipResetScrollOnClear(tooltipType, resetScroll)
    local tooltipInfo = self:GetTooltipInfo(tooltipType)
    tooltipInfo.resetScroll = resetScroll
end

function ZO_GamepadTooltip:ShowGenericHeader(tooltipType, data)
    local tooltipInfo = self:GetTooltipInfo(tooltipType)
    ZO_GamepadGenericHeader_Refresh(tooltipInfo.headerControl, data)
    tooltipInfo.headerContainerControl:SetHidden(false)
end

function ZO_GamepadTooltip:Reset(tooltipType)
    local tooltipInfo = self:GetTooltipInfo(tooltipType)
    tooltipInfo.autoShowBg = tooltipInfo.defaultAutoShowBg
    tooltipInfo.bgType = GAMEPAD_TOOLTIP_NORMAL_BG
    tooltipInfo.bgControl:GetNamedChild("Bg"):SetAlpha(1)
    tooltipInfo.darkBgControl:GetNamedChild("Bg"):SetAlpha(1)
    tooltipInfo.resetScroll = true
    self:SetScrollIndicatorSide(tooltipType, tooltipInfo.scrollIndicatorSide)
    if tooltipInfo.headerContainerControl ~= nil then
        tooltipInfo.headerContainerControl:SetHidden(true)
    end
    if tooltipType == GAMEPAD_MOVABLE_TOOLTIP then
        local HIDE_LEFT_DIVIDER = false
        local HIDE_RIGHT_DIVIDER = false
        self:SetMovableTooltipVerticalRules(HIDE_LEFT_DIVIDER, HIDE_RIGHT_DIVIDER)
    end
    self:ClearTooltip(tooltipType)
end

function ZO_GamepadTooltip:GetTooltip(tooltipType)
    local tooltipContainerTip = self:GetAndInitializeTooltipContainerTip(tooltipType)

    if tooltipContainerTip then
        return tooltipContainerTip.tooltip
    end
end

function ZO_GamepadTooltip:GetTooltipContainer(tooltipType)
    return self:GetTooltipInfo(tooltipType).control.container
end

function ZO_GamepadTooltip:GetAndInitializeTooltipContainerTip(tooltipType)
    local tooltipContainer = self:GetTooltipContainer(tooltipType)

    if tooltipContainer then
        local tooltipContainerTip = tooltipContainer.tip
        if tooltipContainerTip.initialized == false then
            tooltipContainerTip.initialized = true
            ZO_ScrollTooltip_Gamepad:Initialize(tooltipContainerTip, ZO_TOOLTIP_STYLES, self:GetTooltipInfo(tooltipType).style)
            tooltipContainerTip.tooltip.gamepadTooltipContainerBorderControl = tooltipContainer.gamepadTooltipContainerBorderControl
        end
        return tooltipContainerTip
    end
end

function ZO_GamepadTooltip:GetTooltipFragment(tooltipType)
    return self:GetTooltipInfo(tooltipType).fragment
end

function ZO_GamepadTooltip:GetTooltipBgFragment(tooltipType)
    local info = self:GetTooltipInfo(tooltipType)
    if info.bgType == GAMEPAD_TOOLTIP_NORMAL_BG then
        return info.bgFragment
    elseif info.bgType == GAMEPAD_TOOLTIP_DARK_BG then
        return info.darkBgFragment
    end
end

function ZO_GamepadTooltip:AddTooltipInstantScene(tooltipType, scene)
    local info = self:GetTooltipInfo(tooltipType)
    info.fragment:AddInstantScene(scene)
    info.bgFragment:AddInstantScene(scene)
    info.darkBgFragment:AddInstantScene(scene)
end

function ZO_GamepadTooltip:DoesAutoShowTooltipBg(tooltipType)
    return self:GetTooltipInfo(tooltipType).autoShowBg
end

function ZO_GamepadTooltip:GetTooltipInfo(tooltipType)
    return self.tooltips[tooltipType]
end

function ZO_GamepadTooltip_OnInitialized(control, dialogControl)
    GAMEPAD_TOOLTIPS = ZO_GamepadTooltip:New(control, dialogControl)
end
