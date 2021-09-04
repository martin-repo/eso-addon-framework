--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local MOUSE_ENTER = 1
local MOUSE_EXIT = 2

local STOLEN_ICON_TEXTURE = "EsoUI/Art/Inventory/inventory_stolenItem_icon.dds"

--Loot Scene Fragment
------------------------
local ZO_LootSceneFragment = ZO_SceneFragment:Subclass()

function ZO_LootSceneFragment:New(control)
    local fragment = ZO_SceneFragment.New(self)
    fragment.control = control
    fragment.titleControl = GetControl(control, "Title")
    fragment.alphaControl = GetControl(control, "AlphaContainer")
    fragment.keybindButton = GetControl(control, "KeybindButton")

    fragment.slideInStop =  function()
                                LOOT_WINDOW.noTooltips = false
                                local mousedOverItem = LOOT_WINDOW:GetMouseOverLootItem()
                                if mousedOverItem then
                                    LOOT_WINDOW:OnMouseOverUpdated(mousedOverItem, MOUSE_ENTER)
                                end
                            end
    fragment.slideInAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_LootSlideInAnimation", control)
    fragment.slideInAnimation:SetHandler("OnStop", fragment.slideInStop)

    fragment.titleSlideInAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_LootTitleSlideInAnimation", fragment.titleControl)
    fragment.interactFadeOutAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_LootInteractFadeOutAnimation", fragment.keybindButton)

    fragment.alphaInStop =  function()
                                fragment.alphaInDone = true
                            end
    fragment.alphaInAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_LootAlphaInAnimation", fragment.alphaControl)
    fragment.alphaInAnimation:SetHandler("OnStop", fragment.alphaInStop)

    fragment.alphaOutStop = function()
                                    SHARED_INFORMATION_AREA:SetHidden(control, true)
                                    TUTORIAL_SYSTEM:SuppressTutorialType(TUTORIAL_TYPE_HUD_INFO_BOX, false, TUTORIAL_SUPPRESSED_BY_LOOT)
                                    control:SetAlpha(1)
                                    fragment:OnHidden()
                                end
    fragment.alphaOutAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("FadeSceneAnimation", control)
    fragment.alphaOutAnimation:SetHandler("OnStop", fragment.alphaOutStop)

    return fragment
end

function ZO_LootSceneFragment:AnimateNextShow()
    self.animateShow = true
end

function ZO_LootSceneFragment:Show()
    SHARED_INFORMATION_AREA:SetHidden(self.control, false)

    local OPEN_LOOT_WINDOW = false
    ZO_PlayMonsterLootSound(OPEN_LOOT_WINDOW)
    
    TUTORIAL_SYSTEM:SuppressTutorialType(TUTORIAL_TYPE_HUD_INFO_BOX, true, TUTORIAL_SUPPRESSED_BY_LOOT)
    if self.animateShow then
        self.alphaControl:SetAlpha(0)

        self.control:ClearAnchors()
        self.titleControl:ClearAnchors()
        self.control:SetAnchor(TOPLEFT, GetControl("ZO_ReticleContainerInteractContext"), BOTTOMLEFT, -60, -37)
        self.titleControl:SetAnchor(BOTTOMLEFT, GetControl("ZO_ReticleContainerInteractContext"), BOTTOMLEFT, 0, 0)

        LOOT_WINDOW.noTooltips = true

        self.alphaInDone = false
        self.slideInAnimation:PlayFromStart()
        self.titleSlideInAnimation:PlayFromStart()
        self.interactFadeOutAnimation:PlayFromStart()
        self.alphaInAnimation:PlayFromStart()
    else
        self.alphaControl:SetAlpha(1)
        self.keybindButton:SetAlpha(0)

        self.control:ClearAnchors()
        self.titleControl:ClearAnchors()
        self.control:SetAnchor(TOPLEFT, GetControl("ZO_ReticleContainerInteractContext"), BOTTOMLEFT, 165, -37)
        self.titleControl:SetAnchor(BOTTOMLEFT, GetControl("ZO_ReticleContainerInteractContext"), BOTTOMLEFT, 225, 0)
    end
    self.animateShow = nil
    self:OnShown()
end

function ZO_LootSceneFragment:Hide()
    if self.alphaInDone then
        self.alphaOutAnimation:PlayFromEnd()
    else
        SHARED_INFORMATION_AREA:SetHidden(self.control, true)
        TUTORIAL_SYSTEM:SuppressTutorialType(TUTORIAL_TYPE_HUD_INFO_BOX, false, TUTORIAL_SUPPRESSED_BY_LOOT)
        self:OnHidden()
    end
end

local NUM_VISIBLE_LOOT_SLOTS = 5

local DATA_TYPE_LOOT_ITEM = 1
local DATA_TYPE_LOOT_BLANK = 2

