--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

CHARACTER_OPTION_CLEAN_TEST_AREA = true
CHARACTER_OPTION_EXISTING_AREA = false

CHARACTER_CREATE_DEFAULT_LOCATION = 1
CHARACTER_CREATE_SKIP_TUTORIAL = 2

--[[
    MouseCursor Update Utility for Character Select/Create
--]]

local g_lastControl, g_lastSceneState

function ZO_UpdatePaperDollManipulationForScene(control, sceneState)
    g_lastControl, g_lastSceneState = control, sceneState
    local fullyLoaded = GetNumTotalSubsystemsToLoad() == GetNumLoadedSubsystems()

    if(not fullyLoaded or (sceneState == SCENE_HIDDEN)) then
        control:SetMouseEnabled(false)
        WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
    elseif(fullyLoaded and (sceneState == SCENE_SHOWN)) then
        control:SetMouseEnabled(true)

        local mouseIsOverControl = MouseIsOver(control)
        local currentMouseOverControl = WINDOW_MANAGER:GetMouseOverControl()
        local allowHandler = (currentMouseOverControl == control) or (currentMouseOverControl == GuiRoot)
        
        if(mouseIsOverControl and allowHandler) then
            control:GetHandler("OnMouseEnter")(control)
        end    
    end
end

local function OnPregameFullyLoaded()
    if(g_lastControl ~= nil and g_lastSceneState == SCENE_SHOWN) then
        ZO_UpdatePaperDollManipulationForScene(g_lastControl, g_lastSceneState)
    end
end

CALLBACK_MANAGER:RegisterCallback("PregameFullyLoaded", OnPregameFullyLoaded)

-- This allows us to make a the same function in InGame and Pregame while changing exactly what it calls,
-- so shared code doesn't need to know which state its in
function ZO_Disconnect()
    PregameStateManager_SetState("Disconnect")
end

function ZO_IsForceConsoleOrHeronFlow()
    if IsConsoleUI() or IsHeronUI() then
        return GetUIPlatform() == UI_PLATFORM_PC
    end
    return false
end

do
    internalassert(MEGASERVER_MAX_VALUE == 2, "update platform names")
    local LIVE_NA_PLATFORM_NAME = "Live"
    local LIVE_EU_PLATFORM_NAME = "Live-EU"

    function ZO_GetLocalizedServerName(platformName)
        if platformName == LIVE_NA_PLATFORM_NAME then
            platformName = GetString("SI_MEGASERVER", MEGASERVER_NA)
        elseif platformName == LIVE_EU_PLATFORM_NAME then
            platformName = GetString("SI_MEGASERVER", MEGASERVER_EU)
        end
        
        return platformName
    end
end

ZO_PREGAME_EULAS = {
    EULA_TYPE_PREGAME_EULA,
    EULA_TYPE_TERMS_OF_SERVICE,
    EULA_TYPE_PRIVACY_POLICY,
    EULA_TYPE_CODE_OF_CONDUCT,
    EULA_TYPE_NON_DISCLOSURE_AGREEMENT,
}
