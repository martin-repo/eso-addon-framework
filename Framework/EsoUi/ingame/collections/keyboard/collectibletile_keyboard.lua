--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_COLLECTIBLE_TILE_KEYBOARD_DIMENSIONS_X = 175
ZO_COLLECTIBLE_TILE_KEYBOARD_DIMENSIONS_Y = 125
ZO_COLLECTIBLE_TILE_KEYBOARD_ICON_DIMENSIONS = 52

ZO_CollectibleTile_Keyboard_MouseOverIconAnimationProvider = ZO_ReversibleAnimationProvider:New("ZO_CollectibleTile_Keyboard_MouseOverIconAnimation")

-- Primary logic class must be subclassed after the platform class so that platform specific functions will have priority over the logic class functionality
ZO_CollectibleTile_Keyboard = ZO_Object.MultiSubclass(ZO_ContextualActionsTile_Keyboard, ZO_ContextualActionsTile)

function ZO_CollectibleTile_Keyboard:New(...)
    return ZO_ContextualActionsTile.New(self, ...)
end

-- Begin ZO_ContextualActionsTile_Keyboard Overrides --

function ZO_CollectibleTile_Keyboard:InitializePlatform()
    ZO_ContextualActionsTile_Keyboard.InitializePlatform(self)

    self.statusMultiIcon = self.control:GetNamedChild("Status")
    self.cornerTagTexture = self.control:GetNamedChild("CornerTag")
    self.cooldownIcon = self.control:GetNamedChild("CooldownIcon")
    self.cooldownIconDesaturated = self.control:GetNamedChild("CooldownIconDesaturated")
    self.cooldownTimeLabel = self.control:GetNamedChild("CooldownTime")
    self.cooldownEdgeTexture = self.control:GetNamedChild("CooldownEdge")

    self.isCooldownActive = false
    self.cooldownDuration = 0
    self.cooldownStartTime = 0
    
    self.onUpdateCooldownsCallback = function() self:OnUpdateCooldowns() end
    self:GetControl():SetHandler("OnUpdate", function() self:OnUpdate() end)
end

function ZO_CollectibleTile_Keyboard:PostInitializePlatform()
    -- keybindStripDescriptor and canFocus need to be set after initialize, because ZO_ContextualActionsTile
    -- won't have finished initializing those until after InitializePlatform is called
    ZO_ContextualActionsTile_Keyboard.PostInitializePlatform(self)

    table.insert(self.keybindStripDescriptor,
    {
        keybind = "UI_SHORTCUT_PRIMARY",

        name = function()
            return GetString(self:GetPrimaryInteractionStringId())
        end,

        callback = function()
            self.collectibleData:Use(self:GetActorCategory())
        end,

        visible = function()
            return self.collectibleData and self.collectibleData:IsUsable(self:GetActorCategory()) and self:GetPrimaryInteractionStringId() ~= nil
        end,
    })

    table.insert(self.keybindStripDescriptor,
    {
        keybind = "UI_SHORTCUT_SECONDARY",

        name = GetString(SI_COLLECTIBLE_ACTION_RENAME),

        callback = function()
            ZO_CollectionsBook.ShowRenameDialog(self.collectibleData:GetId())
        end,

        visible = function()
            return self.collectibleData and self.collectibleData:IsRenameable()
        end,
    })

    self:SetCanFocus(false)
end

-- End ZO_ContextualActionsTile_Keyboard Overrides --

function ZO_CollectibleTile_Keyboard:GetActorCategory()
    return self.actorCategory or GAMEPLAY_ACTOR_CATEGORY_PLAYER
end

function ZO_CollectibleTile_Keyboard:OnUpdate()
    if self.collectibleData and self.isCooldownActive then
        self:UpdateCooldownEffect()
    end
end

function ZO_CollectibleTile_Keyboard:RefreshTitleLabelColor()
    if self.collectibleData then
        local isUnlocked = self.collectibleData:IsUnlocked()
        local isMousedOver = self:IsMousedOver()
        local labelColor
        if isUnlocked then
            labelColor = isMousedOver and ZO_HIGHLIGHT_TEXT or ZO_NORMAL_TEXT
        else
            labelColor = isMousedOver and ZO_SELECTED_TEXT or ZO_DISABLED_TEXT
        end
        self:GetTitleLabel():SetColor(labelColor:UnpackRGBA())
    end
end

function ZO_CollectibleTile_Keyboard:RefreshMouseoverVisuals()
    if self.collectibleData and self:IsMousedOver() then
        -- Tooltip
        ClearTooltip(ItemTooltip)
        local offsetX = self.control:GetParent():GetLeft() - self.control:GetLeft() - 5
        InitializeTooltip(ItemTooltip, self.control, RIGHT, offsetX, 0, LEFT)
        local SHOW_NICKNAME = true
        local SHOW_PURCHASABLE_HINT = true
        local SHOW_BLOCK_REASON = true
        ItemTooltip:SetCollectible(self.collectibleData:GetId(), SHOW_NICKNAME, SHOW_PURCHASABLE_HINT, SHOW_BLOCK_REASON, self:GetActorCategory())

        -- Tags
        if self.collectibleData:IsPurchasable() then
            self.cornerTagTexture:SetHidden(false)
        end
    else
        self.cornerTagTexture:SetHidden(true)
    end

    self:RefreshTitleLabelColor()
