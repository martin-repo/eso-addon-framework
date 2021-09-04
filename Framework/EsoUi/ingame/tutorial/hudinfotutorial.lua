--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local AUTO_CLOSE_MS = 15 * 1000

ZO_HudInfoTutorial = ZO_TutorialHandlerBase:Subclass()

function ZO_HudInfoTutorial:Initialize(parent)
    self:SetupTutorial(parent, "ZO_HudInfoBoxTutorialTip_Gamepad", "HudInfoTipGamepad")
    self.tutorialGamepad = self.tutorial
    self.tutorialAnimationGamepad = self.tutorialAnimation

    self:SetupTutorial(parent, "ZO_HudInfoBoxTutorialTip", "HudInfoTipKeyboard")
    self.tutorialKeyboard = self.tutorial
    self.tutorialAnimationKeyboard = self.tutorialAnimation

    EVENT_MANAGER:RegisterForUpdate(self.tutorial:GetName() .. "OnUpdate", 0, function() self:OnUpdate() end)

    self:ClearAll()

    ZO_Keybindings_RegisterLabelForBindingUpdate(self.tutorial.helpKey, "TOGGLE_HELP")
    ZO_Keybindings_RegisterLabelForBindingUpdate(self.tutorialGamepad.helpKey, "TOGGLE_HELP")

    self:SetHiddenForReason("inactive", true)
end

function ZO_HudInfoTutorial:SetupTutorial(parent, template, name)
    self.tutorial = CreateControlFromVirtual(parent:GetName(), parent, template, name)

    self.tutorialAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("HudInfoBoxTutorialAnimation", self.tutorial)
    self.tutorialAnimation:SetHandler("OnStop", function(timeline) 
        if not timeline:IsPlayingBackward() then
            FireTutorialHiddenEvent(self.tutorialIndex)
            self:SetHiddenForReason("inactive", true)
            if #self.queue > 0 then
                local nextTutorialIndex = table.remove(self.queue, 1)
                self:DisplayTutorial(nextTutorialIndex)
            end
        end
    end)
end

function ZO_HudInfoTutorial:GetTutorialType()
    return TUTORIAL_TYPE_HUD_INFO_BOX
end

local BASE_TUTORIAL_HEIGHT = 170
function ZO_HudInfoTutorial:DisplayTutorial(tutorialIndex)
    self.tutorialIndex = tutorialIndex
    local isInGamepadMode = IsInGamepadPreferredMode()
    if isInGamepadMode then
        self.tutorial = self.tutorialGamepad
        self.tutorialAnimation = self.tutorialAnimationGamepad
    else
        self.tutorial = self.tutorialKeyboard
        self.tutorialAnimation = self.tutorialAnimationKeyboard
    end

    local title, description = GetTutorialInfo(tutorialIndex)
    local helpCategoryIndex, helpIndex = GetTutorialLinkedHelpInfo(tutorialIndex)
    local hasHelp = helpCategoryIndex ~= nil and helpIndex ~= nil
    self.tutorial.title:SetText(title)
    self.tutorial.description:SetText(description)
    
	local showHelpLabel = hasHelp and not isInGamepadMode
    self.tutorial.helpLabel:SetHidden(not showHelpLabel)
    self.tutorial.helpKey:SetHidden(not showHelpLabel)

    if not isInGamepadMode then
        local textHeight = self.tutorial.description:GetTextHeight()
        if hasHelp then
            textHeight = textHeight + self.tutorial.helpLabel:GetHeight()
        end
        self.tutorial:SetHeight(BASE_TUTORIAL_HEIGHT + textHeight)
    end

    self.tutorialAnimation:PlayBackward()
    self:SetHiddenForReason("inactive", false)
    self:SetCurrentlyDisplayedTutorialIndex(tutorialIndex)
    self.currentlyDisplayedTutorialTimeLeft = AUTO_CLOSE_MS

    PlaySound(SOUNDS.TUTORIAL_INFO_SHOWN)
end

function ZO_HudInfoTutorial:RemoveTutorial(tutorialIndex)
    if self:GetCurrentlyDisplayedTutorialIndex() == tutorialIndex then
        SetTutorialSeen(tutorialIndex)

        self:SetCurrentlyDisplayedTutorialIndex(nil)
        self.currentlyDisplayedTutorialTimeLeft = nil
        self.tutorialAnimation:PlayForward()
    else
        self:RemoveFromQueue(self.queue, tutorialIndex)
    end
end

function ZO_HudInfoTutorial:SetHidden(hide)
    self.tutorial:SetHidden(hide)
end

function ZO_HudInfoTutorial:OnUpdate()
    local now = GetFrameTimeMilliseconds()
    local delta = now - (self.lastUpdate or now)

    if self:GetCurrentlyDisplayedTutorialIndex() and not self.tutorial:IsHidden() then
        self.currentlyDisplayedTutorialTimeLeft = self.currentlyDisplayedTutorialTimeLeft - delta
        if self.currentlyDisplayedTutorialTimeLeft < 0 then
            self:RemoveTutorial(self:GetCurrentlyDisplayedTutorialIndex())
        end
    end

    self.lastUpdate = now
end

function ZO_HudInfoTutorial:ClearAll()
    self:SetCurrentlyDisplayedTutorialIndex(nil)
    self.currentlyDisplayedTutorialTimeLeft = nil
    self.tutorialAnimationGamepad:PlayForward()
    self.tutorialAnimationKeyboard:PlayForward()

    self.queue = {}
end

function ZO_HudInfoTutorial:ShowHelp()
    if self:GetCurrentlyDisplayedTutorialIndex() and not IsInGamepadPreferredMode() then
        local helpCategoryIndex, helpIndex = GetTutorialLinkedHelpInfo(self:GetCurrentlyDisplayedTutorialIndex())
        if helpCategoryIndex and helpIndex then
            self:RemoveTutorial(self:GetCurrentlyDisplayedTutorialIndex())

            HELP:ShowSpecificHelp(helpCategoryIndex, helpIndex)
            return true
        end
    end
end