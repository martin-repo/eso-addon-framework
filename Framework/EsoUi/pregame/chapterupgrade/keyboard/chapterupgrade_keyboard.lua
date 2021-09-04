--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]


local ChapterUpgrade_Keyboard = ZO_ChapterUpgrade_Shared:Subclass()

function ChapterUpgrade_Keyboard:New(...)
    return ZO_ChapterUpgrade_Shared.New(self, ...)
end

function ChapterUpgrade_Keyboard:Initialize(control)
    ZO_ChapterUpgrade_Shared.Initialize(self, control, "chapterUpgradeKeyboard")
    if not ZO_PLATFORM_ALLOWS_CHAPTER_CODE_ENTRY[GetPlatformServiceType()] then
        -- We don't have access to any sort of code entry on these platforms, so just hide the controls
        local enterCodeButton = control:GetNamedChild("EnterCodeButton")
        enterCodeButton:SetHidden(true)
    end
end

function ChapterUpgrade_Keyboard:UpgradeButtonClicked()
    local IS_STANDARD_EDITION = false
    local SHOW_LOGOUT_WARNING = true
    ZO_ShowChapterUpgradePlatformDialog(IS_STANDARD_EDITION, CHAPTER_UPGRADE_SOURCE_PREGAME, SHOW_LOGOUT_WARNING)
end

local ACCOUNT_PAGE_TEXT_PARAMS = { mainTextParams = { GetString(SI_ESO_ACCOUNT_PAGE_LINK_TEXT) }}

function ChapterUpgrade_Keyboard:EnterCodeButtonClicked()
    ZO_Dialogs_ShowDialog("SHOW_REDEEM_CODE", nil, ACCOUNT_PAGE_TEXT_PARAMS)
end

function ZO_ChapterUpgrade_Keyboard_OnInitialized(control)
    CHAPTER_UPGRADE_SCREEN_KEYBOARD = ChapterUpgrade_Keyboard:New(control)
end