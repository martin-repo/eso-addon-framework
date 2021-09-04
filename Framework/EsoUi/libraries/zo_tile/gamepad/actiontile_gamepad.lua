--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

----
-- ZO_ActionTile_Gamepad
----

-----------
-- This class should be dual inherited after an ZO_ActionTile to create a complete tile. This class should NOT subclass an ZO_ActionTile
--
-- Note: Since this is expected to be the second class of a dual inheritance it does not have it's own New function
-----------

ZO_ActionTile_Gamepad = ZO_Tile_Gamepad:Subclass()

function ZO_ActionTile_Gamepad:InitializePlatform()
    ZO_Tile_Gamepad.InitializePlatform(self)

    self.actionKeybindDescriptor = 
    {
        name = GetString(SI_GAMEPAD_SELECT_OPTION),
        keybind = "UI_SHORTCUT_PRIMARY",
        sound = function()
             if self:IsActionAvailable() then
                return SOUNDS.DIALOG_ACCEPT
            else
                return SOUNDS.DIALOG_DECLINE
            end
        end,
        visible = function()
            return self:IsActionAvailable()
        end,
        callback = function()
            if self.actionCallback and self:IsActionAvailable() then
                self.actionCallback()
            end
        end
    }
end

function ZO_ActionTile_Gamepad:PostInitializePlatform()
    self.selection = self.container:GetNamedChild("Selection")

    self:SetSelected(self:IsSelected())
end

function ZO_ActionTile_Gamepad:OnSelectionChanged()
    self:OnFocusChanged(self:IsSelected())
end

function ZO_ActionTile_Gamepad:SetSelected(isSelected)
    local oldSelected = self:IsSelected()

    ZO_Tile_Gamepad.SetSelected(self, isSelected)

    self:UpdateKeybindButton()

    -- Set hidden state if current keybind button's descriptor matches tile's descriptor after the keybind has been updated
    if self.keybindButton and self.keybindButton:GetKeybindButtonDescriptorReference() == self.actionKeybindDescriptor then
        if oldSelected ~= isSelected then
            self.keybindButton:SetHidden(not (isSelected and self:IsActionAvailable()))
        end
    end
end

function ZO_ActionTile_Gamepad:SetKeybindButton(keybindButton)
    self.keybindButton = keybindButton
end

function ZO_ActionTile_Gamepad:SetActionAvailable(available)
    ZO_ActionTile.SetActionAvailable(self, available)
    if self.keybindButton then
        self.keybindButton:SetHidden(not self:IsActionAvailable())
    end
end

function ZO_ActionTile_Gamepad:SetActionText(actionText)
    ZO_ActionTile.SetActionText(self, actionText)

    self.actionKeybindDescriptor.name = actionText
    self:UpdateKeybindButton()
end

function ZO_ActionTile_Gamepad:SetActionSound(actionSound)
    ZO_ActionTile.SetActionSound(self, actionSound)

    self.actionKeybindDescriptor.sound = actionSound
    self:UpdateKeybindButton()
end

function ZO_ActionTile_Gamepad:SetKeybindKey(key)
    self.actionKeybindDescriptor.keybind = key
    self:UpdateKeybindButton()
end

function ZO_ActionTile_Gamepad:UpdateKeybindButton()
    if self.keybindButton and self:IsSelected() then
        self.keybindButton:SetKeybindButtonDescriptor(self.actionKeybindDescriptor)
    end
end

function ZO_ActionTile_Gamepad:GetFocusEntryData()
    if not self.focusEntryData then
        self.focusEntryData =
        {
            activate = function()
                self:SetSelected(true)
            end,
            deactivate = function()
                self:SetSelected(false)
            end,
            highlight = self.selection,
        }
    end
    return self.focusEntryData
end

function ZO_ActionTile_Gamepad:GetKeybindDescriptor()
    return self.actionKeybindDescriptor
end