--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

QuickslotActionButton = ActionButton:Subclass()

function QuickslotActionButton:New(...)
    local newB = ActionButton.New(self, ...)
    newB.button.tooltip = ItemTooltip
    return newB
end

function QuickslotActionButton:GetSlot()
    local slotNum = GetCurrentQuickslot()
    return slotNum
end

function QuickslotActionButton:OnRelease()
    if self.itemQtyFailure then
        PlaySound(SOUNDS.QUICKSLOT_USE_EMPTY)
    end

    ActionButton.OnRelease(self)
end

function QuickslotActionButton:ApplyStyle(template)
    ActionButton.ApplyStyle(self, template)

    local cooldownPercent = 1
    if IsInGamepadPreferredMode() and self.showingCooldown then
        cooldownPercent = self.icon.percentComplete
    end

    self:SetCooldownPercentComplete(cooldownPercent)
    self:SetCooldownEdgeState(self.showingCooldown)
end