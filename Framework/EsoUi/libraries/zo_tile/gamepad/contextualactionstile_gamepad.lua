--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-----------
-- This class should be dual inherited after an ZO_ContextualActionsTile to create a complete tile. This class should NOT subclass an ZO_ContextualActionsTile
--
-- Note: Since this is expected to be the second class of a dual inheritance it does not have it's own New function
-----------

ZO_CONTEXTUAL_ACTIONS_TILE_GAMEPAD_DEFAULT_HIGHLIGHT_ANIMATION_PROVIDER = ZO_ReversibleAnimationProvider:New("ZO_ContextualActionsTile_Gamepad_HighlightAnimation")

ZO_ContextualActionsTile_Gamepad = ZO_Tile_Gamepad:Subclass()

-- Begin ZO_Tile_Gamepad Overrides --

function ZO_ContextualActionsTile_Gamepad:InitializePlatform()
    ZO_Tile_Gamepad.InitializePlatform(self)

    self:SetHighlightAnimationProvider(ZO_CONTEXTUAL_ACTIONS_TILE_GAMEPAD_DEFAULT_HIGHLIGHT_ANIMATION_PROVIDER)
end

function ZO_ContextualActionsTile_Gamepad:PostInitializePlatform()
    ZO_Tile_Gamepad.PostInitializePlatform(self)

    self.keybindStripDescriptor.alignment = KEYBIND_STRIP_ALIGN_LEFT
end

function ZO_ContextualActionsTile_Gamepad:OnSelectionChanged()
    self:OnFocusChanged(self:IsSelected())
end

-- End ZO_Tile_Gamepad Overrides --