--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

HOUSING_EDITOR_POSITION_AXIS_X1 = 1
HOUSING_EDITOR_POSITION_AXIS_X2 = 2
HOUSING_EDITOR_POSITION_AXIS_Y1 = 3
HOUSING_EDITOR_POSITION_AXIS_Y2 = 4
HOUSING_EDITOR_POSITION_AXIS_Z1 = 5
HOUSING_EDITOR_POSITION_AXIS_Z2 = 6
HOUSING_EDITOR_ROTATION_AXIS_X1 = 7
HOUSING_EDITOR_ROTATION_AXIS_X2 = 8
HOUSING_EDITOR_ROTATION_AXIS_Y1 = 9
HOUSING_EDITOR_ROTATION_AXIS_Y2 = 10
HOUSING_EDITOR_ROTATION_AXIS_Z1 = 11
HOUSING_EDITOR_ROTATION_AXIS_Z2 = 12

local PI = math.pi
local TWO_PI = 2 * PI
local HALF_PI = 0.5 * PI
local QUARTER_PI = 0.25 * PI

local AXIS_INDICATOR_ALPHA_ACTIVE_PERCENTAGE = 0.4
local AXIS_INDICATOR_ALPHA_INACTIVE_PERCENTAGE = 0
local AXIS_INDICATOR_ALPHA_MAX_PERCENTAGE = 0.6
local AXIS_INDICATOR_RGB_WEIGHT_MIN_PERCENTAGE = 1.4
local AXIS_INDICATOR_RGB_WEIGHT_MAX_PERCENTAGE = 3
local AXIS_INDICATOR_SCALE_MAX = 3
local AXIS_INDICATOR_SCALE_MIN = 1
local AXIS_INDICATOR_PICKUP_YAW_OFFSET_ANGLE = math.rad(20)
local AXIS_KEYBIND_RGB_WEIGHT_MIN_PERCENTAGE = 0.3
local AXIS_KEYBIND_RGB_WEIGHT_MAX_PERCENTAGE = 0.7
local ROTATION_AXIS_INDICATOR_ALPHA_ACTIVE_PERCENTAGE = 0.7
local ROTATION_AXIS_INDICATOR_LOCAL_DIMENSIONS_M = 1.5
local TRANSLATION_AXIS_RANGE_MAX_CM = 10000
-- Texture height / width, specified in pixels.
local TRANSLATION_AXIS_INDICATOR_LOCAL_X_DIMENSION_M = 0.65
local TRANSLATION_AXIS_INDICATOR_LOCAL_Y_DIMENSION_M = 0.325
local TRANSLATION_AXIS_RANGE_INDICATOR_ALPHA = 0.26
local TRANSLATION_AXIS_RANGE_INDICATOR_LOCAL_X_DIMENSION_M = 200
local TRANSLATION_AXIS_RANGE_INDICATOR_LOCAL_Y_DIMENSION_M = 0.07

local X_AXIS_NEGATIVE_INDICATOR_COLOR = ZO_ColorDef:New(0, 0.5, 0.9, 1)
local X_AXIS_POSITIVE_INDICATOR_COLOR = ZO_ColorDef:New(0, 0.5, 0.9, 1)
local Y_AXIS_NEGATIVE_INDICATOR_COLOR = ZO_ColorDef:New(1, 0, 0.2, 1)
local Y_AXIS_POSITIVE_INDICATOR_COLOR = ZO_ColorDef:New(1, 0, 0.2, 1)
local Z_AXIS_NEGATIVE_INDICATOR_COLOR = ZO_ColorDef:New(0, 1, 0.2, 1)
local Z_AXIS_POSITIVE_INDICATOR_COLOR = ZO_ColorDef:New(0, 1, 0.2, 1)

local PRESS_AND_HOLD_ACCELERATION_INTERVAL_MS = 1000
local PRECISION_POSITION_OR_ORIENTATION_UPDATE_INTERVAL_MS = 100

local PRECISION_MOVE_UNITS_CM = {1, 10, 100}
local PRECISION_ROTATE_UNITS_DEG = {0.05, 1, 15}
local PRECISION_ROTATE_INTERVALS_MS = {[0.05] = 120000, [1] = 9000, [15] = 1200}
local PICKUP_ROTATE_INTERVALS_MS = 2000
local PICKUP_AXIS_INDICATOR_DISTANCE_CM = 1000

local PRECISION_UNIT_ADJUSTMENT_INCREMENT = 1
local PRECISION_UNIT_ADJUSTMENT_DECREMENT = 2

local TEXTURE_ARROW_DIRECTION = "EsoUI/Art/Housing/translation_arrow.dds"
local TEXTURE_ARROW_DIRECTION_INVERSE = "EsoUI/Art/Housing/translation_inverse_arrow.dds"
local TEXTURE_ARROW_ROTATION_FORWARD = "EsoUI/Art/Housing/dual_rotation_arrow.dds"
local TEXTURE_ARROW_ROTATION_REVERSE = "EsoUI/Art/Housing/dual_rotation_arrow_reverse.dds"

local function AngleDistance(angle1, angle2)
    local delta = math.abs(angle1 - angle2) % TWO_PI
    return delta < PI and delta or (TWO_PI - delta)
end

--------------------
--HousingEditor HUD Fragment
--------------------

ZO_HousingEditorHUDFragment = ZO_SceneFragment:Subclass()

function ZO_HousingEditorHUDFragment:New(control)
    return ZO_SceneFragment.New(self, control)
end

function ZO_HousingEditorHUDFragment:Show()
    self:UpdateVisibility()
    ZO_SceneFragment.Show(self)
end

function ZO_HousingEditorHUDFragment:Hide()
    self:UpdateVisibility()
    ZO_SceneFragment.Hide(self)
end

function ZO_HousingEditorHUDFragment:UpdateVisibility()
    local fragmentHidden = not self:IsShowing()
    local playerDead = IsUnitDead("player")
    local hiddenOrDead = fragmentHidden or playerDead
    RETICLE:RequestHidden(hiddenOrDead)
    TUTORIAL_SYSTEM:SuppressTutorialType(TUTORIAL_TYPE_HUD_INFO_BOX, fragmentHidden, TUTORIAL_SUPPRESSED_BY_SCENE)
    SHARED_INFORMATION_AREA:SetSupressed(hiddenOrDead)
end

--------------------
--Housing HUD Fragment
--------------------

local HousingHUDFragment = ZO_HUDFadeSceneFragment:Subclass()

function HousingHUDFragment:New(...)
    return ZO_HUDFadeSceneFragment.New(self, ...)
end

function HousingHUDFragment:Initialize(control)
    ZO_HUDFadeSceneFragment.Initialize(self, control)

    self.keybindButton = self.control:GetNamedChild("KeybindButton")
    ZO_KeybindButtonTemplate_Setup(self.keybindButton, "SHOW_HOUSING_PANEL", function(...) self:OnHousingHUDButtonPressed(...) end, GetString(SI_HOUSING_HUD_FRAGMENT_EDITOR_KEYBIND))

    control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function() self:OnPlayerActivated() end)
    control:RegisterForEvent(EVENT_HOUSING_PLAYER_INFO_CHANGED, function(eventId, ...) self:OnPlayerInfoChanged(...) end)

    self:InitializePlatformStyle()
end

do
    local KEYBOARD_PLATFORM_STYLE =
    {
        keybindButtonTemplate = "ZO_KeybindButton_Keyboard_Template",
        keybindButtonAnchor = ZO_Anchor:New(BOTTOMRIGHT, nil, BOTTOMRIGHT, -80, -25),
    }

    local GAMEPAD_PLATFORM_STYLE =
    {
        keybindButtonTemplate = "ZO_KeybindButton_Gamepad_Template",
        keybindButtonAnchor = ZO_Anchor:New(BOTTOMLEFT, nil, BOTTOMLEFT, 80, -40),
    }

    function HousingHUDFragment:InitializePlatformStyle()
        self.platformStyle = ZO_PlatformStyle:New(function(style) self:ApplyPlatformStyle(style) end, KEYBOARD_PLATFORM_STYLE, GAMEPAD_PLATFORM_STYLE)
    end
end

function HousingHUDFragment:ApplyPlatformStyle(style)
    ApplyTemplateToControl(self.keybindButton, style.keybindButtonTemplate)
    style.keybindButtonAnchor:Set(self.keybindButton)
    self:UpdateKeybind()
end

function HousingHUDFragment:OnShown()
    ZO_HUDFadeSceneFragment.OnShown(self)
    self:UpdateKeybind()
end

function HousingHUDFragment:OnHousingHUDButtonPressed()
    if self:IsShowing() then
        local visitorRole = GetHousingVisitorRole()
        if visitorRole == HOUSING_VISITOR_ROLE_EDITOR then
            local isHouseOwner = IsOwnerOfCurrentHouse()
            local canEditHouse = HasAnyEditingPermissionsForCurrentHouse()
            if not isHouseOwner and not canEditHouse then
                HousingEditorJumpToSafeLocation()
            else
                local result = HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_SELECTION)
                ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)

                if isHouseOwner and IsESOPlusSubscriber() then
                    TriggerTutorial(TUTORIAL_TRIGGER_ENTERED_OWNED_HOUSING_EDITOR_AS_SUBSCRIBER)
                end
            end
        elseif visitorRole == HOUSING_VISITOR_ROLE_PREVIEW then
            SYSTEMS:GetObject("HOUSING_PREVIEW"):ShowDialog()
        end
        PlaySound(SOUNDS.HOUSING_EDITOR_OPEN)
    end
end

do
    local KEYBIND_STRINGS =
    {
        [HOUSING_VISITOR_ROLE_EDITOR] = GetString(SI_HOUSING_HUD_FRAGMENT_EDITOR_KEYBIND),
        [HOUSING_VISITOR_ROLE_PREVIEW] = GetString(SI_HOUSING_HUD_FRAGMENT_PURCHASE_KEYBIND),
        [HOUSING_VISITOR_ROLE_HOME_SHOW] = GetString(SI_HOUSING_HUD_FRAGMENT_VOTE_KEYBIND),
    }

    function HousingHUDFragment:UpdateKeybind()
        local visitorRole = GetHousingVisitorRole()
        local isHouseOwner = IsOwnerOfCurrentHouse()
        local canEditHouse = HasAnyEditingPermissionsForCurrentHouse()

        local keybindString = KEYBIND_STRINGS[visitorRole]
        if visitorRole == HOUSING_VISITOR_ROLE_EDITOR and not isHouseOwner and not canEditHouse then
            keybindString = GetString(SI_HOUSING_EDITOR_SAFE_LOC)
        end
        self.keybindButton:SetText(keybindString)
    end
end

function HousingHUDFragment:CheckShowCopyPermissionsDialog()
    local currentZoneHouseId = GetCurrentZoneHouseId()
    local collectibleId = GetCollectibleIdForHouse(currentZoneHouseId)
    local numHousesUnlocked = GetTotalUnlockedCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_HOUSE)
    if COLLECTIONS_BOOK_SINGLETON:DoesHousePermissionsDialogNeedToBeShownForCollectible(collectibleId) and numHousesUnlocked > 1 then
        local data = { currentHouse = currentZoneHouseId }
        if IsInGamepadPreferredMode() then
            ZO_Dialogs_ShowGamepadDialog("GAMEPAD_COPY_HOUSE_PERMISSIONS", data)
        else
            ZO_Dialogs_ShowDialog("COPY_HOUSING_PERMISSIONS", data)
        end
        COLLECTIONS_BOOK_SINGLETON:MarkHouseCollectiblePermissionLoadDialogShown(collectibleId)
    end
end

function HousingHUDFragment:OnPlayerActivated()
    self:UpdateKeybind()
    self:CheckShowCopyPermissionsDialog()
end

function HousingHUDFragment:OnPlayerInfoChanged(wasOwner, permissionsChanged)
    self:UpdateKeybind()
    local isHouseOwner = IsOwnerOfCurrentHouse()
    if not isHouseOwner and permissionsChanged then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, GetString(SI_HOUSING_PLAYER_PERMISSIONS_CHANGED))
    end
end

--------------------
--HousingEditor HUD 
--------------------

ZO_HousingEditorHud = ZO_Object:Subclass()

function ZO_HousingEditorHud:New(...)
    local editor = ZO_Object.New(self)
    editor:Initialize(...)
    return editor
end

