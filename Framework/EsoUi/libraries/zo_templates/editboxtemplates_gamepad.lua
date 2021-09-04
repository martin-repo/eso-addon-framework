--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_SINGLE_LINE_EDIT_CONTAINER_GAMEPAD_PADDING_TOP = 8
ZO_SINGLE_LINE_EDIT_CONTAINER_GAMEPAD_PADDING_BOTTOM = 8
ZO_SINGLE_LINE_EDIT_CONTAINER_GAMEPAD_PADDING_LEFT = 8
ZO_SINGLE_LINE_EDIT_CONTAINER_GAMEPAD_PADDING_RIGHT = 6

local EditContainerSizer_Gamepad = ZO_EditContainerSizer:New(ZO_SINGLE_LINE_EDIT_CONTAINER_GAMEPAD_PADDING_TOP, ZO_SINGLE_LINE_EDIT_CONTAINER_GAMEPAD_PADDING_BOTTOM)

function ZO_SingleLineEditContainerSize_Gamepad_OnInitialized(self)
    EditContainerSizer_Gamepad:Add(self)
end

ZO_MULTI_LINE_EDIT_CONTAINER_GAMEPAD_PADDING_TOP = 8
ZO_MULTI_LINE_EDIT_CONTAINER_GAMEPAD_PADDING_BOTTOM = 8
ZO_MULTI_LINE_EDIT_CONTAINER_GAMEPAD_PADDING_LEFT = 9
ZO_MULTI_LINE_EDIT_CONTAINER_GAMEPAD_PADDING_RIGHT = 10