--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local ZO_GamepadHelpLegal = ZO_Object:Subclass()

local URL_LABEL_Y_OFFSET = 55

function ZO_GamepadHelpLegal:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object    
end

function ZO_GamepadHelpLegal:Initialize(control)
    self.control = control
    self.scene = ZO_Scene:New("helpLegalDocsGamepad", SCENE_MANAGER)
    self.scene:AddFragment(ZO_FadeSceneFragment:New(control))
    self.headerData = {
        titleText = GetString(SI_GAMEPAD_HELP_LEGAL_HEADER),
        messageText = GetString(SI_GAMEPAD_HELP_LEGAL_TEXT),
    }
    
    self:SetupText()
    self:InitializeKeybindDescriptors()

    self.scene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindDescriptors)
        elseif newState == SCENE_HIDDEN then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindDescriptors)
        end
    end)
end

function ZO_GamepadHelpLegal:InitializeKeybindDescriptors()
    self.keybindDescriptors = {}
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindDescriptors, GAME_NAVIGATION_TYPE_BUTTON)
end

function ZO_GamepadHelpLegal:SetupText()
    local container = self.control:GetNamedChild("Mask"):GetNamedChild("Container")
    local header = container:GetNamedChild("HeaderContainer"):GetNamedChild("Header")
    local urlLabel = CreateControlFromVirtual("LegalURL", container, "ZO_GamepadHelpLegalURL")
    urlLabel:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, URL_LABEL_Y_OFFSET)
    urlLabel:SetAnchor(TOPRIGHT, header, BOTTOMRIGHT, 0, URL_LABEL_Y_OFFSET)

    ZO_GamepadGenericHeader_Initialize(header, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE)
    ZO_GamepadGenericHeader_Refresh(header, self.headerData)
end

function ZO_GamepadHelpLegal_OnInitialize(control)
    HELP_LEGAL_GAMEPAD = ZO_GamepadHelpLegal:New(control)
end