function ZO_HousingEditorHud:Initialize(control)
    self.control = control
    self.buttonContainer = control:GetNamedChild("ButtonContainer")

    self.precisionMoveButtonContainer = control:GetNamedChild("PrecisionMoveButtonContainer")
    self.precisionMoveButtons = self.precisionMoveButtonContainer:GetNamedChild("PrecisionMoveButtons")
    self.precisionMoveUnitsLabel = self.precisionMoveButtonContainer:GetNamedChild("PrecisionMoveUnitsLabel")
    self.precisionPositionLabel = self.precisionMoveButtonContainer:GetNamedChild("PrecisionPositionLabel")

    self.precisionRotateButtonContainer = control:GetNamedChild("PrecisionRotateButtonContainer")
    self.precisionRotateButtons = self.precisionRotateButtonContainer:GetNamedChild("PrecisionRotateButtons")
    self.precisionRotateUnitsLabel = self.precisionRotateButtonContainer:GetNamedChild("PrecisionRotateUnitsLabel")
    self.precisionOrientationLabel = self.precisionRotateButtonContainer:GetNamedChild("PrecisionOrientationLabel")

    self:RefreshConstants()
    self:InitializeHudControls()
    self:InitializeMovementControllers()
    self:OnDeferredInitialization()

    HOUSING_EDITOR_HUD_SCENE = ZO_Scene:New("housingEditorHud", SCENE_MANAGER)
    HOUSING_EDITOR_HUD_SCENE:RegisterCallback("StateChange",  function(oldState, newState)
        if newState == SCENE_SHOWING then
            self:OnDeferredInitialization()
            local currentMode = GetHousingEditorMode()
            if currentMode == HOUSING_EDITOR_MODE_BROWSE then -- If someone cancelled out of the browser without selecting anything.
                HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_SELECTION)
            elseif currentMode == HOUSING_EDITOR_MODE_SELECTION or currentMode == HOUSING_EDITOR_MODE_PATH then
                SCENE_MANAGER:AddFragment(ZO_HOUSING_EDITOR_HISTORY_FRAGMENT)
            end
            self:ClearPlacementKeyPresses()
            KEYBIND_STRIP:AddKeybindButtonGroup(self.exitKeybindButtonStripDescriptor)
            KEYBIND_STRIP:RemoveDefaultExit()
            SCENE_MANAGER:AddFragment(HOUSING_EDITOR_KEYBIND_PALETTE_FRAGMENT)
            self:UpdateKeybinds()
        elseif newState == SCENE_HIDDEN then
            self:ClearPlacementKeyPresses()
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.currentKeybindDescriptor)
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.pushAndPullEtherealKeybindGroup)
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.pushAndPullVisibleKeybindGroup)
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.exitKeybindButtonStripDescriptor)
            KEYBIND_STRIP:RestoreDefaultExit()
            SCENE_MANAGER:RemoveFragment(HOUSING_EDITOR_KEYBIND_PALETTE_FRAGMENT)
            self.currentKeybindDescriptor = nil
        end
    end)

    HOUSING_EDITOR_HUD_UI_SCENE = ZO_Scene:New("housingEditorHudUI", SCENE_MANAGER)
    HOUSING_EDITOR_HUD_UI_SCENE:RegisterCallback("StateChange",  function(oldState, newState)
        if newState == SCENE_SHOWING then
            self:OnDeferredInitialization()
            HOUSING_EDITOR_KEYBIND_PALETTE:RemoveKeybinds()
            if GetHousingEditorMode() ~= HOUSING_EDITOR_MODE_SELECTION then
                -- Add the HUD UI keybinds for any mode other than Selection.
                -- This is to prevent duplicate keybind registration that would result from Selection
                -- and UI mode both sharing the housing editor's tertiary action keybind.
                KEYBIND_STRIP:RemoveDefaultExit()
                KEYBIND_STRIP:AddKeybindButtonGroup(self.UIModeKeybindStripDescriptor)
                KEYBIND_STRIP:AddKeybindButtonGroup(self.pushAndPullEtherealKeybindGroup)
                KEYBIND_STRIP:AddKeybindButtonGroup(self.exitKeybindButtonStripDescriptor)
            end
            self:UnregisterDragMouseAxis()
            self:UpdateAxisIndicators()
        elseif newState == SCENE_HIDDEN then
            self:ClearPlacementKeyPresses()
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.UIModeKeybindStripDescriptor)
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.pushAndPullEtherealKeybindGroup)
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.exitKeybindButtonStripDescriptor)
            KEYBIND_STRIP:RestoreDefaultExit()
            local currentMode = GetHousingEditorMode()
            local currentModeStripDescriptor, currentModePaletteDescriptor = self:GetKeybindStripDescriptorForMode(currentMode)
            if currentModePaletteDescriptor then
                self.currentPaletteKeybindDescriptor = currentModePaletteDescriptor
                HOUSING_EDITOR_KEYBIND_PALETTE:AddKeybinds(currentModePaletteDescriptor)
            end
            self:UpdateAxisIndicators()
        end
    end)
    SCENE_MANAGER:SetSceneRestoresBaseSceneOnGameMenuToggle("housingEditorHudUI", true)

    HOUSING_EDITOR_HUD_SCENE_GROUP = ZO_SceneGroup:New("housingEditorHud", "housingEditorHudUI")
    HOUSING_EDITOR_HUD_SCENE_GROUP:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_GROUP_HIDDEN then
            local currentMode = GetHousingEditorMode()
            if currentMode ~= HOUSING_EDITOR_MODE_BROWSE and currentMode ~= HOUSING_EDITOR_MODE_PATH then
                HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_DISABLED)
                PlaySound(SOUNDS.HOUSING_EDITOR_CLOSED)
            end
        end
    end)

    local function OnHousingModeChanged(eventId, oldMode, newMode)
        self:OnHousingModeChanged(oldMode, newMode)
    end

    local function OnGamepadModeChanged(eventId, isGamepadPreferred)
        if GetHousingEditorMode() ~= HOUSING_EDITOR_MODE_DISABLED and not self.isDirty then
            HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_DISABLED)   -- Turn off housing mode if gamepad mode changes while active.
        end

        self.isDirty = true
    end

    local function OnFurnitureChanged()
        self:UpdateKeybinds()
    end

    local function OnFurniturePathDataChanged(eventId, ...)
        HOUSING_EDITOR_SHARED:UpdateKeybinds()
    end

    local function OnPathNodeSelectionChanged(eventId)
        HOUSING_EDITOR_SHARED:UpdateKeybinds()
    end

    local function OnApplySavedOptions()
        self:InitializePlacementSettings()
    end

    local function OnAddOnLoaded(event, addOnName)
        if addOnName == "ZO_Ingame" then
            EVENT_MANAGER:UnregisterForEvent("HousingEditor", EVENT_ADD_ON_LOADED)
            local defaults =
            {
                moveUnitsCentimeters = 10,
                rotateUnitsRadians = math.rad(15),
            }
            self.savedOptions = ZO_SavedVars:NewAccountWide("ZO_Ingame_SavedVariables", 1, "ZO_HousingEditor_Options", defaults)
            OnApplySavedOptions()
        end
    end

    EVENT_MANAGER:RegisterForEvent("HousingEditor", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
    EVENT_MANAGER:RegisterForEvent("HousingEditor", EVENT_PLAYER_ACTIVATED, OnApplySavedOptions)
    EVENT_MANAGER:RegisterForEvent("HousingEditor", EVENT_HOUSING_EDITOR_MODE_CHANGED, OnHousingModeChanged)
    EVENT_MANAGER:RegisterForEvent("HousingEditor", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, OnGamepadModeChanged)
    EVENT_MANAGER:RegisterForEvent("HousingEditor", EVENT_HOUSING_FURNITURE_PLACED, OnFurnitureChanged)
    EVENT_MANAGER:RegisterForEvent("HousingEditor", EVENT_HOUSING_FURNITURE_REMOVED, OnFurnitureChanged)
    EVENT_MANAGER:RegisterForEvent("HousingEditor", EVENT_HOUSING_FURNITURE_MOVED, OnFurnitureChanged)
    EVENT_MANAGER:RegisterForEvent("HousingEditor", EVENT_HOUSING_EDITOR_COMMAND_RESULT, OnFurnitureChanged)
    EVENT_MANAGER:RegisterForEvent("HousingEditor", EVENT_HOUSING_EDITOR_LINK_TARGET_CHANGED, OnFurnitureChanged)
    EVENT_MANAGER:RegisterForEvent("HousingEditor", EVENT_HOUSING_FURNITURE_PATH_DATA_CHANGED, OnFurniturePathDataChanged)
    EVENT_MANAGER:RegisterForEvent("HousingEditor", EVENT_HOUSING_PATH_NODE_SELECTION_CHANGED, OnPathNodeSelectionChanged)
    EVENT_MANAGER:RegisterForEvent("HousingEditor", EVENT_HOUSING_FURNITURE_PATH_NODES_RESTORED, OnFurnitureChanged)

    do
        local EPSILON_CM = 1
        local EPSILON_RAD = math.rad(1)
        local g_previousX, g_previousY, g_previousZ, g_previousPitch, g_previousYaw, g_previousRoll = 0, 0, 0, 0, 0, 0

        self.axisIndicatorUpdateHandler = function()
            if self.translationIndicators then
                local isSelectingAnything = HousingEditorIsSelectingHousingObject()

                if isSelectingAnything then
                    local pitch, yaw, roll = HousingEditorGetSelectedObjectOrientation()
                    local centerX, centerY, centerZ = HousingEditorGetSelectedObjectWorldCenter()

                    if AngleDistance(pitch, g_previousPitch) > EPSILON_RAD or AngleDistance(yaw, g_previousYaw) > EPSILON_RAD or AngleDistance(roll, g_previousRoll) > EPSILON_RAD then
                        g_previousPitch, g_previousYaw, g_previousRoll = pitch, yaw, roll
                    else
                        pitch, yaw, roll = g_previousPitch, g_previousYaw, g_previousRoll
                    end

                    if math.abs(centerX - g_previousX) > EPSILON_CM or math.abs(centerY - g_previousY) > EPSILON_CM or math.abs(centerZ - g_previousZ) > EPSILON_CM then
                        g_previousX, g_previousY, g_previousZ = centerX, centerY, centerZ
                    else
                        centerX, centerY, centerZ = g_previousX, g_previousY, g_previousZ
                    end

                    -- Order here matters:
                    pitch, yaw, roll = pitch % TWO_PI, yaw % TWO_PI, roll % TWO_PI
                    self:MoveAxisIndicators(centerX, centerY, centerZ, pitch, yaw, roll)
                    self.axisIndicatorWindow:SetHidden(false)
                end
            end
        end
    end

    ZO_PlatformStyle:New(function() self:ApplyPlatformStyle() end)

    control:SetHandler("OnUpdate", function(_, currentFrameTimeMS) self:OnUpdate(currentFrameTimeMS) end)
    self.isDirty = true
end

function ZO_HousingEditorHud:ApplyPlatformStyle()
    self.precisionPositionLabel:SetFont(IsInGamepadPreferredMode() and "ZoFontGamepad34" or "ZoFontGameLargeBold")
    self.precisionOrientationLabel:SetFont(IsInGamepadPreferredMode() and "ZoFontGamepad34" or "ZoFontGameLargeBold")
end

function ZO_HousingEditorHud:RefreshConstants()
    self.pushSpeedPerSecond, self.rotationStep, self.numTickForRotationChange = GetHousingEditorConstants()
    if self.yawMovementController then
        self.yawMovementController:SetAccumulationPerSecondForChange(self.numTickForRotationChange)
        self.pitchMovementController:SetAccumulationPerSecondForChange(self.numTickForRotationChange)
        self.rollMovementController:SetAccumulationPerSecondForChange(self.numTickForRotationChange)
    end
end

function ZO_HousingEditorHud:InitializePlacementSettings()
    HousingEditorSetPlacementType(HOUSING_EDITOR_PLACEMENT_TYPE_PICKUP)
    HousingEditorSetPrecisionMoveUnits(self.savedOptions.moveUnitsCentimeters)
    HousingEditorSetPrecisionRotateUnits(self.savedOptions.rotateUnitsRadians)
end

function ZO_HousingEditorHud:InitializeMovementControllers()
    local function GetButtonDirection(axis)
        return self:GetButtonDirection(axis)
    end

    self.yawMovementController = ZO_MovementController:New(AXIS_TYPE_Y, self.numTickForRotationChange, GetButtonDirection)
    self.pitchMovementController = ZO_MovementController:New(AXIS_TYPE_X, self.numTickForRotationChange, GetButtonDirection)
    self.rollMovementController = ZO_MovementController:New(AXIS_TYPE_Z, self.numTickForRotationChange, GetButtonDirection)
    self.movementControllers = {self.yawMovementController, self.pitchMovementController, self.rollMovementController}
end

function ZO_HousingEditorHud:SetKeybindPaletteHidden(hidden)
    EVENT_MANAGER:UnregisterForUpdate("ZO_HousingEditorHud_ShowKeybindPalette")
    if hidden then
        SCENE_MANAGER:RemoveFragment(HOUSING_EDITOR_KEYBIND_PALETTE_FRAGMENT)
    else
        SCENE_MANAGER:AddFragment(HOUSING_EDITOR_KEYBIND_PALETTE_FRAGMENT)
    end
end

function ZO_HousingEditorHud:SetTargetData(furnitureId, pathIndex)
    HOUSING_EDITOR_KEYBIND_PALETTE:SetTargetData(furnitureId, pathIndex)
end

function ZO_HousingEditorHud:ClearTargetData()
    local NO_VALID_FURNITURE_ID = 0
    local NO_VALID_PATH_INDEX = nil
    self:SetTargetData(NO_VALID_FURNITURE_ID, NO_VALID_PATH_INDEX)
end

function ZO_HousingEditorHud:UpdateTargetData()
    if GetHousingEditorMode() == HOUSING_EDITOR_MODE_PLACEMENT then
        self:SetTargetData(HousingEditorGetSelectedFurnitureId())
    else
        local furnitureId, pathIndex = HousingEditorGetTargetInfo()
        if CompareId64ToNumber(furnitureId, 0) > 0 then
            self:SetTargetData(furnitureId, pathIndex)
        else
            self:ClearTargetData()
        end
    end
end

do
    local function OnTargetFurnitureChanged(event)
        HOUSING_EDITOR_SHARED:UpdateTargetData()
    end

    function ZO_HousingEditorHud:SetLiveTargetingEnabled(enabled)
        if enabled then
            EVENT_MANAGER:RegisterForEvent("HousingEditor", EVENT_HOUSING_TARGET_FURNITURE_CHANGED, OnTargetFurnitureChanged)
        else
            EVENT_MANAGER:UnregisterForEvent("HousingEditor", EVENT_HOUSING_TARGET_FURNITURE_CHANGED)
        end
    end
end

function ZO_HousingEditorHud:OnHousingModeEnabled()
    OpenMarket(MARKET_DISPLAY_GROUP_HOUSE_EDITOR)
    self:CleanDirty()
    SCENE_MANAGER:SetHUDScene("housingEditorHud")
    SCENE_MANAGER:SetHUDUIScene("housingEditorHudUI", true)
    self:SetLiveTargetingEnabled(true)
end

function ZO_HousingEditorHud:OnHousingModeDisabled(oldMode)
    OnMarketClose()
    if oldMode == HOUSING_EDITOR_MODE_PATH then
        if SCENE_MANAGER:GetCurrentScene() ~= nil then
            SCENE_MANAGER:ShowBaseScene()
        end
    end
    SCENE_MANAGER:RestoreHUDScene()
    SCENE_MANAGER:RestoreHUDUIScene()
end

function ZO_HousingEditorHud:OnHousingModeChanged(oldMode, newMode)
    self:UpdateTargetData()
    self:SetKeybindPaletteHidden(false)

    if newMode == HOUSING_EDITOR_MODE_DISABLED then
        self:OnHousingModeDisabled(oldMode)
        self:SetKeybindPaletteHidden(true)
    elseif oldMode == HOUSING_EDITOR_MODE_DISABLED then
        self:OnHousingModeEnabled()
    end

    if newMode == HOUSING_EDITOR_MODE_SELECTION or newMode == HOUSING_EDITOR_MODE_PATH then
        SCENE_MANAGER:AddFragment(ZO_HOUSING_EDITOR_HISTORY_FRAGMENT)
        self:SetKeybindPaletteHidden(false)
    elseif oldMode == HOUSING_EDITOR_MODE_SELECTION or oldMode == HOUSING_EDITOR_MODE_PATH then
        SCENE_MANAGER:RemoveFragment(ZO_HOUSING_EDITOR_HISTORY_FRAGMENT)
    end

    if newMode == HOUSING_EDITOR_MODE_BROWSE then
        HousingEditorSetPlacementType(HOUSING_EDITOR_PLACEMENT_TYPE_PICKUP)
        SYSTEMS:PushScene("housing_furniture_browser")
        self:SetKeybindPaletteHidden(true)
    elseif oldMode == HOUSING_EDITOR_MODE_BROWSE then -- If something external exited the housing mode hide everything.
        if SYSTEMS:IsShowing("housing_furniture_browser") then
            SCENE_MANAGER:HideCurrentScene()
        end
    end

    if newMode == HOUSING_EDITOR_MODE_NODE_PLACEMENT then
        PushActionLayerByName("PathNodeRotationBlockCrouchLayer")
        self:SetKeybindPaletteHidden(false)
    end
    
    if oldMode == HOUSING_EDITOR_MODE_PLACEMENT or oldMode == HOUSING_EDITOR_MODE_NODE_PLACEMENT then
        RemoveActionLayerByName("PathNodeRotationBlockCrouchLayer")
        HousingEditorSetPlacementType(HOUSING_EDITOR_PLACEMENT_TYPE_PICKUP)
        self:ClearPlacementKeyPresses()
        self:UpdateAxisIndicators()
    end

    self:UpdateRotationButtonVisuals(newMode)
    self:UpdateKeybinds()
end

function ZO_HousingEditorHud:OnDeferredInitialization()
    if self.initialized then
        return
    end
    self.initialized = true
    self:InitializeAxisIndicators()
    self:InitializeKeybindDescriptors()
end

function ZO_HousingEditorHud:UpdateKeybinds()
    if not HOUSING_EDITOR_HUD_UI_SCENE:IsShowing() then
        HOUSING_EDITOR_KEYBIND_PALETTE:RemoveKeybinds()
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self.currentKeybindDescriptor)

        local currentMode = GetHousingEditorMode()
        local currentModeStripDescriptor, currentModePaletteDescriptor = self:GetKeybindStripDescriptorForMode(currentMode)

        self.currentPaletteKeybindDescriptor = currentModePaletteDescriptor
        if self.currentPaletteKeybindDescriptor then
            HOUSING_EDITOR_KEYBIND_PALETTE:AddKeybinds(self.currentPaletteKeybindDescriptor)
        end

        self.currentKeybindDescriptor = currentModeStripDescriptor
        if self.currentKeybindDescriptor then
            KEYBIND_STRIP:AddKeybindButtonGroup(self.currentKeybindDescriptor)
        end
    else
        HOUSING_EDITOR_KEYBIND_PALETTE:RefreshKeybinds()
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.currentKeybindDescriptor)
    end

    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.UIModeKeybindStripDescriptor)
    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.exitKeybindButtonStripDescriptor)

    if IsInHousingEditorPlacementMode() then
        local hideRotate = false
        local hidePrecisionRotate = true
        local hidePrecisionMove = true

        SCENE_MANAGER:AddFragment(HOUSING_EDITOR_HUD_PLACEMENT_MODE_ACTION_LAYER_FRAGMENT)

        if self:IsPrecisionEditingEnabled() then
            hideRotate = true
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.pushAndPullEtherealKeybindGroup)
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.pushAndPullVisibleKeybindGroup)
            if self:IsPrecisionPlacementRotationMode() then
                hidePrecisionRotate = false
            else
                hidePrecisionMove = false
            end
        elseif IsInGamepadPreferredMode() and GetHousingEditorMode() == HOUSING_EDITOR_MODE_NODE_PLACEMENT then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.pushAndPullEtherealKeybindGroup)
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.pushAndPullVisibleKeybindGroup)
        else
            if HousingEditorIsSurfaceDragModeEnabled() then
                KEYBIND_STRIP:RemoveKeybindButtonGroup(self.pushAndPullVisibleKeybindGroup)
                KEYBIND_STRIP:AddKeybindButtonGroup(self.pushAndPullEtherealKeybindGroup)
            else
                KEYBIND_STRIP:RemoveKeybindButtonGroup(self.pushAndPullEtherealKeybindGroup)
                KEYBIND_STRIP:AddKeybindButtonGroup(self.pushAndPullVisibleKeybindGroup)
            end
        end

        self:UpdateMovementControllerUnits()
        self.buttonContainer:SetHidden(hideRotate)
        self.precisionRotateButtonContainer:SetHidden(hidePrecisionRotate)
        self.precisionMoveButtonContainer:SetHidden(hidePrecisionMove)
    else
        SCENE_MANAGER:RemoveFragment(HOUSING_EDITOR_HUD_PLACEMENT_MODE_ACTION_LAYER_FRAGMENT)
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self.pushAndPullEtherealKeybindGroup)
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self.pushAndPullVisibleKeybindGroup)
    end 

    local rotationHidden = not IsInHousingEditorPlacementMode()

    if rotationHidden then
        HOUSING_EDITOR_HUD_SCENE:RemoveFragment(HOUSING_EDITOR_ACTION_BAR_FRAGMENT)
    else
        HOUSING_EDITOR_HUD_SCENE:AddFragment(HOUSING_EDITOR_ACTION_BAR_FRAGMENT)
    end
end

function ZO_HousingEditorHud:IsPrecisionEditingEnabled()
    return HousingEditorGetPlacementType() == HOUSING_EDITOR_PLACEMENT_TYPE_PRECISION
end

function ZO_HousingEditorHud:TogglePrecisionEditing()
    HousingEditorTogglePlacementType()
end

function ZO_HousingEditorHud:IsPrecisionPlacementMoveMode()
    return HousingEditorGetPrecisionPlacementMode() == HOUSING_EDITOR_PRECISION_PLACEMENT_MODE_MOVE
end

function ZO_HousingEditorHud:IsPrecisionPlacementRotationMode()
    return HousingEditorGetPrecisionPlacementMode() == HOUSING_EDITOR_PRECISION_PLACEMENT_MODE_ROTATE
end

function ZO_HousingEditorHud:TogglePrecisionPlacementMode()
    HousingEditorTogglePrecisionPlacementMode()
    self:ClearPlacementKeyPresses()
end

function ZO_HousingEditorHud:UpdateMovementControllerUnits()
    local accumulationCoefficient = self:IsPrecisionEditingEnabled() and 2 or 1
    local accumulationPerSecondForChange = accumulationCoefficient * self.numTickForRotationChange

    for _, controller in ipairs(self.movementControllers) do
        controller:SetAccumulationPerSecondForChange(accumulationPerSecondForChange)
    end
end

function ZO_HousingEditorHud:InitializeAxisIndicators()
    local indicatorName = "ZO_HousingEditorAxisIndicators"
    local window = WINDOW_MANAGER:CreateTopLevelWindow(indicatorName)
    self.axisIndicatorWindow = window
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMouseEnabled(false)
    window:Create3DRenderSpace()
    window:Set3DRenderSpaceAxisRotationOrder(AXIS_ROTATION_ORDER_ZXY)
    window:SetDrawLayer(DL_BACKGROUND)
    window:SetDrawTier(DT_LOW)
    window:SetHidden(true)
    
    local translationIndicatorName = "ZO_HousingEditorTranslationAxisIndicators"
    local translationWindow = WINDOW_MANAGER:CreateTopLevelWindow(translationIndicatorName)
    self.translationAxisIndicatorWindow = translationWindow
    translationWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    translationWindow:SetMouseEnabled(false)
    translationWindow:Create3DRenderSpace()
    translationWindow:SetDrawLayer(DL_BACKGROUND)
    translationWindow:SetDrawTier(DT_LOW)
    translationWindow:SetHidden(true)

    self.cameraControlName = indicatorName .. "CameraControl"
    local cameraControl = WINDOW_MANAGER:CreateControl(self.cameraControlName, window, CT_TEXTURE)
    self.cameraControl = cameraControl
    cameraControl:SetMouseEnabled(false)
    cameraControl:Create3DRenderSpace()
    cameraControl:SetHidden(true)

    local function ShouldShowPitchIndiciator()
        return GetHousingEditorMode() ~= HOUSING_EDITOR_MODE_NODE_PLACEMENT
    end

    local function ShouldShowRollIndiciator()
        return GetHousingEditorMode() ~= HOUSING_EDITOR_MODE_NODE_PLACEMENT
    end

    -- Array order matters here for visual control ordering.
    self.translationIndicators = {
        {axis = HOUSING_EDITOR_POSITION_AXIS_X1, pairedAxis = HOUSING_EDITOR_POSITION_AXIS_X2, sizeX = TRANSLATION_AXIS_INDICATOR_LOCAL_X_DIMENSION_M, sizeY = TRANSLATION_AXIS_INDICATOR_LOCAL_Y_DIMENSION_M, offsetX = -0.75, color = X_AXIS_NEGATIVE_INDICATOR_COLOR, inactiveAlpha = AXIS_INDICATOR_ALPHA_ACTIVE_PERCENTAGE, yaw = 0},
        {axis = HOUSING_EDITOR_POSITION_AXIS_X2, pairedAxis = HOUSING_EDITOR_POSITION_AXIS_X1, sizeX = TRANSLATION_AXIS_INDICATOR_LOCAL_X_DIMENSION_M, sizeY = TRANSLATION_AXIS_INDICATOR_LOCAL_Y_DIMENSION_M, offsetX =  0.75, color = X_AXIS_POSITIVE_INDICATOR_COLOR, texture = TEXTURE_ARROW_DIRECTION_INVERSE, inactiveAlpha = AXIS_INDICATOR_ALPHA_ACTIVE_PERCENTAGE, yaw = PI},
        {axis = HOUSING_EDITOR_POSITION_AXIS_Y1, pairedAxis = HOUSING_EDITOR_POSITION_AXIS_Y2, sizeX = TRANSLATION_AXIS_INDICATOR_LOCAL_Y_DIMENSION_M, sizeY = TRANSLATION_AXIS_INDICATOR_LOCAL_X_DIMENSION_M, offsetY = -0.75, color = Y_AXIS_NEGATIVE_INDICATOR_COLOR, texture = TEXTURE_ARROW_DIRECTION_INVERSE, inactiveAlpha = AXIS_INDICATOR_ALPHA_ACTIVE_PERCENTAGE, rotation = HALF_PI},
        {axis = HOUSING_EDITOR_POSITION_AXIS_Y2, pairedAxis = HOUSING_EDITOR_POSITION_AXIS_Y1, sizeX = TRANSLATION_AXIS_INDICATOR_LOCAL_Y_DIMENSION_M, sizeY = TRANSLATION_AXIS_INDICATOR_LOCAL_X_DIMENSION_M, offsetY =  0.75, color = Y_AXIS_POSITIVE_INDICATOR_COLOR, inactiveAlpha = AXIS_INDICATOR_ALPHA_ACTIVE_PERCENTAGE, rotation = -HALF_PI},
        {axis = HOUSING_EDITOR_POSITION_AXIS_Z1, pairedAxis = HOUSING_EDITOR_POSITION_AXIS_Z2, sizeX = TRANSLATION_AXIS_INDICATOR_LOCAL_X_DIMENSION_M, sizeY = TRANSLATION_AXIS_INDICATOR_LOCAL_Y_DIMENSION_M, offsetZ = -0.75, color = Z_AXIS_NEGATIVE_INDICATOR_COLOR, inactiveAlpha = AXIS_INDICATOR_ALPHA_ACTIVE_PERCENTAGE, yaw = -HALF_PI},
        {axis = HOUSING_EDITOR_POSITION_AXIS_Z2, pairedAxis = HOUSING_EDITOR_POSITION_AXIS_Z1, sizeX = TRANSLATION_AXIS_INDICATOR_LOCAL_X_DIMENSION_M, sizeY = TRANSLATION_AXIS_INDICATOR_LOCAL_Y_DIMENSION_M, offsetZ =  0.75, color = Z_AXIS_POSITIVE_INDICATOR_COLOR, texture = TEXTURE_ARROW_DIRECTION_INVERSE, inactiveAlpha = AXIS_INDICATOR_ALPHA_ACTIVE_PERCENTAGE, yaw = HALF_PI},
    }
    self.rotationIndicators = {
        {axis = HOUSING_EDITOR_ROTATION_AXIS_X1, sizeX = ROTATION_AXIS_INDICATOR_LOCAL_DIMENSIONS_M, sizeY = ROTATION_AXIS_INDICATOR_LOCAL_DIMENSIONS_M, inactiveAlpha = ROTATION_AXIS_INDICATOR_ALPHA_ACTIVE_PERCENTAGE,   scale = 1, color = X_AXIS_NEGATIVE_INDICATOR_COLOR, texture = TEXTURE_ARROW_ROTATION_FORWARD, pitch = HALF_PI, yaw = -HALF_PI },
        {axis = HOUSING_EDITOR_ROTATION_AXIS_X2, sizeX = ROTATION_AXIS_INDICATOR_LOCAL_DIMENSIONS_M, sizeY = ROTATION_AXIS_INDICATOR_LOCAL_DIMENSIONS_M, inactiveAlpha = AXIS_INDICATOR_ALPHA_INACTIVE_PERCENTAGE, scale = 1, color = X_AXIS_POSITIVE_INDICATOR_COLOR, texture = TEXTURE_ARROW_ROTATION_REVERSE, pitch = HALF_PI, yaw =  HALF_PI },
        {axis = HOUSING_EDITOR_ROTATION_AXIS_Y1, sizeX = ROTATION_AXIS_INDICATOR_LOCAL_DIMENSIONS_M, sizeY = ROTATION_AXIS_INDICATOR_LOCAL_DIMENSIONS_M, inactiveAlpha = ROTATION_AXIS_INDICATOR_ALPHA_ACTIVE_PERCENTAGE,   scale = 0.66, color = Y_AXIS_NEGATIVE_INDICATOR_COLOR, texture = TEXTURE_ARROW_ROTATION_FORWARD, yaw = 0, visible = ShouldShowPitchIndiciator },
        {axis = HOUSING_EDITOR_ROTATION_AXIS_Y2, sizeX = ROTATION_AXIS_INDICATOR_LOCAL_DIMENSIONS_M, sizeY = ROTATION_AXIS_INDICATOR_LOCAL_DIMENSIONS_M, inactiveAlpha = AXIS_INDICATOR_ALPHA_INACTIVE_PERCENTAGE, scale = 0.66, color = Y_AXIS_POSITIVE_INDICATOR_COLOR, texture = TEXTURE_ARROW_ROTATION_REVERSE, roll = PI, yaw = 0, visible = ShouldShowPitchIndiciator },
        {axis = HOUSING_EDITOR_ROTATION_AXIS_Z1, sizeX = ROTATION_AXIS_INDICATOR_LOCAL_DIMENSIONS_M, sizeY = ROTATION_AXIS_INDICATOR_LOCAL_DIMENSIONS_M, inactiveAlpha = ROTATION_AXIS_INDICATOR_ALPHA_ACTIVE_PERCENTAGE,   scale = 0.44, color = Z_AXIS_NEGATIVE_INDICATOR_COLOR, texture = TEXTURE_ARROW_ROTATION_FORWARD, yaw =  HALF_PI, visible = ShouldShowRollIndiciator },
        {axis = HOUSING_EDITOR_ROTATION_AXIS_Z2, sizeX = ROTATION_AXIS_INDICATOR_LOCAL_DIMENSIONS_M, sizeY = ROTATION_AXIS_INDICATOR_LOCAL_DIMENSIONS_M, inactiveAlpha = AXIS_INDICATOR_ALPHA_INACTIVE_PERCENTAGE, scale = 0.44, color = Z_AXIS_POSITIVE_INDICATOR_COLOR, texture = TEXTURE_ARROW_ROTATION_REVERSE, yaw = -HALF_PI, roll = PI, visible = ShouldShowRollIndiciator },
    }

    local axisIndicators = {}
    for _, indicator in ipairs(self.translationIndicators) do
        table.insert(axisIndicators, indicator)
    end
    for _, indicator in ipairs(self.rotationIndicators) do
        table.insert(axisIndicators, indicator)
    end

    local function OnMouseEnter(...)
        self:OnMouseEnterAxis(...)
    end
    local function OnMouseExit(...)
        self:OnMouseExitAxis(...)
    end
    local function OnMouseDown(...)
        self:OnMouseDownAxis(...)
    end

    self.allAxisIndicators = {}
    for _, indicator in ipairs(axisIndicators) do
        local control = WINDOW_MANAGER:CreateControl(indicatorName .. indicator.axis, window, CT_TEXTURE)
        indicator.control = control
        self.allAxisIndicators[indicator.axis] = indicator
        control.axis = indicator
        control:SetHidden(true)
        control:SetAddressMode(TEX_MODE_CLAMP)
        control:SetAnchor(CENTER, window, CENTER, 0, 0)
        control:SetBlendMode(TEX_BLEND_MODE_ALPHA)
        control:SetColor(indicator.color:UnpackRGBA())
        control:SetTexture(indicator.texture or TEXTURE_ARROW_DIRECTION)
        control:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
        control:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 1)
        self:RotateAndScaleAxisIndicator(indicator.control, indicator.rotation or 0)

        local scale = indicator.scale or 1
        local width = scale * indicator.sizeX
        local height = scale * indicator.sizeY
        local offsetX, offsetY, offsetZ = indicator.offsetX or 0, indicator.offsetY or 0, indicator.offsetZ or 0
        control:Create3DRenderSpace()
        control:Set3DLocalDimensions(width, height)
        control:Set3DRenderSpaceAxisRotationOrder(AXIS_ROTATION_ORDER_ZXY)
        control:Set3DRenderSpaceOrigin(width * offsetX, height * offsetY, width * offsetZ)
        control:Set3DRenderSpaceOrientation(indicator.pitch or 0, indicator.yaw or 0, indicator.roll or 0)
        control:SetMouseEnabled(true)
        control:SetHandler("OnMouseEnter", OnMouseEnter)
        control:SetHandler("OnMouseExit", OnMouseExit)
        control:SetHandler("OnMouseDown", OnMouseDown)
    end

    self.translationAxisIndicators = {}
    for index = 1, 2 do
        local control = WINDOW_MANAGER:CreateControl(translationIndicatorName .. tostring(index), translationWindow, CT_TEXTURE)
        self.translationAxisIndicators[index] = control
        control:SetBlendMode(TEX_BLEND_MODE_ADD)
        control:SetColor(1, 1, 1, 0.2)
        control:Create3DRenderSpace()
        control:Set3DLocalDimensions(1, 1)
        control:Set3DRenderSpaceOrigin(0, 0, 0)
        control:Set3DRenderSpaceOrientation(0, 0, 0)
        control:Set3DRenderSpaceUsesDepthBuffer(true)
    end
