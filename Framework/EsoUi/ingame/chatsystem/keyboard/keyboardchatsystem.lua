--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

--[[ Chat Container ]]--
ChatContainer = SharedChatContainer:Subclass()

function ChatContainer:New(...)
    return SharedChatContainer.New(self, ...)
end

function ChatContainer:Initialize(control, windowPool, tabPool)
    SharedChatContainer.Initialize(self, control, windowPool, tabPool)

    self.newWindowTab = control:GetNamedChild("NewWindowTab")
    ZO_CreateUniformIconTabData(self.visualData, nil, 32, 32, "EsoUI/Art/ChatWindow/chat_addTab_down.dds", "EsoUI/Art/ChatWindow/chat_addTab_up.dds", "EsoUI/Art/ChatWindow/chat_addTab_over.dds", "EsoUI/Art/ChatWindow/chat_addTab_disabled.dds")
    ZO_TabButton_Icon_Initialize(self.newWindowTab, "SimpleIconHighlight", self.visualData)
    self.newWindowTab:SetHandler("OnMouseUp", function(tab, button, isUpInside) if isUpInside and not ZO_TabButton_IsDisabled(self.newWindowTab) then  self.system:CreateNewChatTab(self) end ZO_TabButton_Unselect(tab) end)
    self.newWindowTab.container = self
    self.overflowTab:SetAnchor(LEFT, self.newWindowTab, RIGHT, 0, 0)

    self:SetAllowSaveSettings(true)
    self:InitializeWindowManagement(control, windowPool, tabPool)
    self:InitializeScrolling(control)
    self:FadeOut()
end

function ChatContainer:UpdateInteractivity(isInteractive)
    self.control:SetMouseEnabled(isInteractive)
    self.scrollbar:SetHidden(not isInteractive)

    SharedChatContainer.UpdateInteractivity(self, isInteractive)
end

function ChatContainer:PerformLayout(insertIndex, xOffset)
    SharedChatContainer.PerformLayout(self, insertIndex, xOffset)

    self:UpdateNewWindowTab()
    self:UpdateOverflowArrow()
    self:ApplyInsertIndicator(insertIndex)
    self:SyncScrollToBuffer()
end

function ChatContainer:UpdateNewWindowTab()
    if self.windows[self.hiddenTabStartIndex - 1] then
        local finalTab = self.windows[self.hiddenTabStartIndex - 1].tab
        self.newWindowTab:SetAnchor(LEFT, finalTab, RIGHT, 0, 0)
    end
end

function ChatContainer:ShowRemoveTabDialog(index)
    SharedChatContainer.ShowRemoveTabDialog(self, index, "CHAT_TAB_REMOVE")
end

function ChatContainer:LoadSettings(settings)
    self.control:ClearAnchors()
    self.control:SetAnchor(settings.point, nil, settings.relPoint, settings.x, settings.y)
    self.control:SetDimensions(settings.width, settings.height)

    SharedChatContainer.LoadSettings(self, settings)
end

function ChatContainer:GetChatFont()
    return ZoFontChat
end

--
--[[ Chat System ]]--
--

ZO_ChatSystem = SharedChatSystem:Subclass()

function ZO_ChatSystem:New(...)
    return SharedChatSystem.New(self, ...)
end

local PC_SETTINGS =
{
    horizontalAlignment = TEXT_ALIGN_LEFT,
    initialFadeAlpha = 0,
    finalFadeAlpha = 1,
    fadeTransitionTime = 2000, -- milliseconds

    chatEditBufferTop = 3,
    chatEditBufferBottom = 3,
}

function ZO_ChatSystem:Initialize(control)
    SharedChatSystem.Initialize(self, control, PC_SETTINGS)
    self.currentNumNotifications = 0
end

local function NewContainerHelper(chat, control, windowPool, tabPool)
    return ChatContainer:New(chat, control, windowPool, tabPool)
end

function ZO_ChatSystem:LoadChatFromSettings()
    local defaults = {
        containers = {
            ["*"] = {
                point = BOTTOMLEFT,
                relPoint = BOTTOMLEFT,
                x = 0,
                y = -82,

                width = 445,
                height = 267,
            },
        },
    }

    SharedChatSystem.LoadChatFromSettings(self, NewContainerHelper, defaults)
