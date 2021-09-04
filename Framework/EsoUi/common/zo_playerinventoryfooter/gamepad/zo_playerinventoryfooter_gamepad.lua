--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_GAMEPAD_PLAYER_INVENTORY_FOOTER_SCREEN_EDGE_OFFSET_X = -100
ZO_GAMEPAD_PLAYER_INVENTORY_FOOTER_SCREEN_EDGE_OFFSET_Y = -61

ZO_Gamepad_PlayerInventoryFooterFragment = ZO_FadeSceneFragment:Subclass()

function ZO_Gamepad_PlayerInventoryFooterFragment:New(...)
    return ZO_FadeSceneFragment.New(self, ...)
end

function ZO_Gamepad_PlayerInventoryFooterFragment:Initialize(...)
    ZO_AnimatedSceneFragment.Initialize(self, ...)
    self.capacityAmountLabel = self.control:GetNamedChild("InventoryCapacityAmount")

    local function CapacityUpdate()
        self:CapacityUpdate()
    end

    self.control:RegisterForEvent(EVENT_MONEY_UPDATE, CapacityUpdate)
    self.control:RegisterForEvent(EVENT_ALLIANCE_POINT_UPDATE, CapacityUpdate)
    self.control:RegisterForEvent(EVENT_CROWN_UPDATE, CapacityUpdate)
    self.control:RegisterForEvent(EVENT_INVENTORY_FULL_UPDATE, CapacityUpdate)
    self.control:RegisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, CapacityUpdate)
end

function ZO_Gamepad_PlayerInventoryFooterFragment:CapacityUpdate(forceUpdate)
    if not self.control:IsHidden() or forceUpdate then
        self.capacityAmountLabel:SetText(zo_strformat(SI_GAMEPAD_INVENTORY_CAPACITY_FORMAT, GetNumBagUsedSlots(BAG_BACKPACK), GetBagSize(BAG_BACKPACK)))
    end
end

do
    local FORCE_CAPACITY_UPDATE = true
    function ZO_Gamepad_PlayerInventoryFooterFragment:Show()
        self:CapacityUpdate(FORCE_CAPACITY_UPDATE)
        ZO_AnimatedSceneFragment.Show(self)
    end
end