end

function ZO_HousingEditorHud:OnMouseEnterAxis(control, ...)
    if not self.focusAxis then
        control:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, AXIS_INDICATOR_RGB_WEIGHT_MAX_PERCENTAGE)
    end
end

function ZO_HousingEditorHud:OnMouseExitAxis(control, ...)
    if not self.focusAxis then
        control:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, AXIS_INDICATOR_RGB_WEIGHT_MIN_PERCENTAGE)
    end
end

function ZO_HousingEditorHud:OnMouseDownAxis(control, mouseButton)
    if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
        local mouseX, mouseY = GetUIMousePosition()
        self:RegisterDragMouseAxis(control.axis, mouseX, mouseY)
    end
end

do
    local function GetVisibleTranslationRange(originX, originY, originZ, horizontalAngleRadians, axisType)
        local offsetY = TRANSLATION_AXIS_RANGE_MAX_CM
        local offsetX, offsetZ

        if axisType == AXIS_TYPE_X or axisType == AXIS_TYPE_Y then
            horizontalAngleRadians = horizontalAngleRadians + HALF_PI
        end
        offsetX = math.sin(horizontalAngleRadians) * TRANSLATION_AXIS_RANGE_MAX_CM
        offsetZ = math.cos(horizontalAngleRadians) * TRANSLATION_AXIS_RANGE_MAX_CM

        local translationRange =
        {
            x1 = originX - offsetX,
            y1 = originY + offsetY,
            z1 = originZ - offsetZ,
            x2 = originX + offsetX,
            y2 = originY + offsetY,
            z2 = originZ + offsetZ,
            x3 = originX - offsetX,
            y3 = originY - offsetY,
            z3 = originZ - offsetZ,
        }
        return translationRange
    end

    function ZO_HousingEditorHud:RegisterDragMouseAxis(axis, mouseX, mouseY)
        if HousingEditorIsSelectingHousingObject() and not self.focusAxis then
            local cameraX, cameraY, cameraZ, originX, originY, originZ = self:GetCameraAndAxisIndicatorOrigins()
            self.focusAngle = math.atan2(cameraX - originX, cameraZ - originZ)
            self.focusAxis = axis
            self.focusOffset = 0
            self.focusOriginX = mouseX
            self.focusOriginY = mouseY
            self.focusInitialX, self.focusInitialY, self.focusInitialZ = HousingEditorGetSelectedObjectWorldPosition()
            self.focusInitialPitch, self.focusInitialYaw, self.focusInitialRoll = HousingEditorGetSelectedObjectOrientation()

            -- Calculate the translation range using the selected item's center point.
            local centerX, centerY, centerZ = HousingEditorGetSelectedObjectWorldCenter(HousingEditorGetSelectedFurnitureId())
            local isTranslation = false

            if axis.axis == HOUSING_EDITOR_POSITION_AXIS_X1 or axis.axis == HOUSING_EDITOR_POSITION_AXIS_X2 then
                self.focusRangeAxis = GetVisibleTranslationRange(centerX, centerY, centerZ, self.focusInitialYaw, AXIS_TYPE_X)
                isTranslation = true
            elseif axis.axis == HOUSING_EDITOR_POSITION_AXIS_Y1 or axis.axis == HOUSING_EDITOR_POSITION_AXIS_Y2 then
                self.focusRangeAxis = GetVisibleTranslationRange(centerX, centerY, centerZ, GetPlayerCameraHeading(), AXIS_TYPE_Y)
                isTranslation = true
            elseif axis.axis == HOUSING_EDITOR_POSITION_AXIS_Z1 or axis.axis == HOUSING_EDITOR_POSITION_AXIS_Z2 then
                self.focusRangeAxis = GetVisibleTranslationRange(centerX, centerY, centerZ, self.focusInitialYaw, AXIS_TYPE_Z)
                isTranslation = true
            end

            if self.focusRangeAxis then
                local range = self.focusRangeAxis
                local targetX, targetY, targetZ = HousingEditorGetScreenPointWorldPlaneIntersection(mouseX, mouseY, range.x1, range.y1, range.z1, range.x2, range.y2, range.z2, range.x3, range.y3, range.z3)
                local offsetX, offsetY, offsetZ = self.focusInitialX - targetX, self.focusInitialY - targetY, self.focusInitialZ - targetZ

                self.focusCenterOffsetX, self.focusCenterOffsetY, self.focusCenterOffsetZ = offsetX, offsetY, offsetZ
            else
                self.focusCenterOffsetX, self.focusCenterOffsetY, self.focusCenterOffsetZ = 0, 0, 0
            end

            if isTranslation then
                if not self.focusRangeAxis then
                    self.focusAxis, self.focusOffset, self.focusOriginX, self.focusOriginY, self.focusAngle = nil, nil, nil, nil, nil
                    self.focusInitialX, self.focusInitialY, self.focusInitialZ = nil, nil, nil
                    self.focusInitialPitch, self.focusInitialYaw, self.focusInitialRoll = nil, nil, nil
                    return
                end
            end

            for _, indicator in pairs(self.allAxisIndicators) do
                local isActiveAxis = indicator.axis == self.focusAxis.axis or indicator.axis == self.focusAxis.pairedAxis

                if isActiveAxis then
                    indicator.control:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, AXIS_INDICATOR_RGB_WEIGHT_MAX_PERCENTAGE)
                end

                indicator.control:SetHidden(not isActiveAxis)
            end

            do
                local window = self.translationAxisIndicatorWindow
                local indicator1 = self.translationAxisIndicators[1]
                local indicator2 = self.translationAxisIndicators[2]
                local activeAxis = self.focusAxis.axis
                local hideAxes = true

                if activeAxis == HOUSING_EDITOR_POSITION_AXIS_X1 or activeAxis == HOUSING_EDITOR_POSITION_AXIS_X2 then
                    indicator1:Set3DRenderSpaceOrientation(0, 0, 0)
                    indicator1:Set3DLocalDimensions(TRANSLATION_AXIS_RANGE_INDICATOR_LOCAL_X_DIMENSION_M, TRANSLATION_AXIS_RANGE_INDICATOR_LOCAL_Y_DIMENSION_M)
                    indicator1:SetColor(0.05, 0, 0.65, TRANSLATION_AXIS_RANGE_INDICATOR_ALPHA)
                    indicator2:Set3DRenderSpaceOrientation(HALF_PI, 0, 0)
                    indicator2:Set3DLocalDimensions(TRANSLATION_AXIS_RANGE_INDICATOR_LOCAL_X_DIMENSION_M, TRANSLATION_AXIS_RANGE_INDICATOR_LOCAL_Y_DIMENSION_M)
                    indicator2:SetColor(0.05, 0, 0.65, TRANSLATION_AXIS_RANGE_INDICATOR_ALPHA)
                    hideAxes = false
                elseif activeAxis == HOUSING_EDITOR_POSITION_AXIS_Y1 or activeAxis == HOUSING_EDITOR_POSITION_AXIS_Y2 then
                    indicator1:Set3DRenderSpaceOrientation(0, 0, 0)
                    indicator1:Set3DLocalDimensions(TRANSLATION_AXIS_RANGE_INDICATOR_LOCAL_Y_DIMENSION_M, TRANSLATION_AXIS_RANGE_INDICATOR_LOCAL_X_DIMENSION_M)
                    indicator1:SetColor(0.65, 0, 0.05, TRANSLATION_AXIS_RANGE_INDICATOR_ALPHA)
                    indicator2:Set3DRenderSpaceOrientation(0, HALF_PI, 0)
                    indicator2:Set3DLocalDimensions(TRANSLATION_AXIS_RANGE_INDICATOR_LOCAL_Y_DIMENSION_M, TRANSLATION_AXIS_RANGE_INDICATOR_LOCAL_X_DIMENSION_M)
                    indicator2:SetColor(0.65, 0, 0.05, TRANSLATION_AXIS_RANGE_INDICATOR_ALPHA)
                    hideAxes = false
                elseif activeAxis == HOUSING_EDITOR_POSITION_AXIS_Z1 or activeAxis == HOUSING_EDITOR_POSITION_AXIS_Z2 then
                    indicator1:Set3DRenderSpaceOrientation(0, HALF_PI, 0)
                    indicator1:Set3DLocalDimensions(TRANSLATION_AXIS_RANGE_INDICATOR_LOCAL_X_DIMENSION_M, TRANSLATION_AXIS_RANGE_INDICATOR_LOCAL_Y_DIMENSION_M)
                    indicator1:SetColor(0, 0.65, 0.05, TRANSLATION_AXIS_RANGE_INDICATOR_ALPHA)
                    indicator2:Set3DRenderSpaceOrientation(0, HALF_PI, HALF_PI)
                    indicator2:Set3DLocalDimensions(TRANSLATION_AXIS_RANGE_INDICATOR_LOCAL_X_DIMENSION_M, TRANSLATION_AXIS_RANGE_INDICATOR_LOCAL_Y_DIMENSION_M)
                    indicator2:SetColor(0, 0.65, 0.05, TRANSLATION_AXIS_RANGE_INDICATOR_ALPHA)
                    hideAxes = false
                end

                if not hideAxes then
                    local renderX, renderY, renderZ = WorldPositionToGuiRender3DPosition(centerX, centerY, centerZ)
                    window:Set3DRenderSpaceOrigin(renderX, renderY, renderZ)
                    window:Set3DRenderSpaceOrientation(0, self.focusInitialYaw, 0)
                end

                window:SetHidden(hideAxes)
            end

            EVENT_MANAGER:RegisterForUpdate("ZO_HousingEditorHud_DragMouseAxis", 1, function() self:OnDragMouseAxis() end)
            EVENT_MANAGER:RegisterForEvent("ZO_HousingEditorHud_OnMouseUp", EVENT_GLOBAL_MOUSE_UP, function() self:UnregisterDragMouseAxis() end)
        end
    end
end

function ZO_HousingEditorHud:UnregisterDragMouseAxis()
    if self.focusAxis then
        EVENT_MANAGER:UnregisterForUpdate("ZO_HousingEditorHud_DragMouseAxis")
        EVENT_MANAGER:UnregisterForEvent("ZO_HousingEditorHud_OnMouseUp", EVENT_GLOBAL_MOUSE_UP)

        for _, indicator in pairs(self.allAxisIndicators) do
            local isActiveAxis = indicator.axis == self.focusAxis.axis or indicator.axis == self.focusAxis.pairedAxis
            if isActiveAxis then
                indicator.control:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, AXIS_INDICATOR_RGB_WEIGHT_MIN_PERCENTAGE)
            end
            indicator.control:SetHidden(false)
        end
        self.translationAxisIndicatorWindow:SetHidden(true)

        self.focusOffset, self.focusAxis, self.focusOriginX, self.focusOriginY = nil, nil, nil, nil
        self.focusInitialX, self.focusInitialY, self.focusInitialZ = nil, nil, nil
        self.focusInitialPitch, self.focusInitialYaw, self.focusInitialRoll = nil, nil, nil
        self.focusRangeAxis = nil
        self:UpdateAxisIndicators()
    end
end

function ZO_HousingEditorHud:OnDragMouseAxis()
    local isSelectingHousingObject = HousingEditorIsSelectingHousingObject()
    local axis = self.focusAxis
    if not isSelectingHousingObject or not axis or not IsGameCameraUIModeActive() then
        self:UnregisterDragMouseAxis()
        return
    end

    local mouseX, mouseY = GetUIMousePosition()
    local axisType = axis.axis
    if axisType >= HOUSING_EDITOR_POSITION_AXIS_X1 and axisType <= HOUSING_EDITOR_POSITION_AXIS_Z2 then
        self:OnDragMousePosition(mouseX, mouseY)
        return
    end

    if axisType >= HOUSING_EDITOR_ROTATION_AXIS_X1 and axisType <= HOUSING_EDITOR_ROTATION_AXIS_Z2 then
        local cameraX, cameraY, cameraZ = self:GetCameraOrigin()
        local screenX, screenY = GuiRoot:GetDimensions()
        local normalizedMouseX, normalizedMouseY = mouseX / screenX, mouseY / screenY
        local normalizedMouseOriginX, normalizedMouseOriginY = self.focusOriginX / screenX, self.focusOriginY / screenY
        local normalizedOffsetX = normalizedMouseX - normalizedMouseOriginX
        local normalizedOffsetY = normalizedMouseY - normalizedMouseOriginY

        self:OnDragMouseRotation(cameraX, cameraY, cameraZ, normalizedOffsetX, normalizedOffsetY)
        return
    end
end

function ZO_HousingEditorHud:OnDragMousePosition(mouseX, mouseY)
    local range = self.focusRangeAxis
    if range then
        local axisType = self.focusAxis.axis
        local x, y, z = HousingEditorGetScreenPointWorldPlaneIntersection(mouseX, mouseY, range.x1, range.y1, range.z1, range.x2, range.y2, range.z2, range.x3, range.y3, range.z3)

        if x ~= 0 and y ~= 0 and z ~= 0 then
            if axisType == HOUSING_EDITOR_POSITION_AXIS_Y1 or axisType == HOUSING_EDITOR_POSITION_AXIS_Y2 then
                x, z = self.focusInitialX, self.focusInitialZ
                y = y + self.focusCenterOffsetY
            else
                y = self.focusInitialY
                x, z = x + self.focusCenterOffsetX, z + self.focusCenterOffsetZ
            end

            if zo_distance3D(self.focusInitialX, self.focusInitialY, self.focusInitialZ, x, y, z) <= TRANSLATION_AXIS_RANGE_MAX_CM then
                local result = HousingEditorAdjustPrecisionEditingPosition(x, y, z)
                ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
            end
        end

        self.axisIndicatorUpdateHandler()
    end
end

function ZO_HousingEditorHud:OnDragMouseRotation(cameraX, cameraY, cameraZ, normalizedOffsetX, normalizedOffsetY)
    local axis = self.focusAxis
    local axisType = axis.axis
    local normalizedOffsetRadians = normalizedOffsetX * 2 * TWO_PI
    local axisIndicatorAngleRadians = normalizedOffsetRadians
    local indicatorX, indicatorY, indicatorZ = self:GetAxisIndicatorOrigin()
    local offsetAxis

    if axisType == HOUSING_EDITOR_ROTATION_AXIS_X1 or axisType == HOUSING_EDITOR_ROTATION_AXIS_X2 then
        offsetAxis = AXIS_TYPE_Y
    elseif axisType == HOUSING_EDITOR_ROTATION_AXIS_Y1 or axisType == HOUSING_EDITOR_ROTATION_AXIS_Y2 then
        offsetAxis = AXIS_TYPE_Z
    elseif axisType == HOUSING_EDITOR_ROTATION_AXIS_Z1 or axisType == HOUSING_EDITOR_ROTATION_AXIS_Z2 then
        offsetAxis = AXIS_TYPE_X
    end

    -- Update the rotation offset and/or axis indicator values to match the focused axis.
    if self:IsPrecisionEditingEnabled() then
        if offsetAxis == AXIS_TYPE_X then
            local relativeX = cameraX - indicatorX
            if relativeX > 0 then
                normalizedOffsetRadians, axisIndicatorAngleRadians = -normalizedOffsetRadians, -axisIndicatorAngleRadians
            end
        elseif offsetAxis == AXIS_TYPE_Y then
            normalizedOffsetRadians = -normalizedOffsetRadians
        elseif offsetAxis == AXIS_TYPE_Z then
            local relativeZ = cameraZ - indicatorZ
            if relativeZ > 0 then
                normalizedOffsetRadians, axisIndicatorAngleRadians = -normalizedOffsetRadians, -axisIndicatorAngleRadians
            end
        end
    else
        if offsetAxis == AXIS_TYPE_X then
            normalizedOffsetRadians, axisIndicatorAngleRadians = -normalizedOffsetRadians, -axisIndicatorAngleRadians
        elseif offsetAxis == AXIS_TYPE_Y then
            normalizedOffsetRadians = -normalizedOffsetRadians
        elseif offsetAxis == AXIS_TYPE_Z then
            normalizedOffsetRadians, axisIndicatorAngleRadians = -normalizedOffsetRadians, -axisIndicatorAngleRadians
        end
    end

    if normalizedOffsetRadians then
        if self:IsPrecisionEditingEnabled() then
            HousingEditorAdjustSelectedObjectRotation(HousingEditorCalculateRotationAboutAxis(offsetAxis, normalizedOffsetRadians, self.focusInitialPitch, self.focusInitialYaw, self.focusInitialRoll))
            self:RotateAndScaleAxisIndicator(axis.control, axisIndicatorAngleRadians)
        else
            local pitch, yaw, roll = 0, 0, 0
            local previousOffset = -(self.focusOffset or 0)

            self.focusOffset = normalizedOffsetRadians
            if offsetAxis == AXIS_TYPE_X then
                pitch = normalizedOffsetRadians + previousOffset
            elseif offsetAxis == AXIS_TYPE_Y then
                yaw = normalizedOffsetRadians + previousOffset
            else
                roll = normalizedOffsetRadians + previousOffset
            end

            HousingEditorAdjustSelectedObjectRotation(pitch, yaw, roll)
            self:RotateAndScaleAxisIndicator(axis.control, axisIndicatorAngleRadians)
        end
    end
end

-- Sets the vertex UV coordinates for an axis indicator by the specified rotation angle (theta).
function ZO_HousingEditorHud:RotateAndScaleAxisIndicator(control, theta)
    local topLeftX, topLeftY = ZO_Rotate2D(theta, -0.5, -0.5)
    local topRightX, topRightY = ZO_Rotate2D(theta,  0.5, -0.5)
    local bottomLeftX, bottomLeftY = ZO_Rotate2D(theta, -0.5,  0.5)
    local bottomRightX, bottomRightY = ZO_Rotate2D(theta,  0.5,  0.5)

    control:SetVertexUV(VERTEX_POINTS_TOPLEFT, 0.5 + topLeftX, 0.5 + topLeftY)
    control:SetVertexUV(VERTEX_POINTS_TOPRIGHT, 0.5 + topRightX, 0.5 + topRightY)
    control:SetVertexUV(VERTEX_POINTS_BOTTOMLEFT, 0.5 + bottomLeftX, 0.5 + bottomLeftY)
    control:SetVertexUV(VERTEX_POINTS_BOTTOMRIGHT, 0.5 + bottomRightX, 0.5 + bottomRightY)
end

function ZO_HousingEditorHud:GetCameraOrigin()
    Set3DRenderSpaceToCurrentCamera(self.cameraControlName)
    return GuiRender3DPositionToWorldPosition(self.cameraControl:Get3DRenderSpaceOrigin())
end

