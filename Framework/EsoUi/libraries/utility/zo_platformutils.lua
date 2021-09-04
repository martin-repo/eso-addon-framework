--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]



function ZO_FormatUserFacingDisplayName(name)
    return IsConsoleUI() and UndecorateDisplayName(name) or name
end

do
    local CHARACTER_NAME_ICON = "EsoUI/Art/Miscellaneous/Gamepad/gp_charNameIcon.dds"
    local CHARACTER_NAME_ICON_SIZE = "70%"

    function ZO_FormatUserFacingCharacterName(name)
        if name ~= "" then
            if IsInGamepadPreferredMode() then
                return zo_iconTextFormat(CHARACTER_NAME_ICON, CHARACTER_NAME_ICON_SIZE, CHARACTER_NAME_ICON_SIZE, name)
            else
                return name
            end
        else
            return ""
        end
    end
end

do
    local HERON_NAME_ICON_SIZE = "70%"

    function ZO_FormatUserFacingHeronName(name)
        if name ~= "" then
            if IsInGamepadPreferredMode() then
                return zo_iconTextFormat(ZO_GAMEPAD_HERON_NAME_ICON, HERON_NAME_ICON_SIZE, HERON_NAME_ICON_SIZE, name)
            else
                return name
            end
        else
            return ""
        end
    end
end

function ZO_FormatUserFacingCharacterOrDisplayName(characterOrDisplayName)
    return IsDecoratedDisplayName(characterOrDisplayName) and ZO_FormatUserFacingDisplayName(characterOrDisplayName) or ZO_FormatUserFacingCharacterName(characterOrDisplayName)
end

function ZO_FormatManualNameEntry(name)
    return IsConsoleUI() and DecorateDisplayName(name) or name
end

internalassert(UI_PLATFORM_MAX_VALUE == ACCOUNT_LABEL_MAX_VALUE, "There should be a platform account label for every platform")
function ZO_GetPlatformAccountLabel()
    return GetString("SI_PLATFORMACCOUNTLABEL", GetUIPlatform())
end

internalassert(PLATFORM_STORE_LABEL_MAX_VALUE == PLATFORM_SERVICE_TYPE_MAX_VALUE, "There should be a platform store label for every platform service")
function ZO_GetPlatformStoreName()
    return GetString("SI_PLATFORMSTORELABEL", GetPlatformServiceType())
end

function ZO_GetPlatformUserFacingName(characterName, displayName)
    local userFacingName

    if IsInGamepadPreferredMode() then
        -- Prioritize the userID if using the gamepad UI, but fallback to character name on PC for cases where
        -- we have the character name but not the userID
        userFacingName = displayName ~= "" and ZO_FormatUserFacingDisplayName(displayName) or ZO_FormatUserFacingCharacterName(characterName)
    else
        -- Prioritize the character name in the keyboard UI.
        userFacingName = characterName ~= "" and ZO_FormatUserFacingCharacterName(characterName) or ZO_FormatUserFacingDisplayName(displayName)
    end

    return userFacingName
end

function ZO_SavePlayerConsoleProfile()
    if IsConsoleUI() and SavePlayerConsoleProfile ~= nil then
        SavePlayerConsoleProfile()
    end
end

function ZO_GetInviteInstructions()
    local instructions 
    if IsConsoleUI() then
        local platform = ZO_GetPlatformAccountLabel()
        instructions = zo_strformat(SI_REQUEST_DISPLAY_NAME_INSTRUCTIONS, platform)
    else
        instructions = GetString(SI_REQUEST_NAME_INSTRUCTIONS)
    end
    return instructions
end

function ZO_PlatformIgnorePlayer(displayName, idRequestType, ...)
    if not IsIgnored(displayName) then
        if not IsConsoleUI() then
            AddIgnore(displayName)
        else
            if not idRequestType or idRequestType == ZO_ID_REQUEST_TYPE_DISPLAY_NAME then
                ZO_ShowConsoleIgnoreDialog(displayName)
            else
                ZO_ShowConsoleIgnoreDialogFromDisplayNameOrFallback(displayName, idRequestType, ...)
            end
        end
    end
end

function ZO_PlatformOpenApprovedURL(approvedUrlType, linkText, externalApplicationText)
    if IsHeronUI() then
        OpenURLByType(approvedUrlType)
    else
        ZO_Dialogs_ShowPlatformDialog("CONFIRM_OPEN_URL_BY_TYPE", { urlType = approvedUrlType }, { mainTextParams = { linkText, externalApplicationText } })
    end
end

do
    internalassert(UI_PLATFORM_MAX_VALUE == 4, "Do these functions still do what they say they do?")
    function ZO_IsPCOrHeronUI()
        return not IsConsoleUI()
    end

    function ZO_IsPCUI()
        return not IsConsoleUI() and not IsHeronUI()
    end

    function ZO_IsConsoleOrHeronUI()
        return IsHeronUI() or IsConsoleUI()
    end

    function ZO_IsPlaystationPlatform()
        local platform = GetUIPlatform()
        return platform == UI_PLATFORM_PS4 or platform == UI_PLATFORM_PS5
    end

    function ZO_IsConsolePlatform()
        local platform = GetUIPlatform()
        return ZO_IsPlaystationPlatform() or platform == UI_PLATFORM_XBOX
    end
end

function ZO_IsIngameUI()
    return IsInUI("ingame")
end

function ZO_IsPregameUI()
    return IsInUI("pregame")
end