end

function ZO_CollectibleTile_Keyboard:GetPrimaryInteractionStringId()
    if self.isCooldownActive ~= true and not self.collectibleData:IsBlocked() then
        return self.collectibleData:GetPrimaryInteractionStringId(self:GetActorCategory())
    end
    return nil
end

function ZO_CollectibleTile_Keyboard:ShowMenu()
    local collectibleData = self.collectibleData
    if collectibleData then
        ClearMenu()

        --Use
        if collectibleData:IsUsable(self:GetActorCategory()) then
            local stringId = self:GetPrimaryInteractionStringId()
            if stringId then
                AddMenuItem(GetString(stringId), function() collectibleData:Use(self:GetActorCategory()) end)
            end
        end

        local collectibleId = collectibleData:GetId()

        if IsChatSystemAvailableForCurrentPlatform() then
            --Link in chat
            AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function() ZO_LinkHandler_InsertLink(GetCollectibleLink(collectibleId, LINK_STYLE_BRACKETS)) end)
        end

        --Rename
        if collectibleData:IsRenameable() then
            AddMenuItem(GetString(SI_COLLECTIBLE_ACTION_RENAME), ZO_CollectionsBook.GetShowRenameDialogClosure(collectibleId))
        end

        ShowMenu(self.control)
    end
end

function ZO_CollectibleTile_Keyboard:BeginCooldown()
    self.isCooldownActive = true
    self.cooldownIcon:SetHidden(false)
    self.cooldownIconDesaturated:SetHidden(false)
    self.cooldownTimeLabel:SetHidden(false)
    self.cooldownEdgeTexture:SetHidden(false)
    if self:IsMousedOver() then
        self:SetHighlightHidden(true)
        self:UpdateKeybinds()
    end
end

function ZO_CollectibleTile_Keyboard:EndCooldown()
    self.isCooldownActive = false
    self.cooldownIcon:SetTextureCoords(0, 1, 0, 1)
    self.cooldownIcon:SetHeight(ZO_COLLECTIBLE_TILE_KEYBOARD_ICON_DIMENSIONS)
    self.cooldownIcon:SetHidden(true)
    self.cooldownIconDesaturated:SetHidden(true)
    self.cooldownTimeLabel:SetHidden(true)
    self.cooldownTimeLabel:SetText("")
    self.cooldownEdgeTexture:SetHidden(true)
    if self:IsMousedOver() then
        self:SetHighlightHidden(false)
        self:UpdateKeybinds()
    end
end

function ZO_CollectibleTile_Keyboard:UpdateCooldownEffect()
    local duration = self.cooldownDuration
    local cooldown = self.cooldownStartTime + duration - GetFrameTimeMilliseconds()
    local percentCompleted = (1 - (cooldown / duration)) or 1
    local height = zo_ceil(ZO_COLLECTIBLE_TILE_KEYBOARD_ICON_DIMENSIONS * percentCompleted)
    local textureCoord = 1 - (height / ZO_COLLECTIBLE_TILE_KEYBOARD_ICON_DIMENSIONS)
    self.cooldownIcon:SetHeight(height)
    self.cooldownIcon:SetTextureCoords(0, 1, textureCoord, 1)

    if not self.collectibleData:IsActive(self:GetActorCategory()) then
        local secondsRemaining = cooldown / 1000
        self.cooldownTimeLabel:SetText(ZO_FormatTimeAsDecimalWhenBelowThreshold(secondsRemaining))
    else
        self.cooldownTimeLabel:SetText("")
    end
end

function ZO_CollectibleTile_Keyboard:OnUpdateCooldowns()
    if self.control:IsHidden() then
        self:MarkDirty()
    else
        local collectibleData = self.collectibleData
        if collectibleData and collectibleData:IsUsable(self:GetActorCategory()) then
            local remaining, duration = GetCollectibleCooldownAndDuration(collectibleData:GetId())
            if remaining > 0 and duration > 0 then
                self.cooldownDuration = duration
                self.cooldownStartTime = GetFrameTimeMilliseconds() - (duration - remaining)
                if not self.isCooldownActive then
                    self:BeginCooldown()
                end
                return
            end
        end

        self:EndCooldown()
    end
end

-- Begin ZO_Tile Overrides --

function ZO_CollectibleTile_Keyboard:RefreshLayoutInternal()
    -- Currently this only happens with cooldowns
    self:OnUpdateCooldowns()
end