function ZO_HousingEditorHud:GetAxisIndicatorOrigin()
    return GuiRender3DPositionToWorldPosition(self.axisIndicatorWindow:Get3DRenderSpaceOrigin())
end

function ZO_HousingEditorHud:GetAxisIndicatorOrientation()
    return self.axisIndicatorWindow:Get3DRenderSpaceOrientation()
end

function ZO_HousingEditorHud:GetCameraAndAxisIndicatorOrigins()
    local cameraX, cameraY, cameraZ = self:GetCameraOrigin()
    local originX, originY, originZ = self:GetAxisIndicatorOrigin()
    return cameraX, cameraY, cameraZ, originX, originY, originZ
end

function ZO_HousingEditorHud:GetCameraForwardVector()
    Set3DRenderSpaceToCurrentCamera(self.cameraControlName)
    local forwardX, forwardY, forwardZ = self.cameraControl:Get3DRenderSpaceForward()
    return forwardX, forwardY, forwardZ
end

function ZO_HousingEditorHud:GetAxisIndicatorOffsetPosition(axis)
    local control = axis.control
    local originX, originY, originZ = control:GetParent():Get3DRenderSpaceOrigin()
    local offsetX, offsetY, offsetZ = control:Get3DRenderSpaceOrigin()
    return GuiRender3DPositionToWorldPosition(originX + offsetX, originY + offsetY, originZ + offsetZ)
end

function ZO_HousingEditorHud:CalculateDynamicAxisIndicatorScale(cameraX, cameraY, cameraZ, worldX, worldY, worldZ)
    local screenX, screenY = GuiRoot:GetDimensions()
    local distance = zo_distance3D(cameraX, cameraY, cameraZ, worldX, worldY, worldZ)
    local worldWidth, worldHeight = GetWorldDimensionsOfViewFrustumAtDepth(distance)
    local frustumScaleX, frustumScaleY = worldWidth / screenX, worldHeight / screenY
    local scaleX, scaleY = 1, 1

    if frustumScaleX < AXIS_INDICATOR_SCALE_MIN then
        scaleX = frustumScaleX / AXIS_INDICATOR_SCALE_MIN
    elseif frustumScaleX > AXIS_INDICATOR_SCALE_MAX then
        scaleX = frustumScaleX / AXIS_INDICATOR_SCALE_MAX
    end

    if frustumScaleY < AXIS_INDICATOR_SCALE_MIN then
        scaleY = frustumScaleY / AXIS_INDICATOR_SCALE_MIN
    elseif frustumScaleY > AXIS_INDICATOR_SCALE_MAX then
        scaleY = frustumScaleY / AXIS_INDICATOR_SCALE_MAX
    end

    return scaleX, scaleY
end

function ZO_HousingEditorHud:MoveAxisIndicators(worldX, worldY, worldZ, pitch, yaw, roll)
    local cameraX, cameraY, cameraZ = self:GetCameraOrigin()
    local renderX, renderY, renderZ, renderPitch, renderYaw, renderRoll, scaleX, scaleY
    local isPrecisionEditing = self:IsPrecisionEditingEnabled()

    if isPrecisionEditing then
        renderX, renderY, renderZ = WorldPositionToGuiRender3DPosition(worldX, worldY, worldZ)
        if self:IsPrecisionPlacementRotationMode() then
            renderPitch, renderYaw, renderRoll = pitch, yaw, roll
        else
            renderPitch, renderYaw, renderRoll = 0, yaw, 0
        end
        scaleX, scaleY = self:CalculateDynamicAxisIndicatorScale(cameraX, cameraY, cameraZ, worldX, worldY, worldZ)
    else
        local distance = PICKUP_AXIS_INDICATOR_DISTANCE_CM
        local forwardX, forwardY, forwardZ = self:GetCameraForwardVector()
        local reticleX, reticleY, reticleZ = cameraX + forwardX * distance, cameraY + forwardY * distance, cameraZ + forwardZ * distance

        renderX, renderY, renderZ = WorldPositionToGuiRender3DPosition(reticleX, reticleY, reticleZ)
        renderYaw = GetPlayerCameraHeading() - AXIS_INDICATOR_PICKUP_YAW_OFFSET_ANGLE
        renderPitch, renderRoll = 0, 0
        scaleX, scaleY = 1, 1
    end

    local axisIndicators
    if isPrecisionEditing and self:IsPrecisionPlacementMoveMode() then
        axisIndicators = self.translationIndicators
    else
        axisIndicators = self.rotationIndicators
    end

    for index, axis in ipairs(axisIndicators) do
        local scaledX, scaledY = axis.sizeX * (axis.scale or 1) * scaleX, axis.sizeY * (axis.scale or 1) * scaleY
        axis.control:Set3DLocalDimensions(scaledX, scaledY)
        axis.control:Set3DRenderSpaceOrigin(scaledX * (axis.offsetX or 0), scaledY * (axis.offsetY or 0), scaledX * (axis.offsetZ or 0))
    end

    self.axisIndicatorWindow:Set3DRenderSpaceOrigin(renderX, renderY, renderZ)
    self.axisIndicatorWindow:Set3DRenderSpaceOrientation(renderPitch, renderYaw, renderRoll)
end

function ZO_HousingEditorHud:UpdateAxisIndicators()
    if self.translationIndicators and self.rotationIndicators then
        local isPlacementMode = IsInHousingEditorPlacementMode()
        local isPrecisionMode = self:IsPrecisionEditingEnabled()

        if not isPlacementMode then
            EVENT_MANAGER:UnregisterForUpdate("HousingEditor_AxisIndicators")
            self.axisIndicatorWindow:SetHidden(true)
        else
            local hideTranslation = self:IsPrecisionPlacementRotationMode() or not isPrecisionMode
            local hideRotation = not hideTranslation

            if not hideTranslation then
                local cameraX, cameraY, cameraZ, originX, originY, originZ = self:GetCameraAndAxisIndicatorOrigins()
                local relativeX, relativeY, relativeZ = cameraX - originX, cameraY - originY, cameraZ - originZ
                local horizontalAngle = math.atan2(relativeX, relativeZ)
                local relativeXZ = math.sqrt(relativeX * relativeX + relativeZ * relativeZ)
                local verticalAngle = math.atan2(relativeY, relativeXZ)
                local _, indicatorYaw, _ = self:GetAxisIndicatorOrientation()
                local verticalIndicatorYaw = horizontalAngle - indicatorYaw

                -- Pitch the X- and Z-axis indicators to lay flat when significantly above or below the player.
                local pitch = zo_clamp(2 * verticalAngle, -HALF_PI, HALF_PI)
                pitch = math.abs(pitch) < QUARTER_PI and 0 or HALF_PI

                self.translationIndicators[1].control:Set3DRenderSpaceOrientation(pitch, self.translationIndicators[1].yaw, 0)
                self.translationIndicators[2].control:Set3DRenderSpaceOrientation(-pitch, self.translationIndicators[2].yaw, 0)
                self.translationIndicators[3].control:Set3DRenderSpaceOrientation(0, verticalIndicatorYaw, 0)
                self.translationIndicators[4].control:Set3DRenderSpaceOrientation(0, verticalIndicatorYaw, 0)
                self.translationIndicators[5].control:Set3DRenderSpaceOrientation(pitch, self.translationIndicators[5].yaw, 0)
                self.translationIndicators[6].control:Set3DRenderSpaceOrientation(-pitch, self.translationIndicators[6].yaw, 0)
            end

            local cameraX, cameraY, cameraZ = self:GetCameraOrigin()
            local forwardX, forwardY, forwardZ = self:GetCameraForwardVector()

            for _, indicator in ipairs(self.translationIndicators) do
                local alpha = indicator.control:GetAlpha()
                local hideIndicator = hideTranslation or alpha <= 0
                indicator.control:SetHidden(hideIndicator)

                if not hideIndicator then
                    local indicatorX, indicatorY, indicatorZ = self:GetAxisIndicatorOffsetPosition(indicator)
                    -- We cannot use distance squared reliably here as the result could exceed the maximum draw level for a control.
                    local horizontalDistance = math.sqrt((cameraX - indicatorX) * (cameraX - indicatorX) + (cameraZ - indicatorZ) * (cameraZ - indicatorZ))
                    local verticalCoefficient = forwardY > 0 and 1 or -1
                    local drawLevel = horizontalDistance + verticalCoefficient * (cameraY - indicatorY)
                    indicator.control:SetDrawLevel(drawLevel)
                end
            end

            for _, indicator in ipairs(self.rotationIndicators) do
                local alpha = indicator.control:GetAlpha()
                local shouldBeVisible = true
                if indicator.visible then
                    shouldBeVisible = indicator.visible()
                end
                indicator.control:SetHidden(hideRotation or alpha <= 0 or not shouldBeVisible)
            end

            EVENT_MANAGER:RegisterForUpdate("HousingEditor_AxisIndicators", 1, self.axisIndicatorUpdateHandler)
        end
    end
end

function ZO_HousingEditorHud:InitializeHudControls()
    local function IsEnabledPitch(mode)
        return mode ~= HOUSING_EDITOR_MODE_NODE_PLACEMENT
    end

    local function IsEnabledRoll(mode)
        return mode ~= HOUSING_EDITOR_MODE_NODE_PLACEMENT
    end

    do
        local yawLeftButton = self.buttonContainer:GetNamedChild("YawLeftButton")
        yawLeftButton.icon = yawLeftButton:GetNamedChild("Icon")
        yawLeftButton.icon:SetTexture("EsoUI/Art/Housing/housing_axisControlIcon_yawCW.dds")
        ZO_Keybindings_RegisterLabelForBindingUpdate(yawLeftButton:GetNamedChild("Text"), "HOUSING_EDITOR_YAW_LEFT")

        local yawRightButton = self.buttonContainer:GetNamedChild("YawRightButton")
        yawRightButton.icon = yawRightButton:GetNamedChild("Icon")
        yawRightButton.icon:SetTexture("EsoUI/Art/Housing/housing_axisControlIcon_yawCCW.dds")
        ZO_Keybindings_RegisterLabelForBindingUpdate(yawRightButton:GetNamedChild("Text"), "HOUSING_EDITOR_YAW_RIGHT")

        local pitchForwardButton = self.buttonContainer:GetNamedChild("PitchForwardButton")
        pitchForwardButton.enabledFunction = IsEnabledPitch
        pitchForwardButton.icon = pitchForwardButton:GetNamedChild("Icon")
        pitchForwardButton.icon:SetTexture("EsoUI/Art/Housing/housing_axisControlIcon_pitchCCW.dds")
        ZO_Keybindings_RegisterLabelForBindingUpdate(pitchForwardButton:GetNamedChild("Text"), "HOUSING_EDITOR_PITCH_FORWARD")

        local pitchBackButton = self.buttonContainer:GetNamedChild("PitchBackButton")
        pitchBackButton.enabledFunction = IsEnabledPitch
        pitchBackButton.icon = pitchBackButton:GetNamedChild("Icon")
        pitchBackButton.icon:SetTexture("EsoUI/Art/Housing/housing_axisControlIcon_pitchCW.dds")
        ZO_Keybindings_RegisterLabelForBindingUpdate(pitchBackButton:GetNamedChild("Text"), "HOUSING_EDITOR_PITCH_BACKWARD")

        local rollLeftButton = self.buttonContainer:GetNamedChild("RollLeftButton")
        rollLeftButton.enabledFunction = IsEnabledRoll
        rollLeftButton.icon = rollLeftButton:GetNamedChild("Icon")
        rollLeftButton.icon:SetTexture("EsoUI/Art/Housing/housing_axisControlIcon_rollCCW.dds")
        ZO_Keybindings_RegisterLabelForBindingUpdate(rollLeftButton:GetNamedChild("Text"), "HOUSING_EDITOR_ROLL_LEFT")

        local rollRightButton = self.buttonContainer:GetNamedChild("RollRightButton")
        rollRightButton.enabledFunction = IsEnabledRoll
        rollRightButton.icon = rollRightButton:GetNamedChild("Icon")
        rollRightButton.icon:SetTexture("EsoUI/Art/Housing/housing_axisControlIcon_rollCW.dds")
        ZO_Keybindings_RegisterLabelForBindingUpdate(rollRightButton:GetNamedChild("Text"), "HOUSING_EDITOR_ROLL_RIGHT")
    
        self.pickupRotateHudButtons =
        {
            yawLeftButton,
            yawRightButton,
            pitchForwardButton,
            pitchBackButton,
            rollLeftButton,
            rollRightButton,
        }

        for _, button in ipairs(self.pickupRotateHudButtons) do
            button.precisionMode = false
        end
    end

    do
        local moveLeftButton = self.precisionMoveButtons:GetNamedChild("PrecisionMoveLeftButton")
        moveLeftButton.icon = moveLeftButton:GetNamedChild("Icon")
        ZO_Keybindings_RegisterLabelForBindingUpdate(moveLeftButton:GetNamedChild("Text"), "HOUSING_EDITOR_YAW_LEFT")

        local moveRightButton = self.precisionMoveButtons:GetNamedChild("PrecisionMoveRightButton")
        moveRightButton.icon = moveRightButton:GetNamedChild("Icon")
        ZO_Keybindings_RegisterLabelForBindingUpdate(moveRightButton:GetNamedChild("Text"), "HOUSING_EDITOR_YAW_RIGHT")

        local moveForwardButton = self.precisionMoveButtons:GetNamedChild("PrecisionMoveForwardButton")
        moveForwardButton.icon = moveForwardButton:GetNamedChild("Icon")
        ZO_Keybindings_RegisterLabelForBindingUpdate(moveForwardButton:GetNamedChild("Text"), "HOUSING_EDITOR_PITCH_FORWARD")

        local moveBackButton = self.precisionMoveButtons:GetNamedChild("PrecisionMoveBackButton")
        moveBackButton.icon = moveBackButton:GetNamedChild("Icon")
        ZO_Keybindings_RegisterLabelForBindingUpdate(moveBackButton:GetNamedChild("Text"), "HOUSING_EDITOR_PITCH_BACKWARD")

        local moveUpButton = self.precisionMoveButtons:GetNamedChild("PrecisionMoveUpButton")
        moveUpButton.icon = moveUpButton:GetNamedChild("Icon")
        ZO_Keybindings_RegisterLabelForBindingUpdate(moveUpButton:GetNamedChild("Text"), "HOUSING_EDITOR_ROLL_RIGHT")

        local moveDownButton = self.precisionMoveButtons:GetNamedChild("PrecisionMoveDownButton")
        moveDownButton.icon = moveDownButton:GetNamedChild("Icon")
        ZO_Keybindings_RegisterLabelForBindingUpdate(moveDownButton:GetNamedChild("Text"), "HOUSING_EDITOR_ROLL_LEFT")

        self.precisionMoveHudButtons =
        {
            moveLeftButton,
            moveRightButton,
            moveForwardButton,
            moveBackButton,
            moveDownButton,
            moveUpButton,
        }

        for _, button in ipairs(self.precisionMoveHudButtons) do
            button.precisionMode = true
        end
    end

    do
        local rotateYawLeftButton = self.precisionRotateButtons:GetNamedChild("PrecisionYawLeftButton")
        rotateYawLeftButton.icon = rotateYawLeftButton:GetNamedChild("Icon")
        rotateYawLeftButton.icon:SetTexture("EsoUI/Art/Housing/housing_axisControlIcon_yawCW.dds")
        ZO_Keybindings_RegisterLabelForBindingUpdate(rotateYawLeftButton:GetNamedChild("Text"), "HOUSING_EDITOR_YAW_LEFT")

        local rotateYawRightButton = self.precisionRotateButtons:GetNamedChild("PrecisionYawRightButton")
        rotateYawRightButton.icon = rotateYawRightButton:GetNamedChild("Icon")
        rotateYawRightButton.icon:SetTexture("EsoUI/Art/Housing/housing_axisControlIcon_yawCCW.dds")
        ZO_Keybindings_RegisterLabelForBindingUpdate(rotateYawRightButton:GetNamedChild("Text"), "HOUSING_EDITOR_YAW_RIGHT")

        local rotatePitchForwardButton = self.precisionRotateButtons:GetNamedChild("PrecisionPitchForwardButton")
        rotatePitchForwardButton.enabledFunction = IsEnabledPitch
        rotatePitchForwardButton.icon = rotatePitchForwardButton:GetNamedChild("Icon")
        rotatePitchForwardButton.icon:SetTexture("EsoUI/Art/Housing/housing_axisControlIcon_pitchCCW.dds")
        ZO_Keybindings_RegisterLabelForBindingUpdate(rotatePitchForwardButton:GetNamedChild("Text"), "HOUSING_EDITOR_PITCH_FORWARD")

        local rotatePitchBackButton = self.precisionRotateButtons:GetNamedChild("PrecisionPitchBackButton")
        rotatePitchBackButton.enabledFunction = IsEnabledPitch
        rotatePitchBackButton.icon = rotatePitchBackButton:GetNamedChild("Icon")
        rotatePitchBackButton.icon:SetTexture("EsoUI/Art/Housing/housing_axisControlIcon_pitchCW.dds")
        ZO_Keybindings_RegisterLabelForBindingUpdate(rotatePitchBackButton:GetNamedChild("Text"), "HOUSING_EDITOR_PITCH_BACKWARD")

        local rotateRollLeftButton = self.precisionRotateButtons:GetNamedChild("PrecisionRollLeftButton")
        rotateRollLeftButton.enabledFunction = IsEnabledRoll
        rotateRollLeftButton.icon = rotateRollLeftButton:GetNamedChild("Icon")
        rotateRollLeftButton.icon:SetTexture("EsoUI/Art/Housing/housing_axisControlIcon_rollCCW.dds")
        ZO_Keybindings_RegisterLabelForBindingUpdate(rotateRollLeftButton:GetNamedChild("Text"), "HOUSING_EDITOR_ROLL_LEFT")

        local rotateRollRightButton = self.precisionRotateButtons:GetNamedChild("PrecisionRollRightButton")
        rotateRollRightButton.enabledFunction = IsEnabledRoll
        rotateRollRightButton.icon = rotateRollRightButton:GetNamedChild("Icon")
        rotateRollRightButton.icon:SetTexture("EsoUI/Art/Housing/housing_axisControlIcon_rollCW.dds")
        ZO_Keybindings_RegisterLabelForBindingUpdate(rotateRollRightButton:GetNamedChild("Text"), "HOUSING_EDITOR_ROLL_RIGHT")

        self.precisionRotateHudButtons =
        {
            rotateYawLeftButton,
            rotateYawRightButton,
            rotatePitchForwardButton,
            rotatePitchBackButton,
            rotateRollLeftButton,
            rotateRollRightButton,
        }

        for _, button in ipairs(self.precisionRotateHudButtons) do
            button.precisionMode = true
        end
    end

    local KEYBOARD_CONSTANTS =
    {
        frame = "EsoUI/Art/ActionBar/abilityFrame64_up.dds",
        dimensions = 50,
        font = "ZoFontGameSmall",
        labelOffsetY = 1,
        buttonOffsetX = 2,
        containerOffsetY = -110,
    }

    local GAMEPAD_CONSTANTS =
    {
        frame = "EsoUI/Art/ActionBar/Gamepad/gp_abilityFrame64.dds",
        dimensions = 64,
        font = "ZoFontGamepad18",
        labelOffsetY = -6,
        buttonOffsetX = 10,
        containerOffsetY = -160,
    }

    local function ApplyStyle(style)
        local allHudButtons = {self.pickupRotateHudButtons, self.precisionMoveHudButtons, self.precisionRotateHudButtons}
        for _, buttons in ipairs(allHudButtons) do
            local lastButton = nil
            for _, button in ipairs(buttons) do
                button:SetDimensions(style.dimensions, style.dimensions)
                button:GetNamedChild("Frame"):SetTexture(style.frame)
                button:GetNamedChild("Text"):SetFont(style.font)

                local isValid, point, relativeTo, relativePoint, offsetX, offsetY, constraints = button:GetNamedChild("Text"):GetAnchor(0)
                if isValid then
                    button:GetNamedChild("Text"):SetAnchor(point, relativeTo, relativePoint, offsetX, style.labelOffsetY, constraints)
                end

                if lastButton then
                    button:SetAnchor(LEFT, lastButton, RIGHT, style.buttonOffsetX, 0)
                end
                lastButton = button
            end
        end

        self.buttonContainer:SetAnchor(BOTTOM, nil, BOTTOM, 0, style.containerOffsetY)
        self.precisionMoveButtonContainer:SetAnchor(BOTTOM, nil, BOTTOM, 0, style.containerOffsetY)
        self.precisionRotateButtonContainer:SetAnchor(BOTTOM, nil, BOTTOM, 0, style.containerOffsetY)
    end

    ZO_PlatformStyle:New(ApplyStyle, KEYBOARD_CONSTANTS, GAMEPAD_CONSTANTS) 
end

