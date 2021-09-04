--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_DyeingToolDye = ZO_DyeingToolBase:Subclass()

function ZO_DyeingToolDye:New(...)
    return ZO_DyeingToolBase.New(self, ...)
end

function ZO_DyeingToolDye:Initialize(owner)
   ZO_DyeingToolBase.Initialize(self, owner)
end

function ZO_DyeingToolDye:Activate(fromTool, suppressSounds)
    if fromTool and not suppressSounds then
        PlaySound(SOUNDS.DYEING_TOOL_DYE_SELECTED)
    end
end

function ZO_DyeingToolDye:OnLeftClicked(restyleSlotData, dyeChannel)
    restyleSlotData:SetPendingDyes(zo_replaceInVarArgs(dyeChannel, self.owner:GetSelectedDyeId(), restyleSlotData:GetPendingDyes()))
    self.owner:OnPendingDyesChanged(restyleSlotData)
    PlaySound(SOUNDS.DYEING_TOOL_DYE_USED)
end

function ZO_DyeingToolDye:OnSavedSetLeftClicked(dyeSetIndex, dyeChannel)
    SetSavedDyeSetDyes(dyeSetIndex, zo_replaceInVarArgs(dyeChannel, self.owner:GetSelectedDyeId(), GetSavedDyeSetDyes(dyeSetIndex)))
    self.owner:OnSavedSetSlotChanged(dyeSetIndex)
    PlaySound(SOUNDS.DYEING_TOOL_DYE_USED)
end

function ZO_DyeingToolDye:GetCursorType()
    return MOUSE_CURSOR_PAINT
end

function ZO_DyeingToolDye:GetToolActionString()
    return SI_DYEING_TOOL_DYE_TOOLTIP
end
