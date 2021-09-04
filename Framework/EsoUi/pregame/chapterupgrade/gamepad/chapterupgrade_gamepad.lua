--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]


local ChapterUpgrade_Gamepad = ZO_ChapterUpgrade_Shared:Subclass()

function ChapterUpgrade_Gamepad:New(...)
    return ZO_ChapterUpgrade_Shared.New(self, ...)
end

function ChapterUpgrade_Gamepad:Initialize(control)
    ZO_ChapterUpgrade_Shared.Initialize(self, control, "chapterUpgradeGamepad")

    self.focus = ZO_GamepadFocus:New(control, nil, MOVEMENT_CONTROLLER_DIRECTION_HORIZONTAL)
    
    local enterCodeButton = control:GetNamedChild("EnterCodeButton")
    if ZO_PLATFORM_ALLOWS_CHAPTER_CODE_ENTRY[GetPlatformServiceType()] then
        enterCodeButton:SetHidden(false)
        local enterCodeButtonFocusData = 
        {
            highlight = enterCodeButton:GetNamedChild("Highlight"),
            control = enterCodeButton,
            callback = function() self:EnterCodeButtonClicked() end,
        }
        self.focus:AddEntry(enterCodeButtonFocusData)
    else
        enterCodeButton:SetHidden(true)
    end

    local upgradeButton = control:GetNamedChild("UpgradeButton")
    local upgradeButtonFocusData = 
    {
        highlight = upgradeButton:GetNamedChild("Highlight"),
        control = upgradeButton,
        callback = function() self:UpgradeButtonClicked() end,
    }
    
    self.focus:AddEntry(upgradeButtonFocusData)

    self.keybindStripDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            keybind = "UI_SHORTCUT_PRIMARY",
            name = GetString(SI_GAMEPAD_SELECT_OPTION),
            callback = function()
                local selection = self.focus:GetFocusItem()
                if selection and selection.callback then
                    selection.callback()
                end
            end,
        },

        {
            keybind = "UI_SHORTCUT_NEGATIVE",
            name = GetString(SI_CHAPTER_UPGRADE_CONTINUE),
            callback = function()
                self:ShowContinueDialog()
            end,
        },
    }
end

function ChapterUpgrade_Gamepad:UpgradeButtonClicked()
    local IS_STANDARD_EDITION = false
    local SHOW_LOGOUT_WARNING = true
    ZO_ShowChapterUpgradePlatformDialog(IS_STANDARD_EDITION, CHAPTER_UPGRADE_SOURCE_PREGAME, SHOW_LOGOUT_WARNING)
end

function ChapterUpgrade_Gamepad:EnterCodeButtonClicked()
    ZO_Dialogs_ShowGamepadDialog("SHOW_REDEEM_CODE_CONSOLE")
end

function ChapterUpgrade_Gamepad:OnShowing()
    ZO_ChapterUpgrade_Shared.OnShowing(self)
    KEYBIND_STRIP:RemoveDefaultExit()
    KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
    self.focus:Activate()
end

function ChapterUpgrade_Gamepad:OnHiding()
    ZO_ChapterUpgrade_Shared.OnHiding(self)
    KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
    KEYBIND_STRIP:RestoreDefaultExit()
    ZO_SavePlayerConsoleProfile()
    self.focus:Deactivate()
end

function ZO_ChapterUpgrade_Gamepad_OnInitialized(control)
    CHAPTER_UPGRADE_SCREEN_GAMEPAD = ChapterUpgrade_Gamepad:New(control)
end