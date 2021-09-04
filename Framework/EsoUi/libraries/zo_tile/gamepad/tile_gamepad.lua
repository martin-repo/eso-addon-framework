--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

----
-- ZO_Tile_Gamepad
----

-----------
-- This class should be dual inherited after a ZO_Tile to create a complete tile. This class should NOT subclass a ZO_Tile
--
-- Note: Since this is expected to be the second class of a dual inheritance it does not have it's own New function
-----------

ZO_Tile_Gamepad = ZO_Object:Subclass()

function ZO_Tile_Gamepad:InitializePlatform()
    self.isSelected = false
end

function ZO_Tile_Gamepad:PostInitializePlatform()
    -- To be overridden
end

function ZO_Tile_Gamepad:LayoutPlatform(data)
    if data then
        local isSelected = data.isSelected or false
        self:SetSelected(isSelected)
    end
end

function ZO_Tile_Gamepad:IsSelected()
    return self.isSelected
end

function ZO_Tile_Gamepad:SetSelected(isSelected)
    if self.isSelected ~= isSelected then
        self.isSelected = isSelected
        self:OnSelectionChanged()
    end
end

function ZO_Tile_Gamepad:OnSelectionChanged()
    -- To be overriden
end
