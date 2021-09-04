--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

EVENT_MANAGER:RegisterForEvent("SharedDialogs", EVENT_CONTROLLER_DISCONNECTED, function() ZO_ControllerDisconnect_ShowPopup() end)
EVENT_MANAGER:RegisterForEvent("SharedDialogs", EVENT_CONTROLLER_CONNECTED, function() ZO_ControllerDisconnect_DismissPopup() end)