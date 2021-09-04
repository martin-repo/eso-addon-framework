--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

function ZO_Pregame_CanSkipVideos()
    return GetCVar("HasPlayedPregameVideo") ~= "0" or ZO_IsConsoleOrHeronUI()
end

function ZO_Pregame_ShouldSkipVideos()
    -- only skip if the cvar is set, _and_ the player has seen the videos at least once
    return GetCVar("SkipPregameVideos") ~= "0" and ZO_Pregame_CanSkipVideos()
end

ZO_PREGAME_CHARACTER_COUNT = 0
ZO_PREGAME_FIRED_CHARACTER_CONSTRUCTION_READY = false
ZO_PREGAME_CHARACTER_LIST_RECEIVED = false
ZO_PREGAME_HAD_GLOBAL_ERROR = false

local QUEUE_VIDEO = false

local g_currentStateName = nil
local g_currentStateData = nil
local g_previousState = nil

local g_loadingUpdates = false

-- We don't want to show the video or the chapter upsell when we're logging out, only when we're logging in
local shouldTryToPlayOpeningCinematic = false
local shouldTryToShowChapterInterstitial = false

function Pregame_ShowScene(sceneName)
    SCENE_MANAGER:Show(sceneName)
    ZO_Dialogs_ReleaseAllDialogsExcept("HANDLE_ERROR", "HANDLE_ERROR_WITH_HELP")
end

function AttemptQuickLaunch()
    if GetCVar("QuickLaunch") == "1" then
        local acctName = GetCVar("AccountName")
        local acctPwd = GetCVar("AccountPassword")

        if acctName ~= "" and acctPwd ~= "" then
            PregameLogin(acctName, acctPwd)
        end
    end
end

function AttemptToFireCharacterConstructionReady()
    if not ZO_PREGAME_FIRED_CHARACTER_CONSTRUCTION_READY and IsPregameCharacterConstructionReady() and ZO_PREGAME_CHARACTER_LIST_RECEIVED then
        ZO_PREGAME_FIRED_CHARACTER_CONSTRUCTION_READY = true
        CALLBACK_MANAGER:FireCallbacks("OnCharacterConstructionReady")
    end
end

local function PlayIntroCinematicAndAdvance()
    SetVideoCancelAllOnCancelAny(true)
    local videoDataId = GetOpeningCinematicVideoDataId()
    ZO_PlayVideoAndAdvance(PlayVideoById, videoDataId, QUEUE_VIDEO, VIDEO_SKIP_MODE_REQUIRE_CONFIRMATION_FOR_SKIP)
end

function ZO_PlayIntroCinematicAndReturn()
    SetVideoCancelAllOnCancelAny(true)
    local videoDataId = GetOpeningCinematicVideoDataId()
    ZO_PlayVideoAndReturn(PlayVideoById, videoDataId, QUEUE_VIDEO, VIDEO_SKIP_MODE_REQUIRE_CONFIRMATION_FOR_SKIP)
end

