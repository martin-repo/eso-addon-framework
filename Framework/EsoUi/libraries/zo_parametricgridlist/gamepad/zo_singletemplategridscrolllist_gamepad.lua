--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-- ZO_AbstractSingleTemplateGridScrollList_Gamepad --

ZO_AbstractSingleTemplateGridScrollList_Gamepad = ZO_AbstractGridScrollList_Gamepad:Subclass()

function ZO_AbstractSingleTemplateGridScrollList_Gamepad:New(...)
    return ZO_AbstractGridScrollList_Gamepad.New(self, ...)
end

function ZO_AbstractSingleTemplateGridScrollList_Gamepad:Initialize(control, selectionTemplate)
    ZO_AbstractGridScrollList_Gamepad.Initialize(self, control, selectionTemplate)
end

function ZO_AbstractSingleTemplateGridScrollList_Gamepad:CommitGridList()
    ZO_AbstractSingleTemplateGridScrollList.CommitGridList(self)
    ZO_ScrollList_RefreshLastHoldPosition(self.list)
    if self.active then
        self:RefreshSelection()
    end
end

-- ZO_SingleTemplateGridScrollList_Gamepad --

ZO_SingleTemplateGridScrollList_Gamepad = ZO_Object.MultiSubclass(ZO_AbstractSingleTemplateGridScrollList_Gamepad, ZO_AbstractSingleTemplateGridScrollList)

function ZO_SingleTemplateGridScrollList_Gamepad:New(...)
    return ZO_AbstractSingleTemplateGridScrollList.New(self, ...)
end

function ZO_SingleTemplateGridScrollList_Gamepad:Initialize(control, autofillRows, selectionTemplate)
    ZO_AbstractSingleTemplateGridScrollList.Initialize(self, control, autofillRows)
    ZO_AbstractGridScrollList_Gamepad.Initialize(self, control, selectionTemplate)
end