local ZO_Loot = ZO_Object:Subclass()
function ZO_Loot:Initialize(control)
    self.control = control

    SHARED_INFORMATION_AREA:AddLoot(control)

    self.list = GetControl(control, "AlphaContainerList")
    ZO_ScrollList_AddDataType(self.list, DATA_TYPE_LOOT_ITEM, "ZO_LootItemSlot", 52, function(control, data) self:SetUpLootItem(control, data) end, nil, nil, ZO_InventorySlot_OnPoolReset)
    ZO_ScrollList_AddDataType(self.list, DATA_TYPE_LOOT_BLANK, "ZO_LootBlankItemSlot", 52, function(control, data) self:SetUpBlankLootItem(control, data) end, nil, nil, ZO_InventorySlot_OnPoolReset)
    ZO_Scroll_SetUseFadeGradient(self.list, false)

    self.title = GetControl(control, "Title")
    self.keyButton = GetControl(control, "KeybindButton")
    self.buttons = { GetControl(control, "AlphaContainerButton1"), GetControl(control, "AlphaContainerButton2") }

    local hideUnbound = false
    self.keyButton:SetKeybind("GAME_CAMERA_INTERACT", hideUnbound, "GAMEPAD_JUMP_OR_INTERACT")

    self:InitializeKeybindDescriptors()

    LOOT_WINDOW_FRAGMENT = ZO_LootSceneFragment:New(control)
    LOOT_SCENE = ZO_LootScene:New("loot", SCENE_MANAGER)
    LOOT_SCENE:RegisterCallback("StateChange",   function(oldState, newState)
                                                    if(newState == SCENE_SHOWING) then
                                                        local dontAutomaticallyExitScene = false
                                                        SCENE_MANAGER:SetHUDUIScene("loot", dontAutomaticallyExitScene)
                                                        KEYBIND_STRIP:RemoveDefaultExit()
                                                        KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
                                                        PushActionLayerByName("Loot")
                                                    elseif(newState == SCENE_HIDING) then
                                                        SCENE_MANAGER:RestoreHUDUIScene()
                                                    elseif(newState == SCENE_HIDDEN) then
                                                        ZO_InventorySlot_RemoveMouseOverKeybinds()
                                                        KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
                                                        KEYBIND_STRIP:RestoreDefaultExit()
                                                        RemoveActionLayerByName("Loot")
                                                        EndLooting()
                                                        self.returnScene = nil
                                                    end
                                                end)

    self.stealthIcon = ZO_StealthIcon:New(control:GetNamedChild("StealthIcon"))
    control:RegisterForEvent(EVENT_STEALTH_STATE_CHANGED, function(event, unitTag, ...) if unitTag == "player" then self.stealthIcon:OnStealthStateChanged(...) end end)
    
    SYSTEMS:RegisterKeyboardRootScene("loot", LOOT_SCENE)
    return self
end

function ZO_Loot:InitializeKeybindDescriptors()
    self.keybindStripDescriptor =
    {
        -- Exit Loot
        {
            --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
            name = "Loot Exit",
            keybind = "LOOT_EXIT",
            ethereal = true,
            callback =  function()
                EndLooting()
            end,
        }
    }
end


function ZO_Loot:SetUpLootItem(control, data)
    local nameControl = control:GetNamedChild("Name")

    if data.currencyType and data.currencyType ~= CURT_NONE then
        nameControl:SetText(data.name)
        nameControl:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
    else
        if data.itemType == LOOT_TYPE_COLLECTIBLE then
            nameControl:SetColor(ZO_WHITE:UnpackRGBA())
        elseif data.itemType == LOOT_TYPE_ANTIQUITY_LEAD then
            -- data.quality is deprecated, included here for addon backwards compatibility
            local displayQuality = data.displayQuality or data.quality
            nameControl:SetColor(GetAntiquityQualityColor(displayQuality):UnpackRGBA())
        else
            if data.isQuest then
                nameControl:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_TOOLTIP, ITEM_TOOLTIP_COLOR_QUEST_ITEM_NAME))
            else
                -- data.quality is deprecated, included here for addon backwards compatibility
                local displayQuality = data.displayQuality or data.quality
                nameControl:SetColor(GetItemQualityColor(displayQuality):UnpackRGBA())
            end
        end

        nameControl:SetText(data.name)
    end

    -- Set up everything but the icon using the old slot logic
    local slot = GetControl(control, "Button")
    ZO_Inventory_SetupSlot(slot, data.count, nil, true)

    -- Set up the icon
    local multiIcon = GetControl(control, "MultiIcon")
    multiIcon:ClearIcons()
    if data.isStolen then
        multiIcon:AddIcon(STOLEN_ICON_TEXTURE)
    end
    multiIcon:AddIcon(data.icon)
    multiIcon:Show()

    slot.lootEntry = data
    ZO_Inventory_BindSlot(slot, SLOT_TYPE_LOOT)

    control:SetHidden(false)
end

function ZO_Loot:SetUpBlankLootItem(control, data)
    control:SetHidden(false)
end