local g_sharedPregameStates =
{
    ["CharacterSelect_FromIngame"] =
    {
        OnEnter = function()
            -- Let the character list receipt determine the state to go to.
            RequestCharacterList()
        end,

        OnExit = function()
        end
    },

    ["PlayOpeningCinematic"] =
    {
        ShouldAdvance = function()
            return false
        end,

        OnEnter = function()
            PlayIntroCinematicAndAdvance()
            SCENE_MANAGER:ShowBaseScene()
        end,

        GetStateTransitionData = function()
            return "WaitForGameDataLoaded"
        end,

        OnExit = function()
        end,
    },

    ["WaitForGameDataLoaded"] =
    {
        ShouldAdvance = function()
            return IsSystemLoaded(LOADING_SYSTEM_GAME_DATA)
        end,

        OnEnter = function()
            SuppressWorldList()
            RegisterForLoadingUpdates()
            -- Make sure we aren't showing a scene here if we
            -- didn't show the cinematic before switching to this scene
            SCENE_MANAGER:ShowBaseScene()
        end,

        OnExit = function()
        end,

        GetStateTransitionData = function()
            return "ChapterUpgradeInterstitial"
        end
    },

    ["CharacterCreateFadeIn"] =
    {
        ShouldAdvance = function()
            return false
        end,

        OnEnter = function()
            ZO_CharacterCreate_FadeIn()
        end,

        GetStateTransitionData = function()
            return "CharacterCreate"
        end,

        OnExit = function()
        end,
    },

    ["CharacterCreate"] =
    {
        OnEnter = function()
            ZO_CHARACTERCREATE_MANAGER:SetCharacterMode(CHARACTER_MODE_CREATION)
            local characterCreate = SYSTEMS:GetObject(ZO_CHARACTER_CREATE_SYSTEM_NAME)
            characterCreate:Reset()
            characterCreate:InitializeForCharacterCreate()

            if IsInGamepadPreferredMode() then
                Pregame_ShowScene("gamepadCharacterCreate")
            else
                Pregame_ShowScene("gameMenuCharacterCreate")
                -- PEGI update currently only needs to be shown on PC
                if DoesPlatformRequirePregamePEGI() and not HasAgreedToPEGI() then
                    ZO_Dialogs_ShowDialog("PEGI_COUNTRY_SELECT")
                end
            end
        end,

        OnExit = function()
            ZO_Dialogs_ReleaseDialog("CHARACTER_CREATE_CREATING")
            SetCharacterCameraZoomAmount(-1) -- zoom all the way out when leaving this state
        end
    },

    ["CharacterCreate_Barbershop"] =
    {
        OnEnter = function()
            if IsInGamepadPreferredMode() then
                Pregame_ShowScene("gamepadCharacterCreate")
            else
                Pregame_ShowScene("gameMenuCharacterCreate")
            end
        end,

        OnExit = function()
            ZO_Dialogs_ReleaseDialog("CHARACTER_CREATE_CREATING")
            SetCharacterCameraZoomAmount(-1) -- zoom all the way out when leaving this state
        end
    },

    ["ChapterUpgrade"] =
    {
        ShouldAdvance = function()
            return false
        end,

        OnEnter = function()
            if IsInGamepadPreferredMode() then
                Pregame_ShowScene("chapterUpgradeGamepad")
            else
                Pregame_ShowScene("chapterUpgradeKeyboard")
            end
        end,

        GetStateTransitionData = function()
            return "CharacterSelect"
        end,

        OnExit = function()
        end,
    },

    ["ChapterUpgradeInterstitial"] =
    {
        ShouldAdvance = function()
            if not shouldTryToShowChapterInterstitial then
                return true
            end

            return not CHAPTER_UPGRADE_MANAGER:ShouldShow()
        end,

        OnEnter = function()
            if IsInGamepadPreferredMode() then
                Pregame_ShowScene("chapterUpgradeGamepad")
            else
                Pregame_ShowScene("chapterUpgradeKeyboard")
            end
        end,

        GetStateTransitionData = function()
            return "WaitForCharacterDataLoaded"
        end,

        OnExit = function()
        end,
    },

    ["WaitForCharacterDataLoaded"] =
    {
        ShouldAdvance = function()
            return IsPregameCharacterConstructionReady()
        end,

        OnEnter = function()
        end,

        GetStateTransitionData = function()
            if ZO_PREGAME_CHARACTER_COUNT > 0 then
                return "CharacterSelect"
            else
                return "CharacterCreateFadeIn"
            end
        end,

        OnExit = function()
        end,
    },

    ["BeginLoadingIntoWorld"] =
    {
        OnEnter = function()
            if IsInGamepadPreferredMode() then
                ZO_CharacterSelect_Gamepad_ShowLoginScreen()
            else
                SCENE_MANAGER:ShowBaseScene()
                ZO_Dialogs_ShowDialog("REQUESTING_CHARACTER_LOAD")
            end
        end,

        OnExit = function()
        end
    },

    ["ScreenAdjustIntro"] =
    {
        ShouldAdvance = function()
            return not IsConsoleUI() or GetCVar("PregameScreenAdjustEnabled") ~= "1"
        end,

        OnEnter = function()
            SCENE_MANAGER:Show("screenAdjust")
            SetCVar("PregameScreenAdjustEnabled", "false")
        end,

        OnExit = function()
        end,

        GetStateTransitionData = function()
            return "GammaAdjust"
        end,
    },

    ["GammaAdjust"] =
    {
        ShouldAdvance = function()
            return not ZO_GammaAdjust_NeedsFirstSetup()
        end,

        OnEnter = function()
            SCENE_MANAGER:Show("gammaAdjust")
        end,

        OnExit = function()
            SetCVar("PregameGammaCheckEnabled", "false")
        end,

        GetStateTransitionData = function()
            if IsInGamepadPreferredMode() or not DoesPlatformSelectServer() then
                return "ShowEULA"
            else
                return "ServerSelectIntro"
            end
        end,
    },

    ["PlayIntroMovies"] =
    {
        ShouldAdvance = function()
            return ZO_Pregame_ShouldSkipVideos()
        end,

        OnEnter = function()
            -- If you haven't played the videos, you can't skip them until they finish...
            local skipMode = ZO_Pregame_CanSkipVideos() and VIDEO_SKIP_MODE_ALLOW_SKIP or VIDEO_SKIP_MODE_NO_SKIP

            -- TODO: Determine if these videos need localization or subtitles...
            SetVideoCancelAllOnCancelAny(false)

            PlayVideo("Video/Bethesda_logo.bk2", QUEUE_VIDEO, skipMode)

            ZO_PlayVideoAndAdvance(PlayVideo, "Video/ZOS_logo.bk2", QUEUE_VIDEO, skipMode)
        end,

        GetStateTransitionData = function()
            return "ShowHavokSplashScreen"
        end,

        OnExit = function()
        end,
    },

    ["ShowLegalSplashScreen"] =
    {
        ShouldAdvance = function()
            return ZO_Pregame_ShouldSkipVideos()
        end,

        OnEnter = function()
            SCENE_MANAGER:Show("copyrightLogosSplash")
        end,

        GetStateTransitionData = function()
            return "AccountLoginEntryPoint"
        end,

        OnExit = function()
        end,
    },

    ["ShowHavokSplashScreen"] =
    {
        ShouldAdvance = function()
            return ZO_Pregame_ShouldSkipVideos()
        end,

        OnEnter = function()
            SimpleLogoSplash_ShowWithTexture("EsoUI/Art/Login/havok_logo.dds")
        end,

        GetStateTransitionData = function()
            return "ShowDMMVideo"
        end,

        OnExit = function()
        end,
    },

    ["ShowDMMVideo"] =
    {
        ShouldAdvance = function()
            local serviceType = GetPlatformServiceType()
            return serviceType ~= PLATFORM_SERVICE_TYPE_DMM or ZO_Pregame_ShouldSkipVideos()
        end,

        OnEnter = function()
            local skipMode = ZO_Pregame_CanSkipVideos() and VIDEO_SKIP_MODE_ALLOW_SKIP or VIDEO_SKIP_MODE_NO_SKIP
            ZO_PlayVideoAndAdvance(PlayVideo, "Video/jp_DMM_logo.bk2", QUEUE_VIDEO, skipMode)
        end,

        GetStateTransitionData = function()
            -- The keyboard and gamepad flows begin to diverge here
            return "ShowLegalSplashScreen"
        end,

        OnExit = function()
        end,
    },

    ["Disconnect"] =
    {
        OnEnter = function()
            SetCVar("QuickLaunch", "0")
            PregameDisconnect()
        end,

        OnExit = function ()
        end,
    }
}

