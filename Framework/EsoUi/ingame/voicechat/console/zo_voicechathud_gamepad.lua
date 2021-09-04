--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

--------------------------------------------------------------------------------
-- VoiceChat HUD Gamepad
--  In-game version of the Voice Chat HUD.
--------------------------------------------------------------------------------

ZO_VoiceChatHUD_Gamepad = {}


local FADE_MS = 200

function ZO_VoiceChatHUD_Gamepad:RegisterForProgressBarEvents()
    local function OnPlayerProgressBarShowing()
        self.listFade:FadeOut(0, FADE_MS)
    end
    local function OnPlayerProgressBarHiding()
        self.listFade:FadeIn(0, FADE_MS)
    end
    CALLBACK_MANAGER:RegisterCallback("PlayerProgressBarFadingIn", OnPlayerProgressBarShowing())
    CALLBACK_MANAGER:RegisterCallback("PlayerProgressBarFadingOut", OnPlayerProgressBarHiding())
end

--XML Calls
function ZO_VoiceChatHUDGamepad_OnInitialize(control)
    zo_mixin(control, ZO_VoiceChatHUD, ZO_VoiceChatHUD_Gamepad)
    control:Initialize(control)
    
    control.listFade = ZO_AlphaAnimation:New(control.speakerList)
    control:RegisterForProgressBarEvents()
    
    VOICE_CHAT_HUD_GAMEPAD = control
end

function ZO_VoiceChatHUDGamepad_OnUpdate(control)
	VOICE_CHAT_HUD_GAMEPAD:Update()
end