end

function ZO_ChatSystem:SetupSavedVars(defaults)
    self.sv = ZO_SavedVars:New("ZO_Ingame_SavedVariables", 4, "Chat", defaults)
end

function ZO_ChatSystem:SaveLocalContainerSettings(container, containerControl)
    local id = container.id
    local settings = self.sv.containers[id]
    settings.width, settings.height = containerControl:GetDimensions()
    local _
    _, settings.point, _, settings.relPoint, settings.x, settings.y = containerControl:GetAnchor(0)
end

function ZO_ChatSystem:InitializeSharedControlManagement(control)
    SharedChatSystem.InitializeSharedControlManagement(self, control, NewContainerHelper, "ZO_KeyboardChatWindowTemplate", "ZO_ChatWindowTabTemplate")

    self.friendsButton = control:GetNamedChild("Friends")
    self.friendsLabel = control:GetNamedChild("NumOnlineFriends")
    self.notificationsButton = control:GetNamedChild("Notifications")
    self.notificationsLabel = control:GetNamedChild("NumNotifications")
    self.notificationsGlow = self.notificationsButton:GetNamedChild("Glow")
    self.mailButton = control:GetNamedChild("Mail")
    self.mailLabel = control:GetNamedChild("NumUnreadMail")
    self.mailGlow = self.mailButton:GetNamedChild("Glow")

    local notificationsBurst = self.notificationsButton:GetNamedChild("Burst")
    self.notificationBurstTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("NotificationAddedBurst", notificationsBurst)
    self.notificationBurstTimeline:SetHandler("OnStop", function() notificationsBurst:SetAlpha(0) end)

    local notificationEcho = self.notificationsButton:GetNamedChild("Echo")
    self.notificationPulseTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("NotificationPulse", notificationEcho)
    self.notificationPulseTimeline:SetHandler("OnStop", function() notificationEcho:SetAlpha(0) end)

    local mailBurst = self.mailButton:GetNamedChild("Burst")
    self.mailBurstTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("NotificationAddedBurst", mailBurst)
    self.mailBurstTimeline:SetHandler("OnStop", function() mailBurst:SetAlpha(0) end)

    -- Setup the minmizied bar
    self.minBar = control:GetNamedChild("MinBar")
    self.minBar:SetInheritAlpha(false)
    self.minBar.maxButton = self.minBar:GetNamedChild("Maximize")
    self.minBar.bgHighlight = self.minBar:GetNamedChild("BGHighlight")
    self.newChatFadeAnim = ZO_AlphaAnimation:New(self.minBar.bgHighlight)
end

function ZO_ChatSystem:TryNotificationAndMailBursts()
    if self.currentNumNotifications > 0 then
        self.notificationBurstTimeline:PlayFromStart()
    end

    if self.numUnreadMails > 0 then
        self.mailBurstTimeline:PlayFromStart()
    end
end

function ZO_ChatSystem:ResetContainerPositionAndSize(container)
    self.sv.containers[container.id] = nil
    container:LoadSettings(self.sv.containers[container.id])
end

function ZO_ChatSystem:RemoveSavedContainer(container)
    table.remove(self.sv.containers, container.id)
end

function ZO_ChatSystem:SetupNotifications(numNotifications)
    self.notificationsLabel:SetText(numNotifications)
    self.notificationsButton:SetInheritAlpha(numNotifications == 0)
    self.notificationsLabel:SetInheritAlpha(numNotifications == 0)

    if numNotifications == 0 then
        self.notificationsGlow:SetHidden(true)

        if self.notificationPulseTimeline:IsPlaying() then
            self.notificationPulseTimeline:Stop()
        end

    else
        self.notificationsGlow:SetHidden(false)
        if not self.notificationPulseTimeline:IsPlaying() then
            self.notificationPulseTimeline:PlayFromStart()
        end
    end
end

function ZO_ChatSystem:OnNumNotificationsChanged(numNotifications)
    if numNotifications > self.currentNumNotifications and IsPlayerActivated() then
        self.notificationBurstTimeline:PlayFromStart()
    end

    self.currentNumNotifications = numNotifications

    self:SetupNotifications(numNotifications)
end