do
    local ROTATE_YAW_RIGHT = 1
    local ROTATE_YAW_LEFT = 2
    local ROTATE_PITCH_FORWARD = 3
    local ROTATE_PITCH_BACKWARD = 4
    local ROTATE_ROLL_LEFT = 5
    local ROTATE_ROLL_RIGHT = 6
    local PUSH_FORWARD = 7
    local PULL_BACKWARD = 8

    local PRECISION_MOVE_LEFT = 9
    local PRECISION_MOVE_RIGHT = 10
    local PRECISION_MOVE_FORWARD = 11
    local PRECISION_MOVE_BACKWARD = 12
    local PRECISION_MOVE_UP = 13
    local PRECISION_MOVE_DOWN = 14

    local PRECISION_ROTATE_YAW_RIGHT = 15
    local PRECISION_ROTATE_YAW_LEFT = 16
    local PRECISION_ROTATE_PITCH_FORWARD = 17
    local PRECISION_ROTATE_PITCH_BACKWARD = 18
    local PRECISION_ROTATE_ROLL_LEFT = 19
    local PRECISION_ROTATE_ROLL_RIGHT = 20

    local KEYPRESS_MIN = 1
    local KEYPRESS_MAX = 20

    function ZO_HousingEditorHud:GetAdjacentPrecisionUnits(unitList, currentUnit, direction)
        local index = (ZO_IndexOfElementInNumericallyIndexedTable(unitList, currentUnit) or 1) - 1
        return unitList[((index + direction) % #unitList) + 1]
    end

    function ZO_HousingEditorHud:AdjustPrecisionUnits(unitType, adjustmentType)
        local direction

        if adjustmentType == PRECISION_UNIT_ADJUSTMENT_INCREMENT then
            direction = 1
        elseif adjustmentType == PRECISION_UNIT_ADJUSTMENT_DECREMENT then
            direction = -1
        end

        if unitType == HOUSING_EDITOR_PRECISION_PLACEMENT_MODE_MOVE then
            local unitList = PRECISION_MOVE_UNITS_CM
            local currentUnits = HousingEditorGetPrecisionMoveUnits()
            local newUnits = self:GetAdjacentPrecisionUnits(unitList, currentUnits, direction)
            HousingEditorSetPrecisionMoveUnits(newUnits)
            self.savedOptions.moveUnitsCentimeters = newUnits
        elseif unitType == HOUSING_EDITOR_PRECISION_PLACEMENT_MODE_ROTATE then
            local unitList = PRECISION_ROTATE_UNITS_DEG
            local currentUnits = zo_roundToNearest(math.deg(HousingEditorGetPrecisionRotateUnits()), 0.001)
            local newUnits = math.rad(self:GetAdjacentPrecisionUnits(unitList, currentUnits, direction))
            HousingEditorSetPrecisionRotateUnits(newUnits)
            self.savedOptions.rotateUnitsRadians = newUnits
        end
    end

    function ZO_HousingEditorHud:GetButtonDirection(axis)
        local precisionEditing = self:IsPrecisionEditingEnabled()
        local precisionEditingRotateMode = self:IsPrecisionPlacementRotationMode()

        -- Translate the specified axis' keypress states into the corresponding translational or rotational coefficient.
        if axis == AXIS_TYPE_Y then
            if precisionEditing then
                if precisionEditingRotateMode then
                    return (self.placementKeyPresses[PRECISION_ROTATE_YAW_LEFT] and 1 or 0) + (self.placementKeyPresses[PRECISION_ROTATE_YAW_RIGHT] and -1 or 0)
                else
                    return (self.placementKeyPresses[PRECISION_MOVE_UP] and 1 or 0) + (self.placementKeyPresses[PRECISION_MOVE_DOWN] and -1 or 0)
                end
            else
                return (self.placementKeyPresses[ROTATE_YAW_LEFT] and 1 or 0) + (self.placementKeyPresses[ROTATE_YAW_RIGHT] and -1 or 0)
            end
        elseif axis == AXIS_TYPE_X then
            if precisionEditing then
                if precisionEditingRotateMode then
                    return (self.placementKeyPresses[PRECISION_ROTATE_PITCH_BACKWARD] and 1 or 0) + (self.placementKeyPresses[PRECISION_ROTATE_PITCH_FORWARD] and -1 or 0)
                else
                    return (self.placementKeyPresses[PRECISION_MOVE_BACKWARD] and -1 or 0) + (self.placementKeyPresses[PRECISION_MOVE_FORWARD] and 1 or 0)
                end
            else
                return (self.placementKeyPresses[ROTATE_PITCH_BACKWARD] and 1 or 0) + (self.placementKeyPresses[ROTATE_PITCH_FORWARD] and -1 or 0)
            end
        elseif axis == AXIS_TYPE_Z then
            if precisionEditing then
                if precisionEditingRotateMode then
                    return (self.placementKeyPresses[PRECISION_ROTATE_ROLL_RIGHT] and 1 or 0) + (self.placementKeyPresses[PRECISION_ROTATE_ROLL_LEFT] and -1 or 0)
                else
                    return (self.placementKeyPresses[PRECISION_MOVE_LEFT] and 1 or 0) + (self.placementKeyPresses[PRECISION_MOVE_RIGHT] and -1 or 0)
                end
            else
                return (self.placementKeyPresses[ROTATE_ROLL_RIGHT] and 1 or 0) + (self.placementKeyPresses[ROTATE_ROLL_LEFT] and -1 or 0)
            end
        end
    end

    function ZO_HousingEditorHud:RefreshPlacementKeyPresses()
        local frameTimeMS = GetFrameTimeMilliseconds()
        local furnitureId = HousingEditorGetSelectedFurnitureId()

        if furnitureId and self:IsPrecisionEditingEnabled() then
            local x, y, z = HousingEditorGetSelectedObjectWorldCenter()
            local pitch, yaw, roll = HousingEditorGetSelectedObjectOrientation()

            local nextPrecisionPositionOrOrientationUpdateMS = self.nextPrecisionPositionOrOrientationUpdateMS or 0
            if frameTimeMS > nextPrecisionPositionOrOrientationUpdateMS then
                self.nextPrecisionPositionOrOrientationUpdateMS = frameTimeMS + PRECISION_POSITION_OR_ORIENTATION_UPDATE_INTERVAL_MS

                if self:IsPrecisionPlacementMoveMode() then
                    local xText = ZO_FastFormatDecimalNumber(ZO_CommaDelimitNumber(x))
                    local yText = ZO_FastFormatDecimalNumber(ZO_CommaDelimitNumber(y))
                    local zText = ZO_FastFormatDecimalNumber(ZO_CommaDelimitNumber(z))
                    local positionText = string.format(GetString(SI_HOUSING_EDITOR_CURRENT_FURNITURE_POSITION), xText, yText, zText)
                    self.precisionPositionLabel:SetText(positionText)
                elseif self:IsPrecisionPlacementRotationMode() then
                    pitch = math.deg(pitch or 0) % 360
                    yaw = math.deg(yaw or 0) % 360
                    roll = math.deg(roll or 0) % 360
                    if pitch > 359.94 then pitch = 0 end
                    if yaw > 359.94 then yaw = 0 end
                    if roll > 359.94 then roll = 0 end
                    
                    local pitchText = ZO_FastFormatDecimalNumber(string.format("%.1f", pitch))
                    local yawText = ZO_FastFormatDecimalNumber(string.format("%.1f", yaw))
                    local rollText = ZO_FastFormatDecimalNumber(string.format("%.1f", roll))
                    local orientationText = string.format(GetString(SI_HOUSING_EDITOR_CURRENT_FURNITURE_ORIENTATION), yawText, pitchText, rollText)
                    self.precisionOrientationLabel:SetText(orientationText)
                end

                self.precisionPositionLabel:SetHidden(false)
                self.precisionOrientationLabel:SetHidden(false)
            end
        else
            self.precisionPositionLabel:SetHidden(true)
            self.precisionOrientationLabel:SetHidden(true)
        end

        local activeIntervalMS = 0

        for keypress = KEYPRESS_MIN, KEYPRESS_MAX do
            local key = self.placementKeys[keypress]
            if key then
                if self.placementKeyPresses[keypress] then
                    if not key.keypressStartMS then
                        key.keypressStartMS = frameTimeMS
                    end
                    key.keypressDurationMS = frameTimeMS - key.keypressStartMS
                    key.keypressIntervalMS = ZO_EaseOutQuadratic(math.min(1, key.keypressDurationMS / PRESS_AND_HOLD_ACCELERATION_INTERVAL_MS))
                    activeIntervalMS = math.max(activeIntervalMS, key.keypressIntervalMS)
                elseif key.keypressStartMS then
                    key.keypressStartMS = nil
                    key.keypressDurationMS = nil
                    key.keypressIntervalMS = nil
                end
            end
        end

        local isPrecisionMode = self:IsPrecisionEditingEnabled()
        local rotationInterval = PICKUP_ROTATE_INTERVALS_MS
        if isPrecisionMode then
            local rotationUnits = zo_roundToNearest(math.deg(HousingEditorGetPrecisionRotateUnits()), 0.001)
            rotationInterval = PRECISION_ROTATE_INTERVALS_MS[rotationUnits] or 10000
        end

        for keypress = KEYPRESS_MIN, KEYPRESS_MAX do
            local key = self.placementKeys[keypress]
            if key then
                if key.keypressStartMS then
                    local duration = key.keypressDurationMS
                    local interval = key.keypressIntervalMS
                    local weight = zo_lerp(AXIS_KEYBIND_RGB_WEIGHT_MIN_PERCENTAGE, AXIS_KEYBIND_RGB_WEIGHT_MAX_PERCENTAGE, interval)

                    key.icon:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 1 + weight)

                    if key.axis and key.precisionMode == isPrecisionMode then
                        local axis = key.axis
                        local axisType = axis.axis
                        local control = axis.control
                        local rotationOffset = (duration / rotationInterval) * TWO_PI
                        local rotation = axis.rotation or 0
                        local alpha = zo_lerp(key.axis.inactiveAlpha, AXIS_INDICATOR_ALPHA_MAX_PERCENTAGE, interval)

                        weight = zo_lerp(AXIS_INDICATOR_RGB_WEIGHT_MIN_PERCENTAGE, AXIS_INDICATOR_RGB_WEIGHT_MAX_PERCENTAGE, interval)
                        control:SetAlpha(alpha)
                        control:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, weight)

                        if axisType == HOUSING_EDITOR_ROTATION_AXIS_X1 then
                            rotation = rotation + rotationOffset
                        elseif axisType == HOUSING_EDITOR_ROTATION_AXIS_X2 then
                            rotation = rotation - rotationOffset
                        elseif axisType == HOUSING_EDITOR_ROTATION_AXIS_Y1 then
                            rotation = rotation + rotationOffset
                        elseif axisType == HOUSING_EDITOR_ROTATION_AXIS_Y2 then
                            rotation = rotation - rotationOffset
                        elseif axisType == HOUSING_EDITOR_ROTATION_AXIS_Z1 then
                            rotation = rotation + rotationOffset
                        elseif axisType == HOUSING_EDITOR_ROTATION_AXIS_Z2 then
                            rotation = rotation - rotationOffset
                        end

                        self:RotateAndScaleAxisIndicator(control, rotation)
                    end
                else
                    key.icon:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 1)

                    if key.axis and key.precisionMode == isPrecisionMode then
                        local control = key.axis.control
                        local alpha = activeIntervalMS > 0 and 0 or key.axis.inactiveAlpha
                        control:SetAlpha(alpha)
                        control:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, AXIS_INDICATOR_RGB_WEIGHT_MIN_PERCENTAGE)
                    end
                end
            end
        end
    end

    function ZO_HousingEditorHud:ClearPlacementKeyPresses()
        if not self.placementKeyPresses then
            return
        end

        for i = KEYPRESS_MIN, KEYPRESS_MAX do
            self.placementKeyPresses[i] = false

            local key = self.placementKeys[i]
            if key and key.keypressStartMS then
                key.keypressStartMS = nil
                key.icon:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 1)
            end
        end
    end

    function ZO_HousingEditorHud:InitializeKeybindDescriptors()
        local function PlacementCallback(direction, isUp)
            self.placementKeyPresses[direction] = not isUp and IsInHousingEditorPlacementMode()
        end

        local function RefreshUnits()
            self:UpdateMovementControllerUnits()
            self:UpdateKeybinds()
        end
        
        -- Exit
        self.exitKeybindButtonStripDescriptor =
        {
            alignment = KEYBIND_STRIP_ALIGN_RIGHT,

            {
                name = GetString(SI_EXIT_BUTTON),
                keybind = "DISABLE_HOUSING_EDITOR",
                visible = function()
                        return GetHousingEditorMode() == HOUSING_EDITOR_MODE_SELECTION
                    end,
                callback = function()
                        HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_DISABLED)
                    end,
                alignment = KEYBIND_STRIP_ALIGN_RIGHT,
            },
        }
        
        self.placementKeyPresses =
        {
            [ROTATE_YAW_RIGHT] = false,
            [ROTATE_YAW_LEFT] = false,
            [ROTATE_PITCH_FORWARD] = false,
            [ROTATE_PITCH_BACKWARD] = false,
            [ROTATE_ROLL_RIGHT] = false,
            [ROTATE_ROLL_LEFT] = false,

            [PUSH_FORWARD] = false,
            [PULL_BACKWARD] = false,

            [PRECISION_MOVE_RIGHT] = false,
            [PRECISION_MOVE_LEFT] = false,
            [PRECISION_MOVE_FORWARD] = false,
            [PRECISION_MOVE_BACKWARD] = false,
            [PRECISION_MOVE_UP] = false,
            [PRECISION_MOVE_DOWN] = false,

            [PRECISION_ROTATE_YAW_RIGHT] = false,
            [PRECISION_ROTATE_YAW_LEFT] = false,
            [PRECISION_ROTATE_PITCH_FORWARD] = false,
            [PRECISION_ROTATE_PITCH_BACKWARD] = false,
            [PRECISION_ROTATE_ROLL_RIGHT] = false,
            [PRECISION_ROTATE_ROLL_LEFT] = false,
        }

        self.placementKeys =
        {
            [ROTATE_YAW_RIGHT] = self.pickupRotateHudButtons[2],
            [ROTATE_YAW_LEFT] = self.pickupRotateHudButtons[1],
            [ROTATE_PITCH_FORWARD] = self.pickupRotateHudButtons[3],
            [ROTATE_PITCH_BACKWARD] = self.pickupRotateHudButtons[4],
            [ROTATE_ROLL_LEFT] = self.pickupRotateHudButtons[5],
            [ROTATE_ROLL_RIGHT] = self.pickupRotateHudButtons[6],
            [PUSH_FORWARD] = nil,
            [PULL_BACKWARD] = nil,

            [PRECISION_MOVE_LEFT] = self.precisionMoveHudButtons[1],
            [PRECISION_MOVE_RIGHT] = self.precisionMoveHudButtons[2],
            [PRECISION_MOVE_FORWARD] = self.precisionMoveHudButtons[3],
            [PRECISION_MOVE_BACKWARD] = self.precisionMoveHudButtons[4],
            [PRECISION_MOVE_DOWN] = self.precisionMoveHudButtons[5],
            [PRECISION_MOVE_UP] = self.precisionMoveHudButtons[6],

            [PRECISION_ROTATE_YAW_LEFT] = self.precisionRotateHudButtons[1],
            [PRECISION_ROTATE_YAW_RIGHT] = self.precisionRotateHudButtons[2],
            [PRECISION_ROTATE_PITCH_FORWARD] = self.precisionRotateHudButtons[3],
            [PRECISION_ROTATE_PITCH_BACKWARD] = self.precisionRotateHudButtons[4],
            [PRECISION_ROTATE_ROLL_LEFT] = self.precisionRotateHudButtons[5],
            [PRECISION_ROTATE_ROLL_RIGHT] = self.precisionRotateHudButtons[6],
        }

        do
            local axes = self.translationIndicators
            self.precisionMoveHudButtons[1].axis = axes[1]
            self.precisionMoveHudButtons[2].axis = axes[2]
            self.precisionMoveHudButtons[3].axis = axes[5]
            self.precisionMoveHudButtons[4].axis = axes[6]
            self.precisionMoveHudButtons[5].axis = axes[4]
            self.precisionMoveHudButtons[6].axis = axes[3]
        end

        do
            local axes = self.rotationIndicators

            self.pickupRotateHudButtons[1].axis = axes[1]
            self.pickupRotateHudButtons[2].axis = axes[2]
            self.pickupRotateHudButtons[3].axis = axes[5]
            self.pickupRotateHudButtons[4].axis = axes[6]
            self.pickupRotateHudButtons[5].axis = axes[3]
            self.pickupRotateHudButtons[6].axis = axes[4]

            self.precisionRotateHudButtons[1].axis = axes[1]
            self.precisionRotateHudButtons[2].axis = axes[2]
            self.precisionRotateHudButtons[3].axis = axes[5]
            self.precisionRotateHudButtons[4].axis = axes[6]
            self.precisionRotateHudButtons[5].axis = axes[3]
            self.precisionRotateHudButtons[6].axis = axes[4]
        end

        local function CanEditPath()
            if HousingEditorHasSelectablePathNode() then
                return true
            else
                local furnitureId = HousingEditorGetTargetInfo()
                if CompareId64ToNumber(furnitureId, 0) > 0 then
                    return HousingEditorCanFurnitureBePathed(furnitureId)
                end
            end
            return false
        end

        -- Edit Path
        local sharedEditPathKeybind = {
            name = function()
                local targetingPathableFurniture = false
                local furnitureId = HousingEditorGetTargetInfo()
                if CompareId64ToNumber(furnitureId, 0) > 0 then
                    targetingPathableFurniture = HousingEditorCanFurnitureBePathed(furnitureId)
                end

                if targetingPathableFurniture and HousingEditorGetNumPathNodesForFurniture(furnitureId) == 0 then
                    return GetString(SI_HOUSING_EDITOR_CREATE_PATH)
                else
                    return GetString(SI_HOUSING_EDITOR_PATH)
                end
            end,
            callback =  function()
                            local result = HousingEditorEditTargettedFurniturePath()
                            ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                            if result == HOUSING_REQUEST_RESULT_SUCCESS then
                                TriggerTutorial(TUTORIAL_TRIGGER_HOUSING_EDITOR_ENTERED_PATH_MODE)
                                PlaySound(SOUNDS.HOUSING_EDITOR_PICKUP_ITEM)
                            end
                        end,
            -- pallet descriptors are ethereal and shown in a keybind button. We need both visible and enabled so it acts properly
            visible = CanEditPath,
            enabled = CanEditPath,
            order = 30,
            ethereal = true,
        }
        local keyboardEditPathDescriptor = {}
        ZO_ShallowTableCopy(sharedEditPathKeybind, keyboardEditPathDescriptor)
        keyboardEditPathDescriptor.keybind = "HOUSING_EDITOR_BEGIN_EDIT_PATH"

        local gamepadEditPathDescriptor = {}
        ZO_ShallowTableCopy(sharedEditPathKeybind, gamepadEditPathDescriptor)
        gamepadEditPathDescriptor.keybind = "HOUSING_EDITOR_QUINARY_ACTION"

        --Primary (Selection/Placement)
        local selectionPrimaryDescriptor =
        {
            name =  GetString(SI_HOUSING_EDITOR_SELECT),
            keybind = "HOUSING_EDITOR_PRIMARY_ACTION",
            callback =  function()
                            HousingEditorSetPlacementType(HOUSING_EDITOR_PLACEMENT_TYPE_PICKUP)
                            local result = HousingEditorSelectTargetUnderReticle()
                            ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                            if result == HOUSING_REQUEST_RESULT_SUCCESS then
                                PlaySound(SOUNDS.HOUSING_EDITOR_PICKUP_ITEM)
                            end
                        end,
            -- pallet descriptors are ethereal and shown in a keybind button. We need both visible and enabled so it acts properly
            enabled = function()
                return HousingEditorCanSelectTargettedFurniture() or HousingEditorHasSelectablePathNode()
            end,
            visible = function()
                return HousingEditorCanSelectTargettedFurniture() or HousingEditorHasSelectablePathNode()
            end,
            order = 10,
            ethereal = true,
        }

        --Tertiary 
        local selectionTertiaryDescriptor =
        {
            name = GetString(SI_HOUSING_EDITOR_PRECISION_EDIT),
            keybind = "HOUSING_EDITOR_TERTIARY_ACTION",
            callback =  function()
                            HousingEditorSetPlacementType(HOUSING_EDITOR_PLACEMENT_TYPE_PRECISION)
                            local result = HousingEditorSelectTargetUnderReticle()
                            ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                            if result == HOUSING_REQUEST_RESULT_SUCCESS then
                                TriggerTutorial(TUTORIAL_TRIGGER_HOUSING_EDITOR_ENTERED_PRECISION_PLACEMENT_MODE)
                                PlaySound(SOUNDS.HOUSING_EDITOR_PICKUP_ITEM)
                                return
                            end
                            HousingEditorSetPlacementType(HOUSING_EDITOR_PLACEMENT_TYPE_PICKUP)
                        end,
            -- pallet descriptors are ethereal and shown in a keybind button. We need both visible and enabled so it acts properly
            visible = function()
                return HousingEditorCanSelectTargettedFurniture() or HousingEditorHasSelectablePathNode()
            end,
            enabled = function()
                return HousingEditorCanSelectTargettedFurniture() or HousingEditorHasSelectablePathNode()
            end,
            order = 20,
            ethereal = true,
        }

        local function CanLinkFurniture()
            local furnitureId, nodeIndex = HousingEditorGetTargetInfo()
            local hasFurnitureId = CompareId64ToNumber(furnitureId, 0) > 0
            return hasFurnitureId and nodeIndex == nil and HousingEditorGetNumPathNodesForFurniture(furnitureId) == 0
        end

        -- Link Furniture
        local selectionLinkFurnitureDescriptor =
        {
            name = GetString(SI_HOUSING_EDITOR_LINK),
            keybind = "HOUSING_EDITOR_BEGIN_FURNITURE_LINKING",
            callback =  function()
                            local result = HousingEditorBeginLinkingTargettedFurniture()
                            ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                            if result == HOUSING_REQUEST_RESULT_SUCCESS then
                                PlaySound(SOUNDS.HOUSING_EDITOR_PICKUP_ITEM)
                            end
                        end,
            -- pallet descriptors are ethereal and shown in a keybind button. We need both visible and enabled so it acts properly
            visible = CanLinkFurniture,
            enabled = CanLinkFurniture,
            order = 40,
            ethereal = true,
        }

        self.selectionModeKeybindPaletteDescriptor =
        {
           selectionPrimaryDescriptor,
           selectionTertiaryDescriptor,
           selectionLinkFurnitureDescriptor,
           keyboardEditPathDescriptor
        }

        self.selectionModeKeybindPaletteGamepadDescriptor =
        {
           selectionPrimaryDescriptor,
           selectionTertiaryDescriptor,
           selectionLinkFurnitureDescriptor,
           gamepadEditPathDescriptor
        }

        self.selectionModeKeybindStripDescriptor =
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,

            --Secondary 
            {
                name = GetString(SI_HOUSING_EDITOR_BROWSE),
                keybind = "HOUSING_EDITOR_SECONDARY_ACTION",
                visible = function() 
                                return IsOwnerOfCurrentHouse()
                            end,
                callback =  function()
                                HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_BROWSE)
                            end,
                order = 20,
            },

             --Jump to safe loc
            {
                name = GetString(SI_HOUSING_EDITOR_SAFE_LOC),
                keybind = "HOUSING_EDITOR_JUMP_TO_SAFE_LOC",
                callback =  function()
                                HousingEditorJumpToSafeLocation()
                            end,
                order = 60,
            },

            -- Undo
            {
                alignment = KEYBIND_STRIP_ALIGN_LEFT,
                name = GetString(SI_HOUSING_EDITOR_UNDO),
                keybind = "HOUSING_EDITOR_UNDO_ACTION",
                enabled = function() return CanUndoLastHousingEditorCommand() end,
                callback = function()
                                UndoLastHousingEditorCommand()
                           end,
            },

            -- Redo
            {
                alignment = KEYBIND_STRIP_ALIGN_LEFT,
                name = GetString(SI_HOUSING_EDITOR_REDO),
                keybind = "HOUSING_EDITOR_REDO_ACTION",
                enabled = function() return CanRedoLastHousingEditorCommand() end,
                callback = function()
                                RedoLastHousingEditorCommand()
                           end,
            },
        }

        self.placementModeKeybindPaletteDescriptor =
        {
            --Primary (Selection/Placement)
            {
                name =  function()
                            local stackCount = HousingEditorGetSelectedFurnitureStackCount()
                            if stackCount <= 1 then
                                return GetString(SI_HOUSING_EDITOR_PLACE)
                            else
                                return zo_strformat(SI_HOUSING_EDITOR_PLACE_WITH_STACK_COUNT, stackCount)
                            end
                        end,
                keybind = "HOUSING_EDITOR_PRIMARY_ACTION",
                callback =  function()
                                local result = HousingEditorRequestSelectedPlacement()
                                ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                                if result == HOUSING_REQUEST_RESULT_SUCCESS then
                                    PlaySound(SOUNDS.HOUSING_EDITOR_PLACE_ITEM)
                                end
                                self:ClearPlacementKeyPresses()
                            end,
                order = 10,
                ethereal = true,
            },
        }

        self.placementModeKeybindStripDescriptor =
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,

            --Negative
            {
                name = GetString(SI_HOUSING_EDITOR_CANCEL),
                keybind = "HOUSING_EDITOR_NEGATIVE_ACTION",
                callback = function()
                                HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_SELECTION)
                            end,
                alignment = KEYBIND_STRIP_ALIGN_LEFT,
            },

            --Secondary 
            {
                name = GetString(SI_HOUSING_EDITOR_PUT_AWAY),
                keybind = "HOUSING_EDITOR_SECONDARY_ACTION",
                visible = function() 
                                return IsOwnerOfCurrentHouse()
                            end,
                callback =  function()
                                local result = HousingEditorRequestRemoveSelectedFurniture()
                                ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                                if result == HOUSING_REQUEST_RESULT_SUCCESS then
                                    PlaySound(SOUNDS.HOUSING_EDITOR_RETRIEVE_ITEM)
                                end
                            end,
                order = 20,
            },

            --Tertiary (Surface drag for Gamepad, Mouse mode for keyboard)
            {
                name = function()
                            if IsInGamepadPreferredMode() then
                                if HousingEditorIsSurfaceDragModeEnabled() then 
                                    return GetString(SI_HOUSING_EDITOR_SURFACE_DRAG_OFF)
                                else
                                    return GetString(SI_HOUSING_EDITOR_SURFACE_DRAG_ON)
                                end
                            else
                                return GetString(SI_HOUSING_EDITOR_CURSOR_MODE)
                            end
                        end,
                keybind = "HOUSING_EDITOR_TERTIARY_ACTION",
                callback = function()
                                if IsInGamepadPreferredMode() then 
                                    HousingEditorToggleSurfaceDragMode()
                                    self:UpdateKeybinds()
                                else
                                    SCENE_MANAGER:OnToggleHUDUIBinding()
                                end
                           end,
                order = 30,
            },

            --Quaternary (keyboard only)
            {
                name = function()
                            if HousingEditorIsSurfaceDragModeEnabled() then 
                                return GetString(SI_HOUSING_EDITOR_SURFACE_DRAG_OFF)
                            else
                                return GetString(SI_HOUSING_EDITOR_SURFACE_DRAG_ON)
                            end
                        end,
                keybind = "HOUSING_EDITOR_QUATERNARY_ACTION",
                visible = function() return not IsInGamepadPreferredMode() end,
                callback = function() 
                                HousingEditorToggleSurfaceDragMode()
                                self:UpdateKeybinds()
                           end,
                order = 40,
            },

            --Roll Right
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Yaw Right",
                keybind = "HOUSING_EDITOR_YAW_RIGHT",
                ethereal = true,
                handlesKeyUp = true,
                callback =  function(isUp)
                                PlacementCallback(ROTATE_YAW_RIGHT, isUp)
                            end,
            },

            --Roll Left
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Yaw Left",
                keybind = "HOUSING_EDITOR_YAW_LEFT",
                ethereal = true,
                handlesKeyUp = true,
                callback =  function(isUp)
                                PlacementCallback(ROTATE_YAW_LEFT, isUp)
                            end,
            },

            --Pitch Right
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Pitch Forward",
                keybind = "HOUSING_EDITOR_PITCH_FORWARD",
                ethereal = true,
                handlesKeyUp = true,
                callback =  function(isUp)
                                PlacementCallback(ROTATE_PITCH_FORWARD, isUp)
                            end,
            },

            --Pitch Left
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Pitch Backward",
                keybind = "HOUSING_EDITOR_PITCH_BACKWARD",
                ethereal = true,
                handlesKeyUp = true,
                callback =  function(isUp)
                                PlacementCallback(ROTATE_PITCH_BACKWARD, isUp)
                            end,
            },

            --Roll Right
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Roll Right",
                keybind = "HOUSING_EDITOR_ROLL_RIGHT",
                ethereal = true,
                handlesKeyUp = true,
                callback =  function(isUp)
                                PlacementCallback(ROTATE_ROLL_RIGHT, isUp)
                            end,
            },

            --Roll Left
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Roll Left",
                keybind = "HOUSING_EDITOR_ROLL_LEFT",
                ethereal = true,
                handlesKeyUp = true,
                callback =  function(isUp)
                                PlacementCallback(ROTATE_ROLL_LEFT, isUp)
                            end,
            },
            --Align to Surface
            {
                name = GetString(SI_HOUSING_EDITOR_ALIGN),
                keybind = "HOUSING_EDITOR_ALIGN_TO_SURFACE",
                callback =  function()
                                HousingEditorAlignSelectedObjectToSurface()
                            end,
                order = 50,
            },
        }

        self.precisionMovePlacementModeKeybindPaletteDescriptor =
        {
            --Primary (Selection/Placement)
            {
                name =  GetString(SI_HOUSING_EDITOR_PLACE),
                keybind = "HOUSING_EDITOR_PRIMARY_ACTION",
                callback =  function()
                                local result = HousingEditorRequestSelectedPlacement()
                                ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                                if result == HOUSING_REQUEST_RESULT_SUCCESS then
                                    PlaySound(SOUNDS.HOUSING_EDITOR_PLACE_ITEM)
                                end
                                self:ClearPlacementKeyPresses()
                            end,
                order = 10,
                ethereal = true,
            },
        }

        self.precisionMovePlacementModeKeybindStripDescriptor =
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,
            --Negative
            {
                name = GetString(SI_HOUSING_EDITOR_CANCEL),
                keybind = "HOUSING_EDITOR_NEGATIVE_ACTION",
                callback = function()
                                if GetHousingEditorMode() == HOUSING_EDITOR_MODE_NODE_PLACEMENT then
                                    HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_PATH)
                                else
                                    HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_SELECTION)
                                end
                            end,
                alignment = KEYBIND_STRIP_ALIGN_LEFT,
            },

            --Secondary (Swap to Rotate Mode)
            {
                name = GetString(SI_HOUSING_EDITOR_PRECISION_ROTATE_MODE),
                keybind = "HOUSING_EDITOR_SECONDARY_ACTION",
                callback =  function()
                                self:TogglePrecisionPlacementMode()
                                self:UpdateKeybinds()
                            end,
                order = 20,
            },

            --Tertiary (Cycle Movement Units for Gamepad, Mouse mode for keyboard)
            {
                name = function()
                            if IsInGamepadPreferredMode() then
                                return zo_strformat(SI_HOUSING_EDITOR_PRECISION_MOVE_UNITS, ZO_CommaDelimitDecimalNumber(HousingEditorGetPrecisionMoveUnits()))
                            else
                                return GetString(SI_HOUSING_EDITOR_CURSOR_MODE)
                            end
                        end,
                keybind = "HOUSING_EDITOR_TERTIARY_ACTION",
                callback = function()
                                if IsInGamepadPreferredMode() then 
                                    self:AdjustPrecisionUnits(HOUSING_EDITOR_PRECISION_PLACEMENT_MODE_MOVE, PRECISION_UNIT_ADJUSTMENT_INCREMENT)
                                    RefreshUnits()
                                else
                                    SCENE_MANAGER:OnToggleHUDUIBinding()
                                end
                           end,
                order = 30,
            },

            --Quaternary (Cycle Movement Units)
            {
                name = function()
                    return zo_strformat(SI_HOUSING_EDITOR_PRECISION_MOVE_UNITS, ZO_CommaDelimitDecimalNumber(HousingEditorGetPrecisionMoveUnits()))
                end,
                keybind = "HOUSING_EDITOR_QUATERNARY_ACTION",
                visible = function()
                    return not IsInGamepadPreferredMode()
                end,
                callback = function()
                               self:AdjustPrecisionUnits(HOUSING_EDITOR_PRECISION_PLACEMENT_MODE_MOVE, PRECISION_UNIT_ADJUSTMENT_INCREMENT)
                               RefreshUnits()
                           end,
                order = 40,
            },

            --Straighten
            {
                name = GetString(SI_HOUSING_EDITOR_STRAIGHTEN),
                keybind = "HOUSING_EDITOR_JUMP_TO_SAFE_LOC",
                visible = function()
                                return GetHousingEditorMode() == HOUSING_EDITOR_MODE_PLACEMENT
                          end,
                callback = function() 
                                HousingEditorStraightenSelectedObject()
                           end,
                order = 50,
            },

            --Precision Move Right
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Yaw Right",
                keybind = "HOUSING_EDITOR_YAW_RIGHT",
                ethereal = true,
                handlesKeyUp = true,
                callback =  function(isUp)
                                PlacementCallback(PRECISION_MOVE_RIGHT, isUp)
                            end,
            },

            --Precision Move Left
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Yaw Left",
                keybind = "HOUSING_EDITOR_YAW_LEFT",
                ethereal = true,
                handlesKeyUp = true,
                callback =  function(isUp)
                                PlacementCallback(PRECISION_MOVE_LEFT, isUp)
                            end,
            },

            --Precision Move Forward
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Pitch Forward",
                keybind = "HOUSING_EDITOR_PITCH_FORWARD",
                ethereal = true,
                handlesKeyUp = true,
                callback =  function(isUp)
                                PlacementCallback(PRECISION_MOVE_FORWARD, isUp)
                            end,
            },

            --Precision Move Backward
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Pitch Backward",
                keybind = "HOUSING_EDITOR_PITCH_BACKWARD",
                ethereal = true,
                handlesKeyUp = true,
                callback =  function(isUp)
                                PlacementCallback(PRECISION_MOVE_BACKWARD, isUp)
                            end,
            },

            --Precision Move Up
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Roll Right",
                keybind = "HOUSING_EDITOR_ROLL_RIGHT",
                ethereal = true,
                handlesKeyUp = true,
                callback =  function(isUp)
                                PlacementCallback(PRECISION_MOVE_UP, isUp)
                            end,
            },

            --Precision Move Down
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Roll Left",
                keybind = "HOUSING_EDITOR_ROLL_LEFT",
                ethereal = true,
                handlesKeyUp = true,
                callback =  function(isUp)
                                PlacementCallback(PRECISION_MOVE_DOWN, isUp)
                            end,
            },

            --Align to Surface
            {
                name = GetString(SI_HOUSING_EDITOR_ALIGN),
                keybind = "HOUSING_EDITOR_ALIGN_TO_SURFACE",
                callback =  function()
                                HousingEditorAlignSelectedObjectToSurface()
                            end,
                order = 50,
            },
        }

        self.precisionRotatePlacementModeKeybindPaletteDescriptor =
        {
            --Primary (Placement)
            {
                name =  GetString(SI_HOUSING_EDITOR_PLACE),
                keybind = "HOUSING_EDITOR_PRIMARY_ACTION",
                callback =  function()
                                local result = HousingEditorRequestSelectedPlacement()
                                ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                                if result == HOUSING_REQUEST_RESULT_SUCCESS then
                                    PlaySound(SOUNDS.HOUSING_EDITOR_PLACE_ITEM)
                                end
                                self:ClearPlacementKeyPresses()
                            end,
                order = 10,
                ethereal = true,
            },
        }

        self.precisionRotatePlacementModeKeybindStripDescriptor =
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,

            --Negative
            {
                name = GetString(SI_HOUSING_EDITOR_CANCEL),
                keybind = "HOUSING_EDITOR_NEGATIVE_ACTION",
                callback = function()
                                if GetHousingEditorMode() == HOUSING_EDITOR_MODE_NODE_PLACEMENT then
                                    HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_PATH)
                                else
                                    HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_SELECTION)
                                end
                            end,
                alignment = KEYBIND_STRIP_ALIGN_LEFT,
            },

            --Secondary (Swap to Move Mode)
            {
                name = GetString(SI_HOUSING_EDITOR_PRECISION_MOVE_MODE),
                keybind = "HOUSING_EDITOR_SECONDARY_ACTION",
                callback =  function()
                                self:TogglePrecisionPlacementMode()
                                self:UpdateKeybinds()
                            end,
                order = 20,
            },

            --Tertiary (Cycle Rotation Units for Gamepad, Mouse mode for keyboard)
            {
                name = function()
                            if IsInGamepadPreferredMode() then
                                return zo_strformat(SI_HOUSING_EDITOR_PRECISION_ROTATE_UNITS, ZO_FastFormatDecimalNumber(ZO_CommaDelimitDecimalNumber(zo_roundToNearest(math.deg(HousingEditorGetPrecisionRotateUnits()), 0.01))))
                            else
                                return GetString(SI_HOUSING_EDITOR_CURSOR_MODE)
                            end
                        end,
                keybind = "HOUSING_EDITOR_TERTIARY_ACTION",
                callback = function()
                                if IsInGamepadPreferredMode() then 
                                    self:AdjustPrecisionUnits(HOUSING_EDITOR_PRECISION_PLACEMENT_MODE_ROTATE, PRECISION_UNIT_ADJUSTMENT_INCREMENT)
                                    RefreshUnits()
                                else
                                    SCENE_MANAGER:OnToggleHUDUIBinding()
                                end
                           end,
                order = 30,
            },

            --Quaternary (Cycle Rotation Units)
            {
                name = function()
                    return zo_strformat(SI_HOUSING_EDITOR_PRECISION_ROTATE_UNITS, ZO_FastFormatDecimalNumber(ZO_CommaDelimitDecimalNumber(zo_roundToNearest(math.deg(HousingEditorGetPrecisionRotateUnits()), 0.01))))
                end,
                keybind = "HOUSING_EDITOR_QUATERNARY_ACTION",
                visible = function()
                    return not IsInGamepadPreferredMode()
                end,
                callback = function()
                               self:AdjustPrecisionUnits(HOUSING_EDITOR_PRECISION_PLACEMENT_MODE_ROTATE, PRECISION_UNIT_ADJUSTMENT_INCREMENT)
                               RefreshUnits()
                           end,
                order = 40,
            },

            --Straighten
            {
                name = GetString(SI_HOUSING_EDITOR_STRAIGHTEN),
                keybind = "HOUSING_EDITOR_JUMP_TO_SAFE_LOC",
                visible = function()
                                return GetHousingEditorMode() == HOUSING_EDITOR_MODE_PLACEMENT
                          end,
                callback = function() 
                                HousingEditorStraightenSelectedObject()
                           end,
                order = 50,
            },

            --Precision Yaw Right
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Yaw Right",
                keybind = "HOUSING_EDITOR_YAW_RIGHT",
                ethereal = true,
                handlesKeyUp = true,
                callback =  function(isUp)
                                PlacementCallback(PRECISION_ROTATE_YAW_RIGHT, isUp)
                            end,
            },

            --Precision Yaw Left
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Yaw Left",
                keybind = "HOUSING_EDITOR_YAW_LEFT",
                ethereal = true,
                handlesKeyUp = true,
                callback =  function(isUp)
                                PlacementCallback(PRECISION_ROTATE_YAW_LEFT, isUp)
                            end,
            },

            --Precision Pitch Right
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Pitch Forward",
                keybind = "HOUSING_EDITOR_PITCH_FORWARD",
                ethereal = true,
                handlesKeyUp = true,
                enabled = function()
                                return GetHousingEditorMode() == HOUSING_EDITOR_MODE_PLACEMENT
                          end,
                callback =  function(isUp)
                                PlacementCallback(PRECISION_ROTATE_PITCH_FORWARD, isUp)
                            end,
            },

            --Precision Pitch Left
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Pitch Backward",
                keybind = "HOUSING_EDITOR_PITCH_BACKWARD",
                ethereal = true,
                handlesKeyUp = true,
                enabled = function()
                                return GetHousingEditorMode() == HOUSING_EDITOR_MODE_PLACEMENT
                          end,
                callback =  function(isUp)
                                PlacementCallback(PRECISION_ROTATE_PITCH_BACKWARD, isUp)
                            end,
            },

            --Precision Roll Right
            {
            --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Roll Right",
                keybind = "HOUSING_EDITOR_ROLL_RIGHT",
                ethereal = true,
                handlesKeyUp = true,
                enabled = function()
                                return GetHousingEditorMode() == HOUSING_EDITOR_MODE_PLACEMENT
                          end,
                callback =  function(isUp)
                                PlacementCallback(PRECISION_ROTATE_ROLL_RIGHT, isUp)
                            end,
            },

            --Precision Roll Left
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Roll Left",
                keybind = "HOUSING_EDITOR_ROLL_LEFT",
                ethereal = true,
                handlesKeyUp = true,
                enabled = function()
                                return GetHousingEditorMode() == HOUSING_EDITOR_MODE_PLACEMENT
                          end,
                callback =  function(isUp)
                                PlacementCallback(PRECISION_ROTATE_ROLL_LEFT, isUp)
                            end,
            },

            --Align to Surface
            {
                name = GetString(SI_HOUSING_EDITOR_ALIGN),
                keybind = "HOUSING_EDITOR_ALIGN_TO_SURFACE",
                callback =  function()
                                HousingEditorAlignSelectedObjectToSurface()
                            end,
                order = 50,
            },
        }

        self.linkModeKeybindPaletteDescriptor =
        {
            --Primary (Unlink/Link As Child)
            {
                name = function()
                            local linkResult = HousingEditorGetLinkRelationshipFromSelectedChildToPendingFurniture()
                            if linkResult == HOUSING_EDITOR_PENDING_LINK_RELATIONSHIP_LINKED_TO_PARENT then
                                return GetString(SI_HOUSING_EDITOR_REMOVE_PARENT)
                            elseif linkResult == HOUSING_EDITOR_PENDING_LINK_RELATIONSHIP_LINKED_AS_CHILD then
                                return GetString(SI_HOUSING_EDITOR_REMOVE_CHILD)
                            elseif linkResult == HOUSING_EDITOR_PENDING_LINK_RELATIONSHIP_NO_LINK then
                                return GetString(SI_HOUSING_EDITOR_ADD_AS_CHILD)
                            elseif linkResult == HOUSING_EDITOR_PENDING_LINK_RELATIONSHIP_BAD_LINK then
                                return GetString(SI_HOUSING_EDITOR_BAD_LINK_ACTION)
                            end
                       end,
                keybind = "HOUSING_EDITOR_PRIMARY_ACTION",
                visible = function()
                              local linkResult = HousingEditorGetLinkRelationshipFromSelectedChildToPendingFurniture()
                              return linkResult ~= HOUSING_EDITOR_PENDING_LINK_RELATIONSHIP_INVALID
                          end,
                enabled = function()
                                local linkResult = HousingEditorGetLinkRelationshipFromSelectedChildToPendingFurniture()
                                if linkResult == HOUSING_EDITOR_PENDING_LINK_RELATIONSHIP_BAD_LINK then
                                    local result = HousingEditorGetPendingBadLinkResult()
                                    return false, GetString("SI_HOUSINGREQUESTRESULT", result)
                                else
                                    return true
                                end
                          end,
                callback =  function()
                                HousingEditorPerformPendingLinkOperation()
                            end,
                order = 10,
                ethereal = true,
            },
        }

        self.linkModeKeybindStripDescriptor =
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,

            --Negative
            {
                name = GetString(SI_HOUSING_EDITOR_EXIT_LINK),
                keybind = "HOUSING_EDITOR_SECONDARY_ACTION",
                callback = function()
                                HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_SELECTION)
                            end,
                alignment = KEYBIND_STRIP_ALIGN_LEFT,
            },

            --Secondary (Remove My Parent)
            {
                name = GetString(SI_HOUSING_EDITOR_REMOVE_PARENT),
                keybind = "HOUSING_EDITOR_TERTIARY_ACTION",
                visible = function() 
                                local linkResult = HousingEditorGetLinkRelationshipFromSelectedChildToPendingFurniture()
                                if linkResult == HOUSING_EDITOR_PENDING_LINK_RELATIONSHIP_INVALID then
                                    return HousingEditorCanRemoveParentFromPendingFurniture() == HOUSING_REQUEST_RESULT_SUCCESS
                                end
                            end,
                callback =  function()
                                HousingEditorRemoveParentFromPendingFurniture()
                            end,
                order = 20,
            },

            --Tertiary (Remove All Children)
            {
                name = GetString(SI_HOUSING_EDITOR_REMOVE_ALL_CHILDREN),
                keybind = "HOUSING_EDITOR_NEGATIVE_ACTION",
                visible = function()
                                local linkResult = HousingEditorGetLinkRelationshipFromSelectedChildToPendingFurniture()
                                if linkResult == HOUSING_EDITOR_PENDING_LINK_RELATIONSHIP_INVALID then
                                    return HousingEditorCanRemoveAllChildrenFromPendingFurniture() == HOUSING_REQUEST_RESULT_SUCCESS
                                end
                           end,
                callback = function()
                                HousingEditorRemoveAllChildrenFromPendingFurniture()
                           end,
                order = 30,
            },
        }

        --Primary (Place New Node)
        local pathPrimaryDescriptor =
        {
            name = GetString(SI_HOUSING_EDITOR_PATH_SELECT_NODE),
            keybind = "HOUSING_EDITOR_PRIMARY_ACTION",
            -- pallet descriptors are ethereal and shown in a keybind button. We need both visible and enabled so it acts properly
            visible =   function()
                            return HousingEditorHasSelectablePathNode()
                        end,
            enabled =   function()
                            return HousingEditorHasSelectablePathNode()
                        end,
            callback =  function()
                            local result = HousingEditorSelectTargettedPathNode()
                            ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                        end,
            order = 10,
            ethereal = true,
        }

        -- Tertiary (Precision Edit Mode)
        local pathTertiaryDescriptor =
        {
            name = GetString(SI_HOUSING_EDITOR_PRECISION_EDIT),
            keybind = "HOUSING_EDITOR_TERTIARY_ACTION",
            callback =  function()
                            if HousingEditorHasSelectablePathNode() then
                                HousingEditorSetPlacementType(HOUSING_EDITOR_PLACEMENT_TYPE_PRECISION)
                                local result = HousingEditorSelectTargettedPathNode()
                                ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                                if result == HOUSING_REQUEST_RESULT_SUCCESS then
                                    TriggerTutorial(TUTORIAL_TRIGGER_HOUSING_EDITOR_ENTERED_PRECISION_PLACEMENT_MODE)
                                    PlaySound(SOUNDS.HOUSING_EDITOR_PICKUP_ITEM)
                                    return
                                end
                            end
                            HousingEditorSetPlacementType(HOUSING_EDITOR_PLACEMENT_TYPE_PICKUP)
                        end,
            -- pallet descriptors are ethereal and shown in a keybind button. We need both visible and enabled so it acts properly
            visible =   function()
                            return HousingEditorHasSelectablePathNode()
                        end,
            enabled =   function()
                            return HousingEditorHasSelectablePathNode()
                        end,
            order = 12,
            ethereal = true,
        }

        --Quarternary (Change node speed)
        local pathChangeSpeedDescriptor =
        {
            name =  function()
                        local placeSpeed = GetString("SI_HOUSINGPATHMOVEMENTSPEED", HousingEditorGetSelectedPathNodeSpeed())
                        return zo_strformat(SI_HOUSING_EDITOR_PATH_NODE_SPEED, ZO_SELECTED_TEXT:Colorize(placeSpeed))
                    end,
            -- pallet descriptors are ethereal and shown in a keybind button. We need both visible and enabled so it acts properly
            visible =   function()
                            return HousingEditorHasSelectablePathNode()
                        end,
            enabled =   function()
                            return HousingEditorHasSelectablePathNode()
                        end,
            callback =  function()
                            local result = HousingEditorToggleSelectedPathNodeSpeed()
                            ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                            self:UpdateKeybinds()
                        end,
            order = 40,
            ethereal = true,
        }
        local keyboardPathChangeSpeedDescriptor = {}
        ZO_ShallowTableCopy(pathChangeSpeedDescriptor, keyboardPathChangeSpeedDescriptor)
        keyboardPathChangeSpeedDescriptor.keybind = "HOUSING_EDITOR_TOGGLE_NODE_SPEED"

        local gamepadPathChangeSpeedDescriptor = {}
        ZO_ShallowTableCopy(pathChangeSpeedDescriptor, gamepadPathChangeSpeedDescriptor)
        gamepadPathChangeSpeedDescriptor.keybind = "HOUSING_EDITOR_QUATERNARY_ACTION"

        --Quinary (Change node delay time)
        local pathChangeDelayDescriptor =
        {
            name =  function()
                        local delayTimeMS = HousingEditorGetSelectedPathNodeDelayTime()
                        local delayTimeS = ZO_FormatTimeMilliseconds(delayTimeMS, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT, TIME_FORMAT_PRECISION_SECONDS)
                        return zo_strformat(SI_HOUSING_EDITOR_PATH_NODE_WAIT_TIME, ZO_SELECTED_TEXT:Colorize(delayTimeS))
                    end,
            -- pallet descriptors are ethereal and shown in a keybind button. We need both visible and enabled so it acts properly
            visible =   function()
                            return HousingEditorHasSelectablePathNode()
                        end,
            enabled =   function()
                            return HousingEditorHasSelectablePathNode()
                        end,
            callback =  function()
                            local result = HousingEditorToggleSelectedPathNodeDelayTime()
                            ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                            self:UpdateKeybinds()
                        end,
            order = 50,
            ethereal = true,
        }

        local keyboardPathChangeDelayDescriptor = {}
        ZO_ShallowTableCopy(pathChangeDelayDescriptor, keyboardPathChangeDelayDescriptor)
        keyboardPathChangeDelayDescriptor.keybind = "HOUSING_EDITOR_TOGGLE_NODE_DELAY"

        local gamepadPathChangeDelayDescriptor = {}
        ZO_ShallowTableCopy(pathChangeDelayDescriptor, gamepadPathChangeDelayDescriptor)
        gamepadPathChangeDelayDescriptor.keybind = "HOUSING_EDITOR_QUINARY_ACTION"

        self.pathModeKeybindPaletteDescriptor =
        {
            pathPrimaryDescriptor,
            pathTertiaryDescriptor,
            keyboardPathChangeSpeedDescriptor,
            keyboardPathChangeDelayDescriptor
        }

        self.pathModeKeybindPaletteGamepadDescriptor =
        {
            pathPrimaryDescriptor,
            pathTertiaryDescriptor,
            gamepadPathChangeSpeedDescriptor,
            gamepadPathChangeDelayDescriptor
        }

        -- Edit Path
        local pathEditDescriptor =
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = GetString(SI_HOUSING_EDITOR_EXIT_PATH),
            callback =  function()
                            local result = HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_SELECTION)
                            ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                        end,
        }
        local keyboardPathEditDescriptor = {}
        ZO_ShallowTableCopy(pathEditDescriptor, keyboardPathEditDescriptor)
        keyboardPathEditDescriptor.keybind = "HOUSING_EDITOR_BEGIN_EDIT_PATH"

        local gamepadPathEditDescriptor = {}
        ZO_ShallowTableCopy(pathEditDescriptor, gamepadPathEditDescriptor)
        gamepadPathEditDescriptor.keybind = "HOUSING_EDITOR_SECONDARY_ACTION"

        -- Undo
        local pathUndoDescriptor =
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = GetString(SI_HOUSING_EDITOR_UNDO),
            keybind = "HOUSING_EDITOR_UNDO_ACTION",
            enabled = function() return CanUndoLastHousingEditorCommand() end,
            callback = UndoLastHousingEditorCommand,
        }

        -- Redo
        local pathRedoDescriptor =
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = GetString(SI_HOUSING_EDITOR_REDO),
            keybind = "HOUSING_EDITOR_REDO_ACTION",
            enabled = function() return CanRedoLastHousingEditorCommand() end,
            callback = RedoLastHousingEditorCommand,
        }

        --Linking Button (Add Node Before)
        local pathAddNodeBeforeDescriptor =
        {
            name =  function()
                        local numLeft = HOUSING_MAX_FURNITURE_PATH_NODES - HousingEditorGetNumPathNodesInSelectedFurniture()
                        if HousingEditorHasSelectablePathNode() then
                            return zo_strformat(SI_HOUSING_EDITOR_PATH_ADD_NODE_BEFORE, ZO_SELECTED_TEXT:Colorize(numLeft))
                        else
                            return zo_strformat(SI_HOUSING_EDITOR_PATH_ADD_NEW_NODE, ZO_SELECTED_TEXT:Colorize(numLeft))
                        end
                    end,
            keybind = "HOUSING_EDITOR_BEGIN_FURNITURE_LINKING",
            enabled = function()
                            local numLeft = HOUSING_MAX_FURNITURE_PATH_NODES - HousingEditorGetNumPathNodesInSelectedFurniture()
                            return numLeft > 0
                        end,
            callback =  function()
                            local insertIndex
                            if HousingEditorHasSelectablePathNode() then
                                local furnitureId, pathIndex = HousingEditorGetTargetInfo()
                                insertIndex = pathIndex
                            else
                                local numNodes = HousingEditorGetNumPathNodesInSelectedFurniture()
                                insertIndex = numNodes + 1
                            end
                            local result = HousingEditorBeginPlaceNewPathNode(insertIndex)
                            ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                        end,
            order = 10,
        }

        -- Secondary (Path Settings)
        local pathSettingsDescriptor =
        {
            name =  GetString(SI_HOUSING_EDITOR_PATH_SETTINGS),
            alignment = KEYBIND_STRIP_ALIGN_RIGHT,
            callback = function()
                            local furnitureId = HousingEditorGetSelectedFurnitureId()
                            SYSTEMS:GetObject("path_settings"):SetPathData(furnitureId)
                            SYSTEMS:PushScene("housing_path_settings")
                        end,
            order = 27,
        }
        local keyboardPathSettingsDescriptor = {}
        ZO_ShallowTableCopy(pathSettingsDescriptor, keyboardPathSettingsDescriptor)
        keyboardPathSettingsDescriptor.keybind = "HOUSING_EDITOR_SECONDARY_ACTION"

        local gamepadPathSettingsDescriptor = {}
        ZO_ShallowTableCopy(pathSettingsDescriptor, gamepadPathSettingsDescriptor)
        gamepadPathSettingsDescriptor.keybind = "HOUSING_EDITOR_JUMP_TO_SAFE_LOC"

        self.pathModeKeybindStripDescriptor =
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,

            keyboardPathEditDescriptor,
            pathUndoDescriptor,
            pathRedoDescriptor,
            pathAddNodeBeforeDescriptor,
            keyboardPathSettingsDescriptor
        }

        self.pathModeKeybindStripGamepadDescriptor =
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,

            gamepadPathEditDescriptor,
            pathUndoDescriptor,
            pathRedoDescriptor,
            pathAddNodeBeforeDescriptor,
            gamepadPathSettingsDescriptor
        }

        self.nodePlacementModeKeybindPaletteDescriptor =
        {
            -- Primary (Confirm Node)
            {
                name = function()
                            local numLeft = HOUSING_MAX_FURNITURE_PATH_NODES - HousingEditorGetNumPathNodesInSelectedFurniture()
                            return zo_strformat(SI_HOUSING_EDITOR_CONFIRM_NODE_PLACEMENT, ZO_SELECTED_TEXT:Colorize(numLeft))
                       end,
                keybind = "HOUSING_EDITOR_PRIMARY_ACTION",
                callback =  function()
                                local result = HousingEditorRequestPlaceSelectedPathNode()
                                ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                                self:ClearPlacementKeyPresses()
                            end,
                ethereal = true,
            },
        }


        --Secondary (Remove Node)
        local nodePlacementRemoveNodeDescriptor =
        {
            name =  function()
                        if HousingEditorIsPlacingNewNode() then
                            return GetString(SI_HOUSING_EDITOR_PATH_FINISH_PLACEMENT)
                        else
                            return GetString(SI_HOUSING_EDITOR_PATH_REMOVE_NODE)
                        end
                    end,
            keybind = "HOUSING_EDITOR_SECONDARY_ACTION",
            callback =  function()
                            local result = HousingEditorRequestRemoveSelectedPathNode()
                            ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                            self:ClearPlacementKeyPresses()
                        end,
            order = 10,
        }

        --Quaternary (Change insert node speed)
        local nodePlacementNodeSpeedDescriptor =
        {
            name =  function()
                        local placeSpeed = GetString("SI_HOUSINGPATHMOVEMENTSPEED", HousingEditorGetSelectedPathNodeSpeed())
                        return zo_strformat(SI_HOUSING_EDITOR_PATH_NODE_SPEED, ZO_SELECTED_TEXT:Colorize(placeSpeed))
                    end,
            callback =  function()
                            local result = HousingEditorToggleSelectedPathNodeSpeed()
                            ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                            self:UpdateKeybinds()
                        end,
            order = 20,
        }
        local keyboardNodePlacementNodeSpeedDescriptor = {}
        ZO_ShallowTableCopy(nodePlacementNodeSpeedDescriptor, keyboardNodePlacementNodeSpeedDescriptor)
        keyboardNodePlacementNodeSpeedDescriptor.keybind = "HOUSING_EDITOR_TOGGLE_NODE_SPEED"

        local gamepadNodePlacementNodeSpeedDescriptor = {}
        ZO_ShallowTableCopy(nodePlacementNodeSpeedDescriptor, gamepadNodePlacementNodeSpeedDescriptor)
        gamepadNodePlacementNodeSpeedDescriptor.keybind = "HOUSING_EDITOR_QUATERNARY_ACTION"

        --Quinary (Change insert node delay time)
        local nodePlacementNodeDelayDescriptor =
        {
            name =  function()
                        local delayTimeMS = HousingEditorGetSelectedPathNodeDelayTime()
                        local delayTimeS = ZO_FormatTimeMilliseconds(delayTimeMS, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT, TIME_FORMAT_PRECISION_SECONDS)
                        return zo_strformat(SI_HOUSING_EDITOR_PATH_NODE_WAIT_TIME, ZO_SELECTED_TEXT:Colorize(delayTimeS))
                    end,
            callback =  function()
                            local result = HousingEditorToggleSelectedPathNodeDelayTime()
                            ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                            self:UpdateKeybinds()
                        end,
            order = 25,
        }
        local keyboardNodePlacementNodeDelayDescriptor = {}
        ZO_ShallowTableCopy(nodePlacementNodeDelayDescriptor, keyboardNodePlacementNodeDelayDescriptor)
        keyboardNodePlacementNodeDelayDescriptor.keybind = "HOUSING_EDITOR_TOGGLE_NODE_DELAY"

        local gamepadNodePlacementNodeDelayDescriptor = {}
        ZO_ShallowTableCopy(nodePlacementNodeDelayDescriptor, gamepadNodePlacementNodeDelayDescriptor)
        gamepadNodePlacementNodeDelayDescriptor.keybind = "HOUSING_EDITOR_QUINARY_ACTION"

        --Align to Surface
        local nodePlacementAlignDescriptor =
        {
            name = GetString(SI_HOUSING_EDITOR_ALIGN),
            keybind = "HOUSING_EDITOR_ALIGN_TO_SURFACE",
            callback =  function()
                            local result = HousingEditorAlignSelectedPathNodeToSurface()
                            ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                        end,
            order = 50,
        }

        --Surface Drag Toggle
        local nodePlacementSurfaceDragDescriptor =
        {
            name = function()
                        if HousingEditorIsSurfaceDragModeEnabled() then 
                            return GetString(SI_HOUSING_EDITOR_SURFACE_DRAG_OFF)
                        else
                            return GetString(SI_HOUSING_EDITOR_SURFACE_DRAG_ON)
                        end
                    end,
            keybind = "HOUSING_EDITOR_QUATERNARY_ACTION",
            callback = function() 
                            HousingEditorToggleSurfaceDragMode()
                            self:UpdateKeybinds()
                        end,
            order = 40,
        }

        -- Negative (Cancel placement)
        local nodePlacementCancelDescriptor =
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = GetString(SI_HOUSING_EDITOR_CANCEL),
            keybind = "HOUSING_EDITOR_NEGATIVE_ACTION",
            visible = function()
                            return not HousingEditorIsPlacingNewNode()
                        end,
            callback = function()
                            local result = HousingEditorReleaseSelectedPathNode()
                            ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                            self:UpdateKeybinds()
                        end,
            order = 30,
        }

        --Yaw Right
        local nodePlacementYawRightDescriptor =
        {
            --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
            name = "Node Yaw Right",
            keybind = "HOUSING_EDITOR_YAW_RIGHT",
            ethereal = true,
            handlesKeyUp = true,
            callback =  function(isUp)
                            PlacementCallback(ROTATE_YAW_RIGHT, isUp)
                        end,
        }

        --Yaw Left
        local nodePlacementYawLeftDescriptor =
        {
            --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
            name = "Node Yaw Left",
            keybind = "HOUSING_EDITOR_YAW_LEFT",
            ethereal = true,
            handlesKeyUp = true,
            callback =  function(isUp)
                            PlacementCallback(ROTATE_YAW_LEFT, isUp)
                        end,
        }

        self.nodePlacementModeKeybindStripDescriptor =
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,

            nodePlacementRemoveNodeDescriptor,
            keyboardNodePlacementNodeSpeedDescriptor,
            keyboardNodePlacementNodeDelayDescriptor,
            nodePlacementAlignDescriptor,
            nodePlacementSurfaceDragDescriptor,
            nodePlacementCancelDescriptor,
            nodePlacementYawRightDescriptor,
            nodePlacementYawLeftDescriptor
        }

        self.nodePlacementModeKeybindStripGamepadDescriptor =
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,

            nodePlacementRemoveNodeDescriptor,
            gamepadNodePlacementNodeSpeedDescriptor,
            gamepadNodePlacementNodeDelayDescriptor,
            nodePlacementAlignDescriptor,
            nodePlacementCancelDescriptor,
            nodePlacementYawRightDescriptor,
            nodePlacementYawLeftDescriptor
        }

        self.UIModeKeybindStripDescriptor =
        {
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Housing Editor Exit UI Mode",
                keybind = "HOUSING_EDITOR_TERTIARY_ACTION",
                ethereal = true,
                callback = function()
                                if not IsInGamepadPreferredMode() then
                                    SCENE_MANAGER:OnToggleHUDUIBinding()
                                end
                            end,
            },
        }

        --Push/Pull Visible (for when surface drag is off)
        self.pushAndPullVisibleKeybindGroup =
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,
            {
            
                name = GetString(SI_HOUSING_EDITOR_PUSH_FORWARD),
                keybind = "HOUSING_EDITOR_PUSH_FORWARD",
                visible = function() return not HousingEditorIsSurfaceDragModeEnabled() end,
                handlesKeyUp = true,
                callback =  function(isUp)
                                if IsInGamepadPreferredMode() then
                                    PlacementCallback(PUSH_FORWARD, isUp)
                                else
                                    HousingEditorPushSelectedObject(self.pushSpeedPerSecond * GetFrameDeltaTimeSeconds()) --mousewheel doesn't need the update loop
                                end
                            end,
                order = 70,
            },
            {
                name = GetString(SI_HOUSING_EDITOR_PUSH_BACKWARD),
                keybind = "HOUSING_EDITOR_PULL_BACKWARD",
                visible = function() return not HousingEditorIsSurfaceDragModeEnabled() end,
                handlesKeyUp = true,
                callback =  function(isUp)
                                if IsInGamepadPreferredMode() then
                                    PlacementCallback(PULL_BACKWARD, isUp)
                                else
                                    HousingEditorPushSelectedObject(-self.pushSpeedPerSecond * GetFrameDeltaTimeSeconds()) --mousewheel doesn't need the update loop
                                end
                            end,
                order = 80,
            }
        }

        --Push/Pull ethereal (for when surface drag is on, we still want to consume input so the camera doesn't move)
        self.pushAndPullEtherealKeybindGroup =
        {
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Push Forward",
                keybind = "HOUSING_EDITOR_PUSH_FORWARD",
                ethereal = true,
                handlesKeyUp = true,
                callback =  function(isUp)
                                if IsInGamepadPreferredMode() then
                                    PlacementCallback(PUSH_FORWARD, isUp)
                                else
                                    HousingEditorPushSelectedObject(self.pushSpeedPerSecond * GetFrameDeltaTimeSeconds()) --mousewheel doesn't need the update loop
                                end
                            end,
            },
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Furniture Pull Backward",
                keybind = "HOUSING_EDITOR_PULL_BACKWARD",
                ethereal = true,
                handlesKeyUp = true,
                callback =  function(isUp)
                                if IsInGamepadPreferredMode() then
                                    PlacementCallback(PULL_BACKWARD, isUp)
                                else
                                    HousingEditorPushSelectedObject(-self.pushSpeedPerSecond * GetFrameDeltaTimeSeconds()) --mousewheel doesn't need the update loop
                                end
                            end,
            }
        }
    end

    function ZO_HousingEditorHud:GetKeybindStripDescriptorForMode(mode)
        if mode == HOUSING_EDITOR_MODE_SELECTION then
            if IsInGamepadPreferredMode() then
                return self.selectionModeKeybindStripDescriptor, self.selectionModeKeybindPaletteGamepadDescriptor
            else
                return self.selectionModeKeybindStripDescriptor, self.selectionModeKeybindPaletteDescriptor
            end
        elseif mode == HOUSING_EDITOR_MODE_PLACEMENT then
            if self:IsPrecisionEditingEnabled() then
                if self:IsPrecisionPlacementRotationMode() then
                    return self.precisionRotatePlacementModeKeybindStripDescriptor, self.precisionRotatePlacementModeKeybindPaletteDescriptor
                else
                    return self.precisionMovePlacementModeKeybindStripDescriptor, self.precisionMovePlacementModeKeybindPaletteDescriptor
                end
            else
                return self.placementModeKeybindStripDescriptor, self.placementModeKeybindPaletteDescriptor
            end
        elseif mode == HOUSING_EDITOR_MODE_LINK then
            return self.linkModeKeybindStripDescriptor, self.linkModeKeybindPaletteDescriptor
        elseif mode == HOUSING_EDITOR_MODE_PATH then
            if IsInGamepadPreferredMode() then
                return self.pathModeKeybindStripGamepadDescriptor, self.pathModeKeybindPaletteGamepadDescriptor
            else
                return self.pathModeKeybindStripDescriptor, self.pathModeKeybindPaletteDescriptor
            end
        elseif mode == HOUSING_EDITOR_MODE_NODE_PLACEMENT then
            if self:IsPrecisionEditingEnabled() then
                if self:IsPrecisionPlacementRotationMode() then
                    return self.precisionRotatePlacementModeKeybindStripDescriptor, self.precisionRotatePlacementModeKeybindPaletteDescriptor
                else
                    return self.precisionMovePlacementModeKeybindStripDescriptor, self.precisionMovePlacementModeKeybindPaletteDescriptor
                end
            else
                if IsInGamepadPreferredMode() then
                    return self.nodePlacementModeKeybindStripGamepadDescriptor, self.nodePlacementModeKeybindPaletteDescriptor
                else
                    return self.nodePlacementModeKeybindStripDescriptor, self.nodePlacementModeKeybindPaletteDescriptor
                end
            end
        end
    end

    function ZO_HousingEditorHud:GetAxisDelta(axis)
        local direction = 0
        local rotation = 0
        local movementController
        
        if axis == AXIS_TYPE_X then
            movementController = self.pitchMovementController
        elseif axis == AXIS_TYPE_Y then
            movementController = self.yawMovementController
        elseif axis == AXIS_TYPE_Z then
            movementController = self.rollMovementController
        end

        local movement = movementController:CheckMovement()

        if movement == MOVEMENT_CONTROLLER_MOVE_NEXT then
            direction = 1
        elseif movement == MOVEMENT_CONTROLLER_MOVE_PREVIOUS then
            direction = -1
        end

        if self:IsPrecisionEditingEnabled() then
            rotation = 1
        else
            -- If the movement controller is firing at max speed, switch from frame based incrementing to time based (might base this off a button press in the future).
            if movementController:IsAtMaxVelocity() then
                rotation = self.rotationStep * GetFrameDeltaNormalizedForTargetFramerate()
                direction = self:GetButtonDirection(axis) * -1
            else
                rotation = self.rotationStep
            end
        end

        return rotation * direction
    end

    function ZO_HousingEditorHud:OnUpdate()
        if IsInHousingEditorPlacementMode() then
            self:UpdateAxisIndicators()

            local x = self:GetAxisDelta(AXIS_TYPE_X)
            local y = self:GetAxisDelta(AXIS_TYPE_Y)
            local z = self:GetAxisDelta(AXIS_TYPE_Z)
            local active = false

            if self:IsPrecisionEditingEnabled() then
                if self:IsPrecisionPlacementRotationMode() then
                    if x ~= 0 then
                        HousingEditorRotateSelectedObject(AXIS_TYPE_X, x)
                        active = true
                    end
                    if y ~= 0 then
                        HousingEditorRotateSelectedObject(AXIS_TYPE_Y, y)
                        active = true
                    end
                    if z ~= 0 then
                        HousingEditorRotateSelectedObject(AXIS_TYPE_Z, z)
                        active = true
                    end
                else
                    local result = HOUSING_REQUEST_RESULT_SUCCESS
                    if x ~= 0 then
                        result = HousingEditorMoveSelectedObject(AXIS_TYPE_X, x)
                        active = true
                    end
                    if y ~= 0 then
                        result = HousingEditorMoveSelectedObject(AXIS_TYPE_Y, y)
                        active = true
                    end
                    if z ~= 0 then
                        result = HousingEditorMoveSelectedObject(AXIS_TYPE_Z, z)
                        active = true
                    end
                    ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)
                end
            else
                if x ~= 0 then
                    HousingEditorRotateSelectedObject(AXIS_TYPE_X, x)
                    active = true
                end
                if y ~= 0 then
                    HousingEditorRotateSelectedObject(AXIS_TYPE_Y, y)
                    active = true
                end
                if z ~= 0 then
                    HousingEditorRotateSelectedObject(AXIS_TYPE_Z, z)
                    active = true
                end
            end
                
            if self.placementKeyPresses[PUSH_FORWARD] then
                HousingEditorPushSelectedObject(self.pushSpeedPerSecond * GetFrameDeltaTimeSeconds())
                active = true
            end

            if self.placementKeyPresses[PULL_BACKWARD] then
                HousingEditorPushSelectedObject(-self.pushSpeedPerSecond * GetFrameDeltaTimeSeconds())
                active = true
            end

            if active then
                self:SetKeybindPaletteHidden(true)
            else
                EVENT_MANAGER:RegisterForUpdate("ZO_HousingEditorHud_ShowKeybindPalette", 200, function() self:SetKeybindPaletteHidden(false) end)
            end

            self:RefreshPlacementKeyPresses()
        end
    end
