--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

----
-- ZO_ClaimTile_Gamepad
----

-----------
-- This class should be dual inherited after a ZO_ClaimTile to create a complete tile. This class should NOT subclass a ZO_ClaimTile
--
-- Note: Since this is expected to be the second class of a dual inheritance it does not have it's own New function
-----------

ZO_ClaimTile_Gamepad = ZO_ActionTile_Gamepad:Subclass()

function ZO_ClaimTile_Gamepad:InitializePlatform()
    ZO_ActionTile_Gamepad.InitializePlatform(self)
end

function ZO_ClaimTile_Gamepad:PostInitializePlatform()
    ZO_ActionTile_Gamepad.PostInitializePlatform(self)

    self:SetAnimation("ClaimTileAnimation")
end