function ZO_ChatSystem:OnNumUnreadMailChanged(numUnread)
    if numUnread > self.numUnreadMails and IsPlayerActivated() then
        self.mailBurstTimeline:PlayFromStart()
    end

    SharedChatSystem.OnNumUnreadMailChanged(self, numUnread)

    self.mailLabel:SetText(numUnread)
    self.mailGlow:SetHidden(numUnread == 0)
end

function ZO_ChatSystem:SetNumOnlineFriends(numOnline)
    self.friendsLabel:SetText(numOnline)

    if InformationTooltip:GetOwner() == self.friendsButton then
        FRIENDS_LIST:FriendsButton_OnMouseEnter(self.friendsButton)
    end
end

function ZO_ChatSystem:InitializeEventManagement()
    self:InitializeSharedEvents("KeyboardChatSystem")

    local function OnNumOnlineFriendsChanged(numOnline)
        self:SetNumOnlineFriends(numOnline)
    end

    local function OnChatChannelUpdated()
        local channelData, channelTarget = CHAT_ROUTER:GetCurrentChannelData()
        self:SetChannelInternal(channelData.id, channelTarget)
    end

    CALLBACK_MANAGER:RegisterCallback("NumOnlineFriendsChanged", OnNumOnlineFriendsChanged)
    CALLBACK_MANAGER:RegisterCallback("OnChatChannelUpdated", OnChatChannelUpdated)
    self:SetNumOnlineFriends(FRIENDS_LIST_MANAGER:GetNumOnline())
end

function ZO_ChatSystem:ShowMinBar()
    --clear the anchors
    self.mailButton:ClearAnchors()
    self.mailLabel:ClearAnchors()
    self.friendsButton:ClearAnchors()
    self.friendsLabel:ClearAnchors()
    self.notificationsButton:ClearAnchors()
    self.notificationsLabel:ClearAnchors()
    self.minBar.maxButton:ClearAnchors()
    self.agentChatButton:ClearAnchors()

    --reset the parentage for fading purposes
    self.mailButton:SetParent(self.minBar)
    self.mailLabel:SetParent(self.minBar)
    self.friendsButton:SetParent(self.minBar)
    self.friendsLabel:SetParent(self.minBar)
    self.notificationsButton:SetParent(self.minBar)
    self.notificationsLabel:SetParent(self.minBar)
    self.agentChatButton:SetParent(self.minBar)

    --reanchor everything
    self.mailButton:SetAnchor(TOPLEFT, nil, nil, -4, 265)
    self.mailLabel:SetAnchor(TOPLEFT, self.mailButton, BOTTOMLEFT, 0, -5)
    self.mailLabel:SetAnchor(TOPRIGHT, self.mailButton, BOTTOMRIGHT, 0, -5)
    self.friendsButton:SetAnchor(TOPLEFT, self.mailLabel, BOTTOMLEFT)
    self.friendsLabel:SetAnchor(TOPLEFT, self.friendsButton, BOTTOMLEFT, 0, -5)
    self.friendsLabel:SetAnchor(TOPRIGHT, self.friendsButton, BOTTOMRIGHT, 0, -5)
    self.notificationsButton:SetAnchor(TOPLEFT, self.friendsLabel, BOTTOMLEFT)
    self.notificationsLabel:SetAnchor(TOPLEFT, self.notificationsButton, BOTTOMLEFT, 0, -5)
    self.notificationsLabel:SetAnchor(TOPRIGHT, self.notificationsButton, BOTTOMRIGHT, 0, -5)
    self.agentChatButton:SetAnchor(TOPLEFT, self.notificationsLabel, BOTTOMLEFT)
    self.minBar.maxButton:SetAnchor(TOPLEFT, self.agentChatButton, BOTTOMLEFT)

    --center the labels
    self.mailLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.friendsLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.notificationsLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    self.minBar:SetHidden(false)
    self.isMinimized = true
end