local g_keyboardPregameStates = {}
function PregameStateManager_AddKeyboardStates(externalStates)
    for key, value in pairs(externalStates) do
        g_keyboardPregameStates[key] = value
    end
end

local g_gamepadPregameStates = {}
function PregameStateManager_AddGamepadStates(externalStates)
    for key, value in pairs(externalStates) do
        g_gamepadPregameStates[key] = value
    end
end

function PregameStateManager_GetState(stateName)
    local state
    if IsInGamepadPreferredMode() then
        state = g_gamepadPregameStates[stateName]
    else
        state = g_keyboardPregameStates[stateName]
    end

    if not state then
        state = g_sharedPregameStates[stateName]
    end

    return state
end

function PregameStateManager_SetState(stateName, ...)
    local newPregameState = PregameStateManager_GetState(stateName)
    internalassert(newPregameState, "missing state for " .. stateName)
    local stateArgs = { ... }

    -- Because GetTransitionData returns the next state as the first argument, insert state name into this table.
    -- The actual arguments passed to OnEnter will be adjusted to account for it.
    table.insert(stateArgs, 1, stateName)

    if g_currentStateData then
        g_currentStateData.OnExit()
    end

    g_previousState = g_currentStateName

    local foundState = false
    while not foundState do
        g_currentStateName = stateName
        local shouldAdvance = (newPregameState.ShouldAdvance == nil) or newPregameState.ShouldAdvance()
        if shouldAdvance then
            if newPregameState and newPregameState.GetStateTransitionData then
                stateArgs = { newPregameState.GetStateTransitionData() }
                stateName = stateArgs[1]
                newPregameState = PregameStateManager_GetState(stateName)
                internalassert(newPregameState, "missing state for " .. stateName)
            else
                foundState = true
            end
        else
            foundState = true
        end
    end

    WriteToInterfaceLog(string.format("PregameStateManager_SetState - from: %s, to: %s", tostring(g_previousState), tostring(g_currentStateName)))
    g_currentStateData = newPregameState
    newPregameState.OnEnter(select(2, unpack(stateArgs)))
    CALLBACK_MANAGER:FireCallbacks("OnPregameEnterState", g_currentStateName)
