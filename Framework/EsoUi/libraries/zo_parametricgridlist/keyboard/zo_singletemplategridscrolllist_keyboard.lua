--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-- ZO_AbstractSingleTemplateGridScrollList_Keyboard --

ZO_AbstractSingleTemplateGridScrollList_Keyboard = ZO_AbstractGridScrollList_Keyboard:Subclass()

function ZO_AbstractSingleTemplateGridScrollList_Keyboard:New(...)
    return ZO_AbstractGridScrollList_Keyboard.New(self, ...)
end

function ZO_AbstractSingleTemplateGridScrollList_Keyboard:Initialize(control)
    ZO_AbstractGridScrollList_Keyboard.Initialize(self, control)
end

-- ZO_SingleTemplateGridScrollList_Keyboard --

ZO_SingleTemplateGridScrollList_Keyboard = ZO_Object.MultiSubclass(ZO_AbstractSingleTemplateGridScrollList_Keyboard, ZO_AbstractSingleTemplateGridScrollList)

function ZO_SingleTemplateGridScrollList_Keyboard:New(...)
    return ZO_AbstractSingleTemplateGridScrollList.New(self, ...)
end

function ZO_SingleTemplateGridScrollList_Keyboard:Initialize(control, autofillRows)
    ZO_AbstractSingleTemplateGridScrollList.Initialize(self, control, autofillRows)
    ZO_AbstractGridScrollList_Keyboard.Initialize(self, control)
end
