--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_HelpScreenTemplate_Keyboard = ZO_Object:Subclass()

function ZO_HelpScreenTemplate_Keyboard:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function ZO_HelpScreenTemplate_Keyboard:Initialize(control, data)
	self.control = control
	control.owner = self

	if data then 
		HELP_CUSTOMER_SUPPORT_KEYBOARD:AddCategory(data)
	end
end