end

function PregameStateManager_ReenterLoginState()
    if PregameStateManager_GetCurrentState() == "AccountLogin" then
        CALLBACK_MANAGER:FireCallbacks("OnPregameEnterState", "AccountLogin")
    else
        PregameStateManager_SetState("AccountLogin")
    end
end

function PregameStateManager_AdvanceState()
    local currentStateData = PregameStateManager_GetState(g_currentStateName)
    if currentStateData and currentStateData.GetStateTransitionData then
        PregameStateManager_SetState(currentStateData.GetStateTransitionData())
    else
        -- If there are no transition data, then we're not going anywhere...we'll be locked in the current state.
        -- Do not call this if you're not on a state with transition data
        internalassert(false, string.format("Non-advancable state: %s", tostring(g_currentStateName)))
    end
end

-- this will only advance the state if we are currently in the state passed in
function PregameStateManager_AdvanceStateFromState(state)
    if g_currentStateName == state then
        PregameStateManager_AdvanceState()
    end
end

function PregameStateManager_GetCurrentState()
    return g_currentStateName
end

function PregameStateManager_GetPreviousState()
    return g_previousState
end

local function OnCharacterListReceived(_, characterCount, maxCharacters, mostRecentlyPlayedCharacterId)
    ZO_PREGAME_CHARACTER_LIST_RECEIVED = true
    ZO_PREGAME_CHARACTER_COUNT = characterCount

    local isPlayingVideo = false

    if shouldTryToPlayOpeningCinematic then
        local openingCinematicSeen = GetCVar("OpeningCinematicSeen") == "1"

        if not openingCinematicSeen then
            SetCVar("OpeningCinematicSeen", 1)
            ZO_SavePlayerConsoleProfile()
            -- Play intro movie
            PregameStateManager_SetState("PlayOpeningCinematic")
            isPlayingVideo = true
        end
    end

    if not isPlayingVideo then
        -- Go to character create/select as necessary after we have our data
        -- If we are already at CharacterSelect when we get the character list, then we don't need to move
        -- This could happen when we rename or delete a character
        if PregameStateManager_GetCurrentState() ~= "CharacterSelect" then
            PregameStateManager_SetState("WaitForGameDataLoaded")
            -- If the data isn't fully loaded make sure we're registered for loading updates for things
            -- that depend on the "PregameFullyLoaded" callback.
            -- This can happen when we are returning to character select after being disconnected from the server
            if not PregameIsFullyLoaded() then
                RegisterForLoadingUpdates()
            end
        elseif characterCount == 0 then
            -- However, if we delete our last character then we need to switch to CharacterCreate
            -- so we can create a new character. We also want to avoid CharacterCreateFadeIn since
            -- that won't transition very nicely between CharacterSelect and CharacterCreate
            -- We are also assuming here that we already have character data since we were at character select
            PregameStateManager_SetState("CharacterCreate")
        end
    end

    -- if this hasn't been fired yet, then fire it (could have been a reload or coming from in-game)
    AttemptToFireCharacterConstructionReady()

    if DoesPlatformSupportDisablingShareFeatures() then
        -- re-enabled when the character list is loaded
        EnableShareFeatures()
    end