end

function ZO_HousingEditorHud:GetPathNodeInfo(furnitureId, nodeIndex)
    local worldX, worldY, worldZ = HousingEditorGetPathNodeWorldPosition(furnitureId, nodeIndex)
    local pitch, yaw, roll = HousingEditorGetPathNodeOrientation(furnitureId, nodeIndex)
    local speed = HousingEditorPathNodeSpeed(furnitureId, nodeIndex)
    local delayMS = HousingEditorPathNodeDelayTime(furnitureId, nodeIndex)
    return worldX, worldY, worldZ, yaw, speed, delayMS
end

function ZO_HousingEditorHud:CleanDirty()
    if self.isDirty then
        self.isDirty = false
        self:SetupHousingEditorHudScene()
    end
end

function ZO_HousingEditorHud:SetupHousingEditorHudScene()
    if IsInGamepadPreferredMode() then
        HOUSING_EDITOR_HUD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_KEYBIND_STRIP_GROUP)
        HOUSING_EDITOR_HUD_SCENE:RemoveFragmentGroup(FRAGMENT_GROUP.KEYBOARD_KEYBIND_STRIP_GROUP)

        HOUSING_EDITOR_HUD_UI_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
        HOUSING_EDITOR_HUD_UI_SCENE:RemoveFragment(KEYBIND_STRIP_FADE_FRAGMENT)
    else
        HOUSING_EDITOR_HUD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.KEYBOARD_KEYBIND_STRIP_GROUP)
        HOUSING_EDITOR_HUD_SCENE:RemoveFragmentGroup(FRAGMENT_GROUP.GAMEPAD_KEYBIND_STRIP_GROUP)

        HOUSING_EDITOR_HUD_UI_SCENE:AddFragment(KEYBIND_STRIP_FADE_FRAGMENT)
        HOUSING_EDITOR_HUD_UI_SCENE:RemoveFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
    end