do
    local BLANK_DATA = {}

    function ZO_Loot:UpdateList()
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        ZO_ScrollList_Clear(self.list)

        self.itemCount = 0
        -- Assume that there's only stolen stuff present in this window until proven otherwise
        self.nonStolenItemsPresent = false

        local lootData = LOOT_SHARED:GetSortedLootData()

        for _, data in ipairs(lootData) do
            if data.currencyType then
                data.icon = GetCurrencyLootKeyboardIcon(data.currencyType)
            end

            local scrollEntryData = ZO_ScrollList_CreateDataEntry(DATA_TYPE_LOOT_ITEM, data)
            table.insert(scrollData, scrollEntryData)

            if not data.isStolen then
                self.nonStolenItemsPresent = true
            end
        end

        self.itemCount = #scrollData

        for i = #scrollData + 1, NUM_VISIBLE_LOOT_SLOTS do
            scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_LOOT_BLANK, BLANK_DATA)
        end

        ZO_ScrollList_Commit(self.list)

        -- this text depends on the list itself
        self:UpdateAllControlText()
    end
end

function ZO_Loot:Hide()
    if SCENE_MANAGER:IsShowing("loot") then
        if self.returnScene then
            SCENE_MANAGER:Show(self.returnScene)
        else
            SCENE_MANAGER:RestoreHUDUIScene()
        end
    end
end

function ZO_Loot:UpdateLootWindow(name, actionName, isOwned)
    self:UpdateList()
    self.title:SetText(name)

    self.keyButton:SetText(actionName)
    self.keyButton:SetEnabled(false)
    self.keyButton:SetNormalTextColor(self.nonStolenItemsPresent and ZO_NORMAL_TEXT or ZO_ERROR_COLOR)

    if self.itemCount == 0 then
        self:Hide()
    elseif self.control:IsControlHidden() then
        if SCENE_MANAGER:IsShowingBaseScene() then
            self.returnScene = nil
            LOOT_WINDOW_FRAGMENT:AnimateNextShow()
        else
            self.returnScene = SCENE_MANAGER:GetCurrentScene():GetName()
        end

        SCENE_MANAGER:Show("loot")
    end
end

function ZO_Loot:GetButtonByKeybind(keybind)
    if keybind == "LOOT_ALL" then
        return self.buttons[1]
    else
        return self.buttons[2]
    end
end

function ZO_Loot:OnMouseOverUpdated(control, state)
    if state == MOUSE_ENTER then
        self.mouseOverLootItem = control
        if not self.noTooltips then
            local slot = GetControl(control, "Button")
            local shouldShowSteal = slot.lootEntry.isStolen
            self.buttons[2]:SetText(GetString(shouldShowSteal and SI_LOOT_STEAL or SI_LOOT_TAKE))
            self.buttons[2]:SetNormalTextColor(shouldShowSteal and ZO_ERROR_COLOR or ZO_NORMAL_TEXT)
            self.buttons[2]:SetHidden(false)
            ZO_InventorySlot_OnMouseEnter(control)
        end
    else
        self.mouseOverLootItem = nil
        if not self.noTooltips then
            self.buttons[2]:SetHidden(true)
            ZO_InventorySlot_OnMouseExit(control)
        end
    end
end

function ZO_Loot:UpdateAllControlText()
    if self.itemCount > 0 then
        -- update the take all / steal all text depending on the situation
        self.buttons[1]:SetText(GetString(self.nonStolenItemsPresent and SI_LOOT_TAKE_ALL or SI_LOOT_STEAL_ALL))
        self.buttons[1]:SetNormalTextColor(self.nonStolenItemsPresent and ZO_NORMAL_TEXT or ZO_ERROR_COLOR)
    end
end

function ZO_Loot:GetMouseOverLootItem()
    return self.mouseOverLootItem
end

function ZO_Loot:LootSingleItem()
    local mouseOver = self:GetMouseOverLootItem()
    if mouseOver then
        local control = GetControl(mouseOver, "Button")
        TakeLoot(control)
    end
end

function ZO_Loot:AreNonStolenItemsPresent()
    return (self.nonStolenItemsPresent == true)
end

--[[ Global handlers ]]--
function ZO_Loot_Initialize(control)
    LOOT_WINDOW = ZO_Loot:Initialize(control)
    SYSTEMS:RegisterKeyboardObject("loot", LOOT_WINDOW)
end

function ZO_LootActionButtonCallback_LootAll()
    LOOT_SHARED:LootAllItems()
end

function ZO_LootActionButtonCallback_LootItem()
    LOOT_WINDOW:LootSingleItem()
end

function ZO_Loot_ButtonKeybindPressed(keybind)
    local btn = LOOT_WINDOW:GetButtonByKeybind(keybind)
    if(btn and not btn:IsHidden()) then
        btn:OnClicked()
    end
end

function ZO_LootItemSlot_OnMouseEnter(control)
    LOOT_WINDOW:OnMouseOverUpdated(control, MOUSE_ENTER)
end

function ZO_LootItemSlot_OnMouseExit(control)
    LOOT_WINDOW:OnMouseOverUpdated(control, MOUSE_EXIT)
end