end

-- Debugging utility...you must be at character select already to use this.
local function SetupUIReloadAfterLogin()
    RequestCharacterList()

    return "CharacterSelect"
    -- Return an invalid state, allow the character list receipt to figure out what state to advance to
end

local initialStateOverrideFn --= SetupUIReloadAfterLogin -- normally this is nil, it can be set to a custom function to allow the reload to drop into a desired state

function UnregisterForLoadingUpdates()
    if g_loadingUpdates then
        EVENT_MANAGER:UnregisterForEvent("PregameStateManager", EVENT_AREA_LOAD_STARTED)
        EVENT_MANAGER:UnregisterForEvent("PregameStateManager", EVENT_SUBSYSTEM_LOAD_COMPLETE)
        EVENT_MANAGER:UnregisterForEvent("PregameStateManager", EVENT_LUA_ERROR)
        g_loadingUpdates = false
    end
end

local function OnAreaLoadStarted()
    ZO_Dialogs_ReleaseAllDialogs(true)
end

function IsPlayingChapterOpeningCinematic()
    return PregameStateManager_GetCurrentState() == "PlayOpeningCinematic"
end

function IsInCharacterSelectCinematicState()
    return PregameStateManager_GetCurrentState() == "CharacterSelect_PlayCinematic"
end

function IsInCharacterCreateState()
    return PregameStateManager_GetCurrentState() == "CharacterCreate"
end

local function OnCharacterSelected(_, characterId)
    PregameStateManager_SetState("BeginLoadingIntoWorld")
end

function PregameIsFullyLoaded()
    return GetNumLoadedSubsystems() == GetNumTotalSubsystemsToLoad()
end

function AttemptToAdvancePastChapterOpeningCinematic()
    if PregameIsFullyLoaded() then
        PregameStateManager_AdvanceStateFromState("PlayOpeningCinematic")
    end
end

function AttemptToAdvancePastCharacterSelectCinematic()
    if PregameIsFullyLoaded() then
        PregameStateManager_AdvanceStateFromState("CharacterSelect_PlayCinematic")
    end
end

