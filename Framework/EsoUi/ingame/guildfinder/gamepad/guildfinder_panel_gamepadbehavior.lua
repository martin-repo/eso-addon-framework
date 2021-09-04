--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-----------------------------------------
-- Guild Finder Panel Gamepad Behavior --
-----------------------------------------

ZO_GuildFinder_Panel_GamepadBehavior = ZO_CallbackObject:Subclass()

function ZO_GuildFinder_Panel_GamepadBehavior:New(...)
    local object = ZO_CallbackObject.New(self)
    object:Initialize(...)
    return object
end

function ZO_GuildFinder_Panel_GamepadBehavior:Initialize(control)
    self.isActive = false

    self:InitializeKeybinds()
end

function ZO_GuildFinder_Panel_GamepadBehavior:InitializeKeybinds()
    local function OnBack()
        PlaySound(SOUNDS.GAMEPAD_MENU_BACK)
        self:EndSelection()
    end

    self.keybindStripDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, OnBack)
end

function ZO_GuildFinder_Panel_GamepadBehavior:EndSelection()
    self:FireCallbacks("PanelSelectionEnd", self)
end

function ZO_GuildFinder_Panel_GamepadBehavior:Activate()
    self.isActive = true
    KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
end

function ZO_GuildFinder_Panel_GamepadBehavior:Deactivate()
    self.isActive = false
    KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
end

function ZO_GuildFinder_Panel_GamepadBehavior:IsActive()
    return self.isActive
end

function ZO_GuildFinder_Panel_GamepadBehavior:CanBeActivated()
    return true -- Should be overridden for non-interactive panels
end