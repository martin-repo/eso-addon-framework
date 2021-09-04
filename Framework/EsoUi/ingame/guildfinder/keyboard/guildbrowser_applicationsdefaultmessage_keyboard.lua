--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

------------------
-- Guild Finder --
------------------

ZO_GuildBrowser_ApplicationsDefaultMessage_Keyboard = ZO_GuildFinder_Panel_Shared:Subclass()

function ZO_GuildBrowser_ApplicationsDefaultMessage_Keyboard:New(...)
    return ZO_GuildFinder_Panel_Shared.New(self, ...)
end

function ZO_GuildBrowser_ApplicationsDefaultMessage_Keyboard:Initialize(control)
    ZO_GuildFinder_Panel_Shared.Initialize(self, control)

    self.messageBox = ZO_ScrollingSavingEditBox:New(control:GetNamedChild("DefaultMessage"))
    self.messageBox:SetDefaultText(GetString(SI_GUILD_BROWSER_APPLICATIONS_MESSAGE_DEFAULT_TEXT))
    self.messageBox:SetEmptyText(GetString(SI_GUILD_BROWSER_APPLICATIONS_MESSAGE_EMPTY_TEXT))
    local editControl = self.messageBox:GetEditControl()
    editControl:SetMaxInputChars(MAX_GUILD_APPLICATION_MESSAGE_LENGTH)
    self.messageBox:RegisterCallback("Save", function(text) GUILD_BROWSER_MANAGER:SetSavedApplicationMessage(text) end)
end

function ZO_GuildBrowser_ApplicationsDefaultMessage_Keyboard:OnShowing()
    self.messageBox:SetText(GUILD_BROWSER_MANAGER:GetSavedApplicationMessage() or "")
end

-- XML Functions
-----------------

function ZO_GuildBrowser_ApplicationsDefaultMessage_Keyboard_OnInitialized(control)
    GUILD_BROWSER_APPLICATIONS_KEYBOARD:SetSubcategoryManager(ZO_GUILD_BROWSER_APPLICATIONS_SUBCATEGORY_MESSAGE, ZO_GuildBrowser_ApplicationsDefaultMessage_Keyboard:New(control))
end