local function OnSubsystemLoadComplete(_, subSystem)
    if subSystem == LOADING_SYSTEM_GAME_DATA or subSystem == LOADING_SYSTEM_SHARED_CHARACTER_OBJECT then
        AttemptToFireCharacterConstructionReady()
        -- LOADING_SYSTEM_GAME_DATA loads before LOADING_SYSTEM_SHARED_CHARACTER_OBJECT so if we hit either
        -- of those then the game data is loaded
        if subSystem == LOADING_SYSTEM_GAME_DATA then
            PregameStateManager_AdvanceStateFromState("WaitForGameDataLoaded")
        elseif subSystem == LOADING_SYSTEM_SHARED_CHARACTER_OBJECT then
            PregameStateManager_AdvanceStateFromState("WaitForCharacterDataLoaded")
        end
    end

    if PregameIsFullyLoaded() then
        if IsPlayingChapterOpeningCinematic() then
            AttemptToAdvancePastChapterOpeningCinematic()
        end

        CALLBACK_MANAGER:FireCallbacks("PregameFullyLoaded")
        UnregisterForLoadingUpdates()
    end
end

local function OnLuaErrorWhileLoading(_)
    -- Errors triggered during a loading screen will prevent some loading
    -- subsystems from completing, so the loading screen will never go away unless
    -- we do something. Let's immediately disconnect and bail back to the initial
    -- screen to handle this. We're calling lua code to handle errors in lua code,
    -- so we may still end up in the situation where our error recovery code never
    -- gets called, but the list of places where that could happen are very low;
    -- basically just this function.
    EVENT_MANAGER:UnregisterForEvent("PregameStateManager", EVENT_LUA_ERROR)
    ZO_PREGAME_HAD_GLOBAL_ERROR = true
    PregameDisconnectOnLuaError()
end

function RegisterForLoadingUpdates()
    if not g_loadingUpdates then
        EVENT_MANAGER:RegisterForEvent("PregameStateManager", EVENT_AREA_LOAD_STARTED, OnAreaLoadStarted)
        EVENT_MANAGER:RegisterForEvent("PregameStateManager", EVENT_SUBSYSTEM_LOAD_COMPLETE, OnSubsystemLoadComplete)
        EVENT_MANAGER:RegisterForEvent("PregameStateManager", EVENT_LUA_ERROR, OnLuaErrorWhileLoading)
        g_loadingUpdates = true
    end
end

local function OnShowPregameGuiInState(_, desiredState)
    SetGuiHidden("pregame", false)

    if initialStateOverrideFn then
        desiredState = initialStateOverrideFn()
    end

    if desiredState and desiredState ~= "" then
        PregameStateManager_SetState(desiredState, true)
    end
end

function PregameStateManager_PlayCharacter(charId, loadOption)
    if type(loadOption) == "string" then
        PregameStateManager_SetState(loadOption)
    else --We will need to revisit this once the tutorial gate is integrated into the build
        CALLBACK_MANAGER:FireCallbacks("OnCharacterLoadRequested")
        SelectCharacterForPlay(charId, loadOption)
    end
end

do
    local g_currentVideoPregameState = nil
    local function OnVideoPlaybackComplete()
        EVENT_MANAGER:UnregisterForEvent("ZO_PlayVideoAndAdvance", EVENT_VIDEO_PLAYBACK_COMPLETE)
        EVENT_MANAGER:UnregisterForEvent("ZO_PlayVideoAndAdvance", EVENT_VIDEO_PLAYBACK_ERROR)

        if not ZO_PREGAME_HAD_GLOBAL_ERROR then
            PregameStateManager_AdvanceStateFromState(g_currentVideoPregameState)
        end
    end

    function ZO_PlayVideoAndAdvance(playVideoFunction, ...)
        g_currentVideoPregameState = PregameStateManager_GetCurrentState()
        EVENT_MANAGER:RegisterForEvent("ZO_PlayVideoAndAdvance", EVENT_VIDEO_PLAYBACK_COMPLETE, OnVideoPlaybackComplete)
        EVENT_MANAGER:RegisterForEvent("ZO_PlayVideoAndAdvance", EVENT_VIDEO_PLAYBACK_ERROR, OnVideoPlaybackComplete)
        playVideoFunction(...)
    end
end

