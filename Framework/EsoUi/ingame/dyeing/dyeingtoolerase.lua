--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_DyeingToolErase = ZO_DyeingToolBase:Subclass()

function ZO_DyeingToolErase:New(...)
    return ZO_DyeingToolBase.New(self, ...)
end

function ZO_DyeingToolErase:Initialize(owner)
   ZO_DyeingToolBase.Initialize(self, owner)
end

function ZO_DyeingToolErase:Activate(fromTool, suppressSounds)
    if fromTool and not suppressSounds then
        PlaySound(SOUNDS.DYEING_TOOL_ERASE_SELECTED)
    end
end

function ZO_DyeingToolErase:HasSwatchSelection()
    return false
end

function ZO_DyeingToolErase:OnLeftClicked(restyleSlotData, dyeChannel)
    restyleSlotData:SetPendingDyes(zo_replaceInVarArgs(dyeChannel, INVALID_DYE_ID, restyleSlotData:GetPendingDyes()))
    self.owner:OnPendingDyesChanged(restyleSlotData)
    PlaySound(SOUNDS.DYEING_TOOL_ERASE_USED)
end

function ZO_DyeingToolErase:OnSavedSetLeftClicked(dyeSetIndex, dyeChannel)
    SetSavedDyeSetDyes(dyeSetIndex, zo_replaceInVarArgs(dyeChannel, INVALID_DYE_ID, GetSavedDyeSetDyes(dyeSetIndex)))
    self.owner:OnSavedSetSlotChanged(dyeSetIndex)
    PlaySound(SOUNDS.DYEING_TOOL_ERASE_USED)
end

function ZO_DyeingToolErase:GetCursorType()
    return MOUSE_CURSOR_ERASE
end

function ZO_DyeingToolErase:GetToolActionString()
    return SI_DYEING_TOOL_ERASE_TOOLTIP
end
