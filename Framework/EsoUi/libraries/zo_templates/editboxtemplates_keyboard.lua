--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_SINGLE_LINE_EDIT_CONTAINER_PADDING_TOP = 3
ZO_SINGLE_LINE_EDIT_CONTAINER_PADDING_BOTTOM = 3
ZO_SINGLE_LINE_EDIT_CONTAINER_PADDING_LEFT = 8
ZO_SINGLE_LINE_EDIT_CONTAINER_PADDING_RIGHT = 6

local EditContainerSizer_Keyboard = ZO_EditContainerSizer:New(ZO_SINGLE_LINE_EDIT_CONTAINER_PADDING_TOP, ZO_SINGLE_LINE_EDIT_CONTAINER_PADDING_BOTTOM)

function ZO_SingleLineEditContainerSize_Keyboard_OnInitialized(self)
    EditContainerSizer_Keyboard:Add(self)
end

ZO_SINGLE_LINE_EDIT_CONTAINER_DARK_PADDING_TOP = 5
ZO_SINGLE_LINE_EDIT_CONTAINER_DARK_PADDING_BOTTOM = 8
ZO_SINGLE_LINE_EDIT_CONTAINER_DARK_PADDING_LEFT = 8
ZO_SINGLE_LINE_EDIT_CONTAINER_DARK_PADDING_RIGHT = 6

local EditContainerDarkSizer_Keyboard = ZO_EditContainerSizer:New(ZO_SINGLE_LINE_EDIT_CONTAINER_DARK_PADDING_TOP, ZO_SINGLE_LINE_EDIT_CONTAINER_DARK_PADDING_BOTTOM)

function ZO_SingleLineEditContainerDarkSize_Keyboard_OnInitialized(self)
    EditContainerDarkSizer_Keyboard:Add(self)
end

ZO_MULTI_LINE_EDIT_CONTAINER_PADDING_TOP = 5
ZO_MULTI_LINE_EDIT_CONTAINER_PADDING_BOTTOM = 7
ZO_MULTI_LINE_EDIT_CONTAINER_PADDING_LEFT = 6
ZO_MULTI_LINE_EDIT_CONTAINER_PADDING_RIGHT = 7