function ZO_CollectibleTile_Keyboard:Reset()
    self.collectibleId = nil
    self.collectibleData = nil
    self.actorCategory = nil

    self:SetCanFocus(false)
    local INSTANT = true
    self:SetHighlightHidden(true, INSTANT)
    self:SetTitle("")
    self:GetIconTexture():SetHidden(true)
    self.statusMultiIcon:ClearIcons()
    self.cornerTagTexture:SetHidden(true)
    COLLECTIONS_BOOK_SINGLETON:UnregisterCallback("OnUpdateCooldowns", self.onUpdateCooldownsCallback)
    self:EndCooldown()
end

-- End ZO_Tile Overrides --

-- Begin ZO_ContextualActionsTile Overrides --

function ZO_CollectibleTile_Keyboard:OnControlHidden()
    self:OnMouseExit()
    ZO_ContextualActionsTile.OnControlHidden(self)
end

function ZO_CollectibleTile_Keyboard:OnFocusChanged(isFocused)
    ZO_ContextualActionsTile.OnFocusChanged(self, isFocused)

    local collectibleData = self.collectibleData
    if collectibleData then
        if not isFocused then
            ClearTooltip(ItemTooltip)

            if collectibleData:GetNotificationId() then
                RemoveCollectibleNotification(collectibleData:GetNotificationId())
            end

            if collectibleData:IsNew() then
                ClearCollectibleNewStatus(collectibleData:GetId())
            end
        end

        self:RefreshMouseoverVisuals()
    end
end

function ZO_CollectibleTile_Keyboard:SetHighlightHidden(hidden, instant)
    ZO_ContextualActionsTile.SetHighlightHidden(self, hidden, instant)

    if hidden or self.isCooldownActive then
        ZO_CollectibleTile_Keyboard_MouseOverIconAnimationProvider:PlayBackward(self:GetIconTexture(), instant)
    else
        ZO_CollectibleTile_Keyboard_MouseOverIconAnimationProvider:PlayForward(self:GetIconTexture(), instant)
    end
end

-- End ZO_ContextualActionsTile Overrides --

-- Begin ZO_ContextualActionsTile_Keyboard Overrides --

function ZO_CollectibleTile_Keyboard:LayoutPlatform(data)
    local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(data.collectibleId)
    internalassert(collectibleData ~= nil)
    self.collectibleData = collectibleData
    self.actorCategory = data.actorCategory
    self:SetCanFocus(true)

    -- Title
    self:SetTitle(collectibleData:GetFormattedName())

    -- Icon/Highlight
    local iconFile = collectibleData:GetIcon()
    local iconTexture = self:GetIconTexture()
    iconTexture:SetTexture(iconFile)
        
    local desaturation = (collectibleData:IsLocked() or collectibleData:IsBlocked()) and 1 or 0
    self:GetHighlightControl():SetDesaturation(desaturation)

    local isLocked = collectibleData:IsLocked()
    ZO_SetDefaultIconSilhouette(iconTexture, isLocked)
    iconTexture:SetDesaturation(desaturation)

    iconTexture:SetHidden(false)

    -- Status
    local statusMultiIcon = self.statusMultiIcon
    statusMultiIcon:ClearIcons()

    if collectibleData:IsUnlocked() then
        if collectibleData:IsActive(self:GetActorCategory()) then
            statusMultiIcon:AddIcon(ZO_CHECK_ICON)

            if collectibleData:WouldBeHidden() then
                statusMultiIcon:AddIcon("EsoUI/Art/Inventory/inventory_icon_hiddenBy.dds")
            end
        end

        if collectibleData:IsNew() then
            statusMultiIcon:AddIcon(ZO_KEYBOARD_NEW_ICON)
        end
    end

    statusMultiIcon:Show()

    -- Mouseover
    self:RefreshMouseoverVisuals()

    --Cooldowns
    self.cooldownIcon:SetTexture(iconFile)
    self.cooldownIconDesaturated:SetTexture(iconFile)
    self.cooldownTimeLabel:SetText("")
    self:OnUpdateCooldowns()
    COLLECTIONS_BOOK_SINGLETON:RegisterCallback("OnUpdateCooldowns", self.onUpdateCooldownsCallback)
end

function ZO_CollectibleTile_Keyboard:OnMouseUp(button, upInside)
    if upInside and button == MOUSE_BUTTON_INDEX_RIGHT then
        self:ShowMenu()
    end
end

function ZO_CollectibleTile_Keyboard:OnMouseDoubleClick(button)
    if button == MOUSE_BUTTON_INDEX_LEFT then
        local collectibleData = self.collectibleData
        if collectibleData and collectibleData:IsUsable(self:GetActorCategory()) then
            collectibleData:Use(self:GetActorCategory())
        end
    end
end

-- End ZO_ContextualActionsTile_Keyboard Overrides --

-- Begin Global XML Functions --

function ZO_CollectibleTile_Keyboard_OnInitialized(control)
    ZO_CollectibleTile_Keyboard:New(control)
end

-- End Global XML Functions --