function ZO_ChatSystem:HideMinBar()
    --clear the anchors
    self.mailButton:ClearAnchors()
    self.mailLabel:ClearAnchors()
    self.friendsButton:ClearAnchors()
    self.friendsLabel:ClearAnchors()
    self.notificationsButton:ClearAnchors()
    self.notificationsLabel:ClearAnchors()
    self.agentChatButton:ClearAnchors()

    --reset the parentage for fading purposes
    self.mailButton:SetParent(self.control)
    self.mailLabel:SetParent(self.control)
    self.friendsButton:SetParent(self.control)
    self.friendsLabel:SetParent(self.control)
    self.notificationsButton:SetParent(self.control)
    self.notificationsLabel:SetParent(self.control)
    self.agentChatButton:SetParent(self.control)

    --reanchor everything
    self.mailButton:SetAnchor(TOPLEFT, nil, TOPLEFT, 20, 7)
    self.mailLabel:SetAnchor(LEFT, self.mailButton, RIGHT, 2)
    self.friendsButton:SetAnchor(LEFT, self.mailLabel, RIGHT, 10)
    self.friendsLabel:SetAnchor(LEFT, self.friendsButton, RIGHT, 2)
    self.notificationsButton:SetAnchor(LEFT, self.friendsLabel, RIGHT, 10)
    self.notificationsLabel:SetAnchor(LEFT, self.notificationsButton, RIGHT, 2)
    self.agentChatButton:SetAnchor(LEFT, self.notificationsLabel, RIGHT, 10)

    --left align the labels
    self.mailLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.friendsLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.notificationsLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    self.isMinimized = false
    self.minBar:SetHidden(true)
end

do
    local function OnPlay(animation, control)
        control.container:SetMinimizingOrMaximizing(true)
        control:SetClampedToScreen(false)
    end

    local function OnStop(animation, control)
        local progress = animation:GetTimeline():GetProgress()
        local maximized = animation:GetDeltaOffsetX() >= 0
        control:SetClampedToScreen(maximized)
        control.container:SetMinimizingOrMaximizing(false)
    end

    local function GetOrCreateMinimizeAnimationTimeline(container)
        if not container.minimizeAnimationTimeline then
            local animationTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ChatMinMaxAnim", container.control)
            container.minimizeAnimationTimeline = animationTimeline

            local animation = animationTimeline:GetAnimation(1)
            animation:SetHandler("OnPlay", OnPlay)
            animation:SetHandler("OnStop", OnStop)
        end

        return container.minimizeAnimationTimeline
    end

    function ZO_ChatSystem:Minimize()
        if not self.isMinimized then
            -- Slide all chat windows off the left edge of the screen
            for _, container in pairs(self.containers) do
                local animationTimeline = GetOrCreateMinimizeAnimationTimeline(container)

                -- If the animation is still playing keep the same positions;
                -- otherwise save the current position and calculate the minimize distance
                local minimizeDistance
                if not animationTimeline:IsPlaying() then
                    minimizeDistance = container.control:GetRight()
                    container.originalPosition = minimizeDistance
                else
                    minimizeDistance = container.originalPosition
                end

                -- Additional margin to ensure the container is completely hidden
                minimizeDistance = minimizeDistance + 40

                -- Set the animation distance
                animationTimeline:GetAnimation(1):SetTranslateDeltas(-minimizeDistance, 0)

                -- Fire the animation
                animationTimeline:PlayFromStart()

                -- Hide all the tabs at the top
                for _, tab in pairs(container.tabGroup.m_Buttons) do
                    tab:SetHidden(true)
                end

                container.overflowTab:SetHidden(true)
                container.newWindowTab:SetHidden(true)
            end

            -- Move the buttons to and show the minimized bar
            PlaySound(SOUNDS.CHAT_MINIMIZED)
            self:ShowMinBar()
        end
    end

    function ZO_ChatSystem:Maximize()
        if self.isMinimized then
            for _, container in pairs(self.containers) do
                -- Calculate the distance to the original position
                local maximizeDistance = container.originalPosition - container.control:GetRight()

                -- Setup the animation and fire it
                local animationTimeline = GetOrCreateMinimizeAnimationTimeline(container)
                animationTimeline:GetAnimation(1):SetTranslateDeltas(maximizeDistance, 0)
                animationTimeline:PlayFromStart()

                -- Show the tabs that haven't overflowed
                for _, tab in pairs(container.tabGroup.m_Buttons) do
                    if tab.index < container.hiddenTabStartIndex then
                        tab:SetHidden(false)
                    else
                        container.overflowTab:SetHidden(false)
                    end
                end
                container.newWindowTab:SetHidden(false)

                container:FadeIn()
            end

            -- Hide the minimized bar and fade in the windows
            PlaySound(SOUNDS.CHAT_MAXIMIZED)
            self:HideMinBar()

            if self.newChatFadeAnim and self.newChatFadeAnim:IsPlaying() then
                self.newChatFadeAnim:Stop()
                self.minBar.bgHighlight:SetAlpha(0)
            end
        end
    end