end

do
    local function UpdateRotationButtonsForList(buttons, newMode)
        for k, buttonData in ipairs(buttons) do
            if buttonData.enabledFunction then
                local desaturateAmount = buttonData.enabledFunction(newMode) and 0 or 1
                buttonData:GetNamedChild("Icon"):SetDesaturation(desaturateAmount)
            end
        end
    end

    function ZO_HousingEditorHud:UpdateRotationButtonVisuals(newMode)
        UpdateRotationButtonsForList(self.pickupRotateHudButtons, newMode)
        UpdateRotationButtonsForList(self.precisionRotateHudButtons, newMode)
    end
end

-----------------------------
--Housing Editor History 
-----------------------------

local MAX_COMMANDS_SHOWN = 6
ZO_HOUSING_EDITOR_HISTORY_ENTRY_DIMENSION_KEYBOARD_X = 290
ZO_HOUSING_EDITOR_HISTORY_ENTRY_DIMENSION_KEYBOARD_Y = 50
ZO_HOUSING_EDITOR_HISTORY_ENTRY_DIMENSION_GAMEPAD_X = 315
ZO_HOUSING_EDITOR_HISTORY_ENTRY_DIMENSION_GAMEPAD_Y = 58
ZO_HOUSING_EDITOR_HISTORY_CONTAINER_DIMENSION_X = ZO_HOUSING_EDITOR_HISTORY_ENTRY_DIMENSION_GAMEPAD_X
ZO_HOUSING_EDITOR_HISTORY_CONTAINER_DIMENSION_Y = ZO_HOUSING_EDITOR_HISTORY_ENTRY_DIMENSION_GAMEPAD_Y * MAX_COMMANDS_SHOWN

