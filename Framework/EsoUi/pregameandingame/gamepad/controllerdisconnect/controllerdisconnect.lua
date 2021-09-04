--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

function ZO_ControllerDisconnect_Initialize(control)
    CONTROLLER_DISCONNECT_FRAGMENT = ZO_FadeSceneFragment:New(control)

    local headerData =
    {
        titleTextAlignment = TEXT_ALIGN_CENTER,
        titleText = GetString(SI_GAMEPAD_DISCONNECTED_TITLE),
    }

    local header = control:GetNamedChild("HeaderContainer").header
    ZO_GamepadGenericHeader_Initialize(header)
    ZO_GamepadGenericHeader_Refresh(header, headerData)

    control:GetNamedChild("InteractKeybind"):SetText(zo_strformat(SI_GAMEPAD_DISCONNECTED_CONTINUE_TEXT, ZO_Keybindings_GenerateIconKeyMarkup(KEY_GAMEPAD_BUTTON_1)))
end

function ZO_ControllerDisconnect_ShowPopup()
    local name = GetOnlineIdForActiveProfile()
    if name == "" then
        --There is no currently active profile, do not show the controller disconnected message.
        return
    end

    local message
    if ZO_IsPlaystationPlatform() then 
        message = GetString(SI_GAMEPAD_DISCONNECTED_PLAYSTATION_TEXT)
    else
        message = GetString(SI_GAMEPAD_DISCONNECTED_XBOX_TEXT)
    end

    message = zo_strformat(message, name)

    local mainText = ZO_ControllerDisconnect:GetNamedChild("ContainerScrollChildMainText")
    mainText:SetText(message)
    mainText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    ZO_ControllerDisconnect:SetHidden(false)
end

function ZO_ControllerDisconnect_DismissPopup()
    ZO_ControllerDisconnect:SetHidden(true)
end