end

function ZO_ChatSystem:GetFont()
    return ZoFontEditChat
end

function ZO_ChatSystem:GetFontSizeString(fontSize)
    return string.format("$(KB_%d)", fontSize)
end

function ZO_ChatSystem:GetFontSizeFromSetting()
    return GetChatFontSize()
end

-- override
function ZO_ChatSystem:ShouldOnlyShowOnHUD()
    return false
end

-- override
function ZO_ChatSystem:IsHidden()
    if not IsChatSystemAvailableForCurrentPlatform() then
        return true
    end

    -- On platforms with both chat systems (currently only heron), hide on the opposite UI mode
    if ZO_ChatSystem_DoesPlatformUseGamepadChatSystem() and IsInGamepadPreferredMode() then
        return true
    end

    return false
end

--[[ Global/XML Handlers ]]--

function ZO_ChatSystem_ShowOptions(control)
    control.container:ShowContextMenu()
end

function ZO_ChatSystem_OnFriendsEnter(control)
    FRIENDS_LIST:FriendsButton_OnMouseEnter(control)
end

function ZO_ChatSystem_OnFriendsExit(control)
    FRIENDS_LIST:FriendsButton_OnMouseExit(control)
end

function ZO_ChatSystem_OnFriendsClicked(control)
    if IsInGamepadPreferredMode() then
        SCENE_MANAGER:Show("gamepad_friends")
    else
        SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_CONTACTS)
    end
end

function ZO_ChatSystem_OnMailEnter(control)
    local numUnreadMail = GetNumUnreadMail()
    InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
    if numUnreadMail == 0 then
        SetTooltipText(InformationTooltip, GetString(SI_MAIL_NO_UNREAD_MAIL))
    else
        SetTooltipText(InformationTooltip, zo_strformat(SI_MAIL_UNREAD_MAIL, numUnreadMail))
    end
end

function ZO_ChatSystem_OnMailExit(control)
    ClearTooltip(InformationTooltip)
end

function ZO_ChatSystem_OnMailClicked(control)
    SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_MAIL)
end

function ZO_ChatSystem_OnAgentChatEnter(control)
    InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
    SetTooltipText(InformationTooltip, GetString(SI_AGENT_CHAT_ACTIVE_TOOLTIP))
end

function ZO_ChatSystem_OnAgentChatExit(control)
    ClearTooltip(InformationTooltip)
end

function ZO_ChatSystem_OnAgentChatClicked()
    local isChatRequested = GetAgentChatRequestInfo()
    if isChatRequested then
        AcceptAgentChat()
    end
end

function ZO_ChatSystem_OnNotificationsClicked(control)
    SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_NOTIFICATIONS)
end

function ZO_ChatSystem_OnNotificationsEnter(control)
    NOTIFICATIONS:OnNotificationsChatButtonEnter(control)
end

function ZO_ChatSystem_OnNotificationsExit(control)
    NOTIFICATIONS:OnNotificationsChatButtonExit(control)
end

function ZO_ChatSystem_OnMinMaxClicked()
    if KEYBOARD_CHAT_SYSTEM:IsMinimized() then
        KEYBOARD_CHAT_SYSTEM:Maximize()
    else
        KEYBOARD_CHAT_SYSTEM:Minimize()
    end
end

function ZO_ChatSystem_OnInitialized(control)
    KEYBOARD_CHAT_SYSTEM = ZO_ChatSystem:New(control)
    SYSTEMS:RegisterKeyboardObject("ChatSystem", KEYBOARD_CHAT_SYSTEM)

    if not ZO_ChatSystem_DoesPlatformUseGamepadChatSystem() then
        -- On PC platforms, we do not load a gamepad chat system. Let's reuse the keyboard system instead.
        GAMEPAD_CHAT_SYSTEM = KEYBOARD_CHAT_SYSTEM
        SYSTEMS:RegisterGamepadObject("ChatSystem", KEYBOARD_CHAT_SYSTEM)
    end
end