ZO_HousingEditorHistory = ZO_Object:Subclass()

function ZO_HousingEditorHistory:New(...)
    local undoStack = ZO_Object.New(self)
    undoStack:Initialize(...)
    return undoStack
end

function ZO_HousingEditorHistory:Initialize(control)
    self.control = control
    self.entryContainer = control:GetNamedChild("Container")
    self.historyTitle = control:GetNamedChild("Header")

    self:SetDefaultIndicies()

    ZO_HOUSING_EDITOR_HISTORY_FRAGMENT = ZO_FadeSceneFragment:New(control)

    ZO_HOUSING_EDITOR_HISTORY_FRAGMENT:RegisterCallback("StateChange",  function(oldState, newState)
        if newState == SCENE_SHOWING then
            self:UpdateUndoStack()
        end
    end)

    self.historyEntryPool = ZO_ControlPool:New("ZO_HousingEditorHistory_Entry", self.entryContainer)
    self.recentUndoStackControls = {}

    local function OnUndoRedoCommand()
        self:UpdateUndoStack()
    end

    control:RegisterForEvent(EVENT_HOUSING_EDITOR_COMMAND_RESULT, OnUndoRedoCommand)

    ZO_PlatformStyle:New(function() self:ApplyPlatformStyle() end)

    -- Make sure title is setup properly
    self:ApplyPlatformStyle()
end

function ZO_HousingEditorHistory:UpdateUndoStack()
    self.historyEntryPool:ReleaseAllObjects()
    ZO_ClearNumericallyIndexedTable(self.recentUndoStackControls)

    local numCommands = GetNumHousingEditorHistoryCommands()
    local currentCommandIndex = GetCurrentHousingEditorHistoryCommandIndex()

    if self.numCommands ~= numCommands then
        self:SetDefaultIndicies()
    else
        local commandDirection = currentCommandIndex - self.lastCommandIndex
        if commandDirection < 0 and currentCommandIndex == self.endingIndex + (MAX_COMMANDS_SHOWN / 2) then
            self:SetContrainedEndingIndex(self.endingIndex - 1)
            if self.startingIndex - self.endingIndex > MAX_COMMANDS_SHOWN then
                self:SetContrainedStartingIndex(self.startingIndex - 1)
            end
        elseif commandDirection > 0 and currentCommandIndex == self.startingIndex  then
            self:SetContrainedStartingIndex(self.startingIndex + 1)
            if self.startingIndex - self.endingIndex > MAX_COMMANDS_SHOWN then
                self:SetContrainedEndingIndex(self.endingIndex + 1)
            end
        end
    end

    local currentCommandControl
    local nextIndex = self.endingIndex
    local lastIndex = self.startingIndex
    local offsetY = 0

    while nextIndex < lastIndex do
        local commandType, name, icon = GetHousingEditorHistoryCommandInfo(nextIndex)
        if commandType ~= HOUSING_EDITOR_COMMAND_TYPE_NONE then
            local isEntryActive = false
            local historyEntry = self.historyEntryPool:AcquireObject()
            ApplyTemplateToControl(historyEntry, ZO_GetPlatformTemplate("ZO_HousingEditorHistory_Entry"))
            table.insert(self.recentUndoStackControls, historyEntry)
            historyEntry:SetAnchor(TOPRIGHT, self.entryContainer, TOPRIGHT, 0, offsetY)
            historyEntry.label:SetText(zo_strformat(SI_HOUSE_HISTORY_COMMAND_FORMATTER, GetString("SI_HOUSINGEDITORCOMMANDTYPE", commandType), name))
            historyEntry.icon:SetTexture(icon)
            if nextIndex + 1 == currentCommandIndex then
                currentCommandControl = historyEntry
                isEntryActive = true
            elseif currentCommandIndex > nextIndex then
                isEntryActive = true
            end

            if isEntryActive then
                historyEntry.label:SetColor(ZO_SELECTED_TEXT:UnpackRGB())
                historyEntry.icon:SetDesaturation(0)
            else
                historyEntry.label:SetColor(ZO_DISABLED_TEXT:UnpackRGB())
                historyEntry.icon:SetDesaturation(1)
            end
            historyEntry.backgroundHighlight:SetHidden(true)
            offsetY = offsetY + historyEntry:GetHeight()
        end

        nextIndex = nextIndex + 1
    end

    if currentCommandControl then
        currentCommandControl.backgroundHighlight:SetHidden(false)
    end

    self.historyTitle:SetHidden(numCommands == 0)

    self.lastCommandIndex = currentCommandIndex
end

function ZO_HousingEditorHistory:SetDefaultIndicies()
    self.numCommands = GetNumHousingEditorHistoryCommands()
    self.lastCommandIndex = GetCurrentHousingEditorHistoryCommandIndex()
    self:SetContrainedStartingIndex(self.lastCommandIndex + 2)
    self:SetContrainedEndingIndex(self.startingIndex - MAX_COMMANDS_SHOWN)
end

function ZO_HousingEditorHistory:SetContrainedStartingIndex(newIndex)
    self.startingIndex = newIndex

    local totalCommands = GetNumHousingEditorHistoryCommands()
    if self.startingIndex > totalCommands then
        self.startingIndex = totalCommands
    end
end

function ZO_HousingEditorHistory:SetContrainedEndingIndex(newIndex)
    self.endingIndex = newIndex
    
    if self.endingIndex < 0 then
        self.endingIndex = 0
    end
end

function ZO_HousingEditorHistory:ApplyPlatformStyle()
    for i,control in ipairs(self.recentUndoStackControls) do
        ApplyTemplateToControl(control, ZO_GetPlatformTemplate("ZO_HousingEditorHistory_Entry"))
        control:ClearAnchors()
        control:SetAnchor(TOPRIGHT, self.entryContainer, TOPRIGHT, 0, control:GetHeight() * (i - 1))
    end

    self.historyTitle:SetFont(IsInGamepadPreferredMode() and "ZoFontGamepadBold34" or "ZoFontWinH2")
end

---------------------------------
-- Housing Editor Keybind Palette
---------------------------------

ZO_HousingEditorKeybindPalette = ZO_Object:Subclass()

function ZO_HousingEditorKeybindPalette:New(...)
    local instance = ZO_Object.New(self)
    instance:Initialize(...)
    return instance
end

function ZO_HousingEditorKeybindPalette:Initialize(control)
    self.control = control
    self.targetName = self.control:GetNamedChild("TargetName")

    self.numActiveKeybindButtons = 0
    self.keybindButtons = {}
    self:InitializePlatformStyle()

    local ALWAYS_ANIMATE = true
    local ANIMATION_DURATION_MS = 250
    HOUSING_EDITOR_KEYBIND_PALETTE_FRAGMENT = ZO_FadeSceneFragment:New(self.control, ALWAYS_ANIMATE, ANIMATION_DURATION_MS)
end

do
    local KEYBOARD_PLATFORM_STYLE =
    {
        targetNameFont = "ZoInteractionPrompt",
        keybindButtonTemplate = "ZO_KeybindButton_Keyboard_Template",
    }

    local GAMEPAD_PLATFORM_STYLE =
    {
        targetNameFont = "ZoFontGamepad42",
        keybindButtonTemplate = "ZO_KeybindButton_Gamepad_Template",
    }

    function ZO_HousingEditorKeybindPalette:InitializePlatformStyle()
        local function ApplyPlatformStyle(style)
            self:ApplyPlatformStyle(style)
        end

        self.platformStyle = ZO_PlatformStyle:New(ApplyPlatformStyle, KEYBOARD_PLATFORM_STYLE, GAMEPAD_PLATFORM_STYLE)
    end
end

function ZO_HousingEditorKeybindPalette:ApplyPlatformStyle(style)
    style = style or self.currentPlatformStyle
    self.currentPlatformStyle = style
    self.targetName:SetFont(style.targetNameFont)

    local previousKeybindButton
    for keybindButtonIndex, keybindButton in ipairs(self.keybindButtons) do
        ApplyTemplateToControl(keybindButton, style.keybindButtonTemplate)

        keybindButton:ClearAnchors()
        if previousKeybindButton then
            keybindButton:SetAnchor(TOPLEFT, previousKeybindButton, BOTTOMLEFT, nil, 10)
        else
            keybindButton:SetAnchor(TOPLEFT, self.targetName, BOTTOMLEFT, 80, 10)
        end

        previousKeybindButton = keybindButton
    end
end

function ZO_HousingEditorKeybindPalette:CreateKeybindButton()
    -- ZO_KeybindButtonTemplate_Setup registers a global reference to each keybind control, even if the control was previously registered.
    -- For this reason, we only create keybind button controls but we never call ZO_KeybindButtonTemplate_Setup for a control after its initial creation.

    local keybindButtonIndex = #self.keybindButtons + 1
    local controlName = string.format("%sKeybindButton%d", self.control:GetName(), keybindButtonIndex)
    local keybindButton = CreateControlFromVirtual(controlName, self.control, "ZO_KeybindButton_LabelAligned")
    table.insert(self.keybindButtons, keybindButton)

    local NO_KEYBIND = nil
    local NO_CALLBACK = nil
    local NO_LABEL = nil
    ZO_KeybindButtonTemplate_Setup(keybindButton, NO_KEYBIND, NO_CALLBACK, NO_LABEL)

    return keybindButton
end

function ZO_HousingEditorKeybindPalette:GetOrCreateKeybindButton()
    local keybindButtonIndex = self.numActiveKeybindButtons + 1
    self.numActiveKeybindButtons = keybindButtonIndex

    local keybindButton = self.keybindButtons[keybindButtonIndex] or self:CreateKeybindButton()
    return keybindButton
end

do
    local function EvaluateLiteralOrFunction(expression, ...)
        if type(expression) == "function" then
            return expression(...)
        end
        return expression
    end

    local function EvaluateLiteralOrFunctionWithDefault(expression, default, ...)
        local result = EvaluateLiteralOrFunction(expression, ...)
        if result == nil then
            return default
        end
        return result
    end

    local function CompareKeybindOrder(left, right)
        if left.order and right.order then
            return left.order < right.order
        elseif left.order then
            return true
        end
        return false
    end

    function ZO_HousingEditorKeybindPalette:AddKeybinds(descriptors)
        self:RemoveKeybinds()
        self.keybindDescriptors = descriptors

        if self.keybindDescriptors then
            local numKeybindButtons = #self.keybindButtons

            if not self.keybindDescriptors.sorted then
                table.sort(self.keybindDescriptors, CompareKeybindOrder)
                self.keybindDescriptors.sorted = true
            end

            for keybindDescriptorIndex, keybindDescriptor in ipairs(self.keybindDescriptors) do
                local DEFAULT_VISIBLE = true
                local isVisible = EvaluateLiteralOrFunctionWithDefault(keybindDescriptor.visible, DEFAULT_VISIBLE, keybindDescriptor)
                if isVisible then
                    local keybindButton = self:GetOrCreateKeybindButton()
                    keybindButton:SetHidden(false)
                    keybindButton:ShowKeyIcon()
                    keybindButton:SetKeybindButtonDescriptor(keybindDescriptor)

                    local DEFAULT_ENABLED = true
                    local isEnabled = EvaluateLiteralOrFunctionWithDefault(keybindDescriptor.enabled, DEFAULT_ENABLED, keybindDescriptor)
                    keybindButton:SetEnabled(isEnabled)
                    keybindButton:SetKeybindEnabled(isEnabled)
                end
            end

            if self.numActiveKeybindButtons > numKeybindButtons then
                -- New keybind button controls have been added. Apply the current platform style to them.
                self:ApplyPlatformStyle()
            end

            KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindDescriptors)
        end
    end
end

function ZO_HousingEditorKeybindPalette:RemoveKeybinds()
    if self.keybindDescriptors then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindDescriptors)
    end

    for keybindButtonIndex, keybindButton in ipairs(self.keybindButtons) do
        if keybindButtonIndex > self.numActiveKeybindButtons then
            break
        end

        keybindButton:HideKeyIcon()
        keybindButton:SetHidden(true)
    end

    self.keybindDescriptors = nil
    self.numActiveKeybindButtons = 0
end

function ZO_HousingEditorKeybindPalette:RefreshKeybinds()
    self:AddKeybinds(self.keybindDescriptors)
end

function ZO_HousingEditorKeybindPalette:SetTargetData(furnitureId, pathIndex)
    local itemName, icon, furnitureDataId = GetPlacedHousingFurnitureInfo(furnitureId)
    if pathIndex then
        itemName = zo_strformat(SI_HOUSING_EDITOR_PATH_NODE_NAME, pathIndex, itemName or "")
    elseif itemName then
        itemName = zo_strformat(SI_HOUSING_FURNITURE_NAME_FORMAT, itemName)
    else
        itemName = ""
    end

    self.targetFurnitureId = furnitureId
    self.targetFurniturePathIndex = pathIndex
    self.targetFurnitureName = itemName
    self.targetName:SetText(self.targetFurnitureName)
    self:RefreshKeybinds()
end

--[[ Globals ]]--

function ZO_HousingEditorActionBar_OnInitialize(control)
    HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_DISABLED) -- Disable if someone reloads ui from editor mode.
    HOUSING_EDITOR_SHARED = ZO_HousingEditorHud:New(control)
end

function ZO_HousingHUDFragmentTopLevel_Initialize(control)
    HOUSING_HUD_FRAGMENT = HousingHUDFragment:New(control)
end

function ZO_HousingEditorKeybindPalette_Initialize(control)
    HOUSING_EDITOR_KEYBIND_PALETTE = ZO_HousingEditorKeybindPalette:New(control)
end

function ZO_HousingEditorHistory_Initialize(control)
    HOUSING_EDITOR_UNDO_STACK = ZO_HousingEditorHistory:New(control)
end

function ZO_HousingEditorHistory_Entry_OnInitialized(control)
    control.icon = control:GetNamedChild("Icon")
    control.label = control:GetNamedChild("Label")
    control.background = control:GetNamedChild("Bg")
    control.backgroundHighlight = control:GetNamedChild("Highlight")
end
