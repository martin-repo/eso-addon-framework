--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-----------------
--Contacts Manager
-----------------

local ZO_GamepadContactsManager = ZO_Object:Subclass()

function ZO_GamepadContactsManager:New(...)
    local manager = ZO_Object.New(self)
    manager:Initialize(...)
    return manager
end

function ZO_GamepadContactsManager:Initialize(control)
    self.control = control

    -- Setup the footer
    self.footerData = 
    {
        data1HeaderText = GetString(SI_GAMEPAD_CONTACTS_HEADER_FRIENDS_ONLINE),
    }

    GAMEPAD_CONTACTS_FRAGMENT = ZO_CreateQuadrantConveyorFragment(control)
    GAMEPAD_CONTACTS_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
                                                                    if newState == SCENE_FRAGMENT_SHOWN then  
                                                                        self:RefreshFooter()
                                                                        self:PerformDeferredInitialization()
                                                                        TriggerTutorial(TUTORIAL_TRIGGER_CONTACTS_OPENED)
                                                                    end
                                                                end)
end

function ZO_GamepadContactsManager:PerformDeferredInitialization()
    if self.initialized then return end
    self.initialized = true

    self:UpdateOnline()
end

function ZO_GamepadContactsManager:UpdateOnline()
    if not self.control:IsControlHidden() then
        self:RefreshFooter()
    end
end

function ZO_GamepadContactsManager:RefreshFooter()
    self.footerData.data1Text = zo_strformat(SI_GAMEPAD_CONTACTS_HEADER_FRIENDS_ONLINE_FORMAT, FRIENDS_LIST_MANAGER:GetNumOnline(), GetNumFriends())

    GAMEPAD_GENERIC_FOOTER:Refresh(self.footerData)
end

function ZO_GamepadContacts_OnInitialized(self)
    GAMEPAD_CONTACTS = ZO_GamepadContactsManager:New(self)
end