do
    local g_wasVideoStartedInGamepadPreferredMode = false
    local function OnVideoPlaybackComplete()
        EVENT_MANAGER:UnregisterForEvent("ZO_PlayVideoAndReturn", EVENT_VIDEO_PLAYBACK_COMPLETE)
        EVENT_MANAGER:UnregisterForEvent("ZO_PlayVideoAndReturn", EVENT_VIDEO_PLAYBACK_ERROR)

        if g_wasVideoStartedInGamepadPreferredMode ~= IsInGamepadPreferredMode() then
            -- The gamepad preferred mode changed event is supressed during while the video is playing, let's bring it back now
            ZO_Pregame_OnGamepadPreferredModeChanged()
        end
    end

    function ZO_PlayVideoAndReturn(playVideoFunction, ...)
        g_wasVideoStartedInGamepadPreferredMode = IsInGamepadPreferredMode()
        EVENT_MANAGER:RegisterForEvent("ZO_PlayVideoAndReturn", EVENT_VIDEO_PLAYBACK_COMPLETE, OnVideoPlaybackComplete)
        EVENT_MANAGER:RegisterForEvent("ZO_PlayVideoAndReturn", EVENT_VIDEO_PLAYBACK_ERROR, OnVideoPlaybackComplete)
        playVideoFunction(...)
    end
end

function PregameStateManager_ClearError()
    ZO_PREGAME_HAD_GLOBAL_ERROR = false
end

local function OnDisplayNameReady()
    shouldTryToPlayOpeningCinematic = true
    shouldTryToShowChapterInterstitial = true
end

function ZO_Pregame_DisplayServerDisconnectedError()
    if not IsErrorQueuedFromIngame() then
        return
    end

    local logoutError, globalErrorCode = GetErrorQueuedFromIngame()

    ZO_PREGAME_HAD_GLOBAL_ERROR = true

    local errorString
    local errorStringFormat

    if logoutError ~= LOGOUT_ERROR_NO_ERROR and logoutError ~= LOGOUT_ERROR_UNKNOWN_ERROR and logoutError ~= LOGOUT_ERROR_TRANSFER_FAILED then
        errorStringFormat = GetString("SI_LOGOUTERROR", logoutError)

        if errorStringFormat ~= ""  then
            errorString = zo_strformat(errorStringFormat, GetGameURL())
        end
    elseif globalErrorCode ~= GLOBAL_ERROR_CODE_NO_ERROR then
        -- if the error code is not in LogoutReason then it is probably in the GlobalErrorCode enum
        errorStringFormat = GetString("SI_GLOBALERRORCODE", globalErrorCode)

        if errorStringFormat ~= ""  then
            errorString = zo_strformat(errorStringFormat, globalErrorCode)
        end
    end

    if errorString == nil or errorString == "" then
        if IsInGamepadPreferredMode() then
            errorString = zo_strformat(SI_UNEXPECTED_ERROR, GetString(SI_HELP_URL))
        else
            errorString = GetString(SI_UNKNOWN_ERROR)
        end
    end

    local shouldReenterLoginState = true
    if logoutError == LOGOUT_ERROR_TRANSFER_FAILED then
        shouldReenterLoginState = false
    end

    if IsInGamepadPreferredMode() then
        if shouldReenterLoginState then
            -- Showing the error here also sets the state to AccountLogin
            PREGAME_INITIAL_SCREEN_GAMEPAD:ShowError(nil, errorString)
        end
    else
        if shouldReenterLoginState then
            PregameStateManager_ReenterLoginState()
        end

        ZO_Dialogs_ShowDialog("HANDLE_ERROR", nil, {mainTextParams = {errorString}})
    end
end

local function OnDisconnectedFromServer()
    ZO_Dialogs_ReleaseAllDialogsExcept("HANDLE_ERROR", "HANDLE_ERROR_WITH_HELP")

    ZO_Pregame_DisplayServerDisconnectedError()

    local NUM_FLASHES_BEFORE_SOLID = 7
    FlashTaskbarWindow("DISCONNECTED", NUM_FLASHES_BEFORE_SOLID)
end

local IS_WORLD_SELECT_STATE = ZO_CreateSetFromArguments("WorldSelect_Requested", "WorldSelect_ShowList", "WorldSelect")

function ZO_Pregame_OnGamepadPreferredModeChanged()
    local currentState = PregameStateManager_GetCurrentState()
    if currentState == nil then
        -- The initial state has not been set up yet, let's wait for that
        return
    end

    if IsAnyVideoPlaying() then
        -- Allow the video to finish. All states that play a video should be
        -- able to be used in either keyboard or gamepad flows, to properly
        -- shuffle the player on to the next state
        return
    end

    if currentState == "GammaAdjust" then
        -- switching between kb/gamepad will be handled by platform style
        -- TODO: for ingame scenes, we can use the
        -- SetHandleGamepadPreferredModeChangedCallback to preempt any UI mode
        -- switching. ideally we could do the same for pregame scenes, so we could
        -- share code between the two
        return
    end

    local FORCE_CLOSE = true
    ZO_Dialogs_ReleaseAllDialogs(FORCE_CLOSE)

    if not IsAccountLoggedIn() or IS_WORLD_SELECT_STATE[currentState] then -- While in world select, we're logged in but haven't yet started the character loading process
        PregameStateManager_SetState("AccountLoginEntryPoint")
    elseif not IsPregameCharacterConstructionReady() then
        PregameStateManager_SetState("WaitForCharacterDataLoaded")
    elseif PregameStateManager_GetCurrentState() == "CharacterCreate" or GetNumCharacters() == 0 then
        PregameStateManager_SetState("CharacterCreate")
    else
        local wasLoadingIntoWorld = PregameStateManager_GetCurrentState() == "BeginLoadingIntoWorld"
        MoveCameraToCurrentCharacter()
        PregameStateManager_SetState("CharacterSelect")
        if wasLoadingIntoWorld then
            -- pop up the loading dialog.
            -- this needs to happen as a transition from character select so the input-appropriate version of that scene is visible in the background
            PregameStateManager_SetState("BeginLoadingIntoWorld")
        end
    end
end

function ZO_RegisterForSavedVars(systemName, version, defaults, callback)
    local function OnReady()
        local savedVars = ZO_SavedVars:NewAccountWide("ZO_Pregame_SavedVariables", version, systemName, defaults)
        callback(savedVars)
    end

    local function OnAddonLoaded(_, name)
        if name == "ZO_Pregame" then
            EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_ADD_ON_LOADED)

            if IsAccountLoggedIn() then
                OnReady()
            end
        end
    end

    EVENT_MANAGER:RegisterForEvent(systemName, EVENT_ADD_ON_LOADED, OnAddonLoaded)
    -- Every time we log in, we need a new saved vars for that account
    EVENT_MANAGER:RegisterForEvent(systemName, EVENT_DISPLAY_NAME_READY, OnReady)
end

EVENT_MANAGER:RegisterForEvent("PregameStateManager", EVENT_DISPLAY_NAME_READY, OnDisplayNameReady)
EVENT_MANAGER:RegisterForEvent("PregameStateManager", EVENT_CHARACTER_LIST_RECEIVED, OnCharacterListReceived)
EVENT_MANAGER:RegisterForEvent("PregameStateManager", EVENT_SHOW_PREGAME_GUI_IN_STATE, OnShowPregameGuiInState)
EVENT_MANAGER:RegisterForEvent("PregameStateManager", EVENT_CHARACTER_SELECTED_FOR_PLAY, OnCharacterSelected)
EVENT_MANAGER:RegisterForEvent("PregameStateManager", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, ZO_Pregame_OnGamepadPreferredModeChanged)
EVENT_MANAGER:RegisterForEvent("PregameStateManager", EVENT_DISCONNECTED_FROM_SERVER, OnDisconnectedFromServer)
