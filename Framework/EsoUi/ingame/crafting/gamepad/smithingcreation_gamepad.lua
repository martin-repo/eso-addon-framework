--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local GAMEPAD_SMITHING_CREATION_OPTION_FILTER_MATERIALS = 1
local GAMEPAD_SMITHING_CREATION_OPTION_FILTER_KNOWLEDGE = 2
local GAMEPAD_SMITHING_CREATION_OPTION_FILTER_QUESTS = 3

local GAMEPAD_SMITHING_TOGGLE_TYPE_STYLE = 1

local optionFilterMaterials =
{
    header = SI_GAMEPAD_SMITHING_FILTERS,
    filterName = GetString(SI_SMITHING_HAVE_MATERIALS),
    filterTooltip = GetString(SI_CRAFTING_HAVE_MATERIALS_TOOLTIP),
    checked = false,
}
local optionFilterKnowledge =
{
    filterName = GetString(SI_SMITHING_HAVE_KNOWLEDGE),
    filterTooltip = GetString(SI_CRAFTING_HAVE_KNOWLEDGE_TOOLTIP),
    checked = false,
}
local optionFilterQuests =
{
    filterName = GetString(SI_SMITHING_IS_QUEST_ITEM),
    filterTooltip = GetString(SI_CRAFTING_IS_QUEST_ITEM_TOOLTIP),
    checked = false,
}


local GAMEPAD_SMITHING_CREATION_OPTION_ACTION_CROWN_STORE = 1

local g_globalActions = 
{
    [GAMEPAD_SMITHING_CREATION_OPTION_ACTION_CROWN_STORE] = 
    {
        actionName = GetString(SI_GAMEPAD_SMITHING_PURCHASE_MORE),
        callback = function()
            ShowMarketAndSearch("", MARKET_OPEN_OPERATION_UNIVERSAL_STYLE_ITEM)
        end,
    }
}
ZO_GAMEPAD_SMITHING_CONTAINER_ITEM_PADDING_Y = 3

--[[ SmithingHorizontalScrollList ]]--
ZO_SmithingHorizontalScrollList_Gamepad = ZO_HorizontalScrollList_Gamepad:Subclass()

function ZO_SmithingHorizontalScrollList_Gamepad:New(...)
    return ZO_HorizontalScrollList_Gamepad.New(self, ...)
end

function ZO_SmithingHorizontalScrollList_Gamepad:SetToggleType(type)
    self.toggleType = type
end

function ZO_SmithingHorizontalScrollList_Gamepad:GetToggleType()
    return self.toggleType
end

--[[ ZO_GamepadSmithingCreation ]]--

ZO_GamepadSmithingCreation = ZO_SharedSmithingCreation:Subclass()

function ZO_GamepadSmithingCreation:New(...)
    return ZO_SharedSmithingCreation.New(self, ...)
end

function ZO_GamepadSmithingCreation:Initialize(panelControl, floatingControl, owner, scene)
    local createListControl = panelControl:GetNamedChild("Create")
    ZO_SharedSmithingCreation.Initialize(self, createListControl, owner)

    self.panelControl = panelControl
    self.floatingControl = floatingControl
    self.currentFocus = nil

    self.scrollContainer = panelControl:GetNamedChild("ScrollContainer")
    self.scrollChild = self.scrollContainer:GetNamedChild("ScrollChild")

    scene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            self:PerformDeferredInitialization()
            KEYBIND_STRIP:RemoveDefaultExit()
            KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
            local tabBarEntries = self:GenerateTabBarEntries()
            self.focus:Activate()
            self.focus:SetFocusByIndex(self.focus:GetFocus()) -- somehow this fixes the "move focus by 2 the first time" issue when entering the screen...remove when lower-level system fixed

            self.owner:SetEnableSkillBar(true)

            local savedFilter = self.typeFilter

            local titleString = ZO_GamepadCraftingUtils_GetLineNameForCraftingType(GetCraftingInteractionType())

            local DONT_SHOW_CAPACITY = false
            ZO_GamepadCraftingUtils_SetupGenericHeader(self.owner, titleString, tabBarEntries, DONT_SHOW_CAPACITY)
            ZO_GamepadCraftingUtils_RefreshGenericHeader(self.owner)

            self:SetupTabBar(tabBarEntries, savedFilter)

            self:DirtyAllLists()
            self.refreshGroup:TryClean()

            GAMEPAD_CRAFTING_RESULTS:SetCraftingTooltip(self.resultTooltip)
            GAMEPAD_CRAFTING_RESULTS:SetTooltipAnimationSounds(self:GetCreateTooltipSound())

            self:TriggerUSITutorial()
        elseif newState == SCENE_HIDDEN then
            GAMEPAD_CRAFTING_RESULTS:SetCraftingTooltip(nil)
            ZO_InventorySlot_RemoveMouseOverKeybinds()
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
            KEYBIND_STRIP:RestoreDefaultExit()

            self.focus:Deactivate()
            self.resultTooltip:SetHidden(true)
            self.interactingWithSameStation = true

            self.owner:SetEnableSkillBar(false)

            ZO_GamepadGenericHeader_Deactivate(self.owner.header)
        end
    end)

    CALLBACK_MANAGER:RegisterCallback("CraftingAnimationsStarted", function()
        if SCENE_MANAGER:IsShowing(scene.name) then
            self.materialQuantitySpinner:Deactivate()
            ZO_GamepadGenericHeader_Deactivate(self.owner.header)
        end
    end)

    CALLBACK_MANAGER:RegisterCallback("CraftingAnimationsStopped", function()
        if SCENE_MANAGER:IsShowing(scene.name) then
            -- only reactivate this right away if it's focused - selecting it will activate it otherwise
            if self.focus:IsFocused(self.materialQuantitySpinner) then
                self:ActivateMaterialQuantitySpinner()
            end

            if self.shouldActivateTabBar then
                ZO_GamepadGenericHeader_Activate(self.owner.header)
            end

            self:RefreshUniversalStyleItemTooltip()
        end
    end)
end

function ZO_GamepadSmithingCreation:PerformDeferredInitialization()
    if self.keybindStripDescriptor then return end

    local scrollListControl = ZO_SmithingHorizontalScrollList_Gamepad
    local traitUnknownFont = "ZoFontGamepadCondensed34"
    local notEnoughInInventoryFont = "ZoFontGamepadCondensed34"
    local listSlotTemplate = "ZO_GamepadSmithingListSlot"

    self:InitializeTraitList(scrollListControl, traitUnknownFont, notEnoughInInventoryFont, listSlotTemplate)
    self:InitializeStyleList(scrollListControl, traitUnknownFont, notEnoughInInventoryFont, listSlotTemplate)
    self:InitializePatternList(scrollListControl, listSlotTemplate)

    local CHAMPION_POINT_RANGE_INHERITS_COLOR = true
    local DONT_COLOR_MATERIAL_NAME_WHITE = false
    self:InitializeMaterialList(scrollListControl, ZO_Spinner_Gamepad, listSlotTemplate, CHAMPION_POINT_RANGE_INHERITS_COLOR, DONT_COLOR_MATERIAL_NAME_WHITE)

    self:InitializeKeybindStripDescriptors()

    self.movementController = ZO_MovementController:New(MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)
    self.resultTooltip = self.floatingControl:GetNamedChild("ResultTooltip")
    self.resultTooltip.ClearLines = function(tooltip)
                                            tooltip.tip:ClearLines()
                                       end

    self:InitializeInventoryChangedCallback()
    self:SetupSavedVars()

    self:SetupListActivationFunctions()

    self:InitializeScrollPanel()
    self:InitializeFocusItems()

    self.styleList:SetToggleType(GAMEPAD_SMITHING_TOGGLE_TYPE_STYLE)
end

do
    local selectedColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
    local disabledColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED))

    local COLOR_TABLE = {
        [true] = selectedColor,
        [false] = disabledColor,
    }

    local function ActivationChangedFn(list, activated)
        local parentControl = list:GetControl():GetParent()

        parentControl.selectedLabel:SetColor(COLOR_TABLE[activated]:UnpackRGBA())
    end

    function ZO_GamepadSmithingCreation:SetupListActivationFunctions()
        local lists = {self.patternList, self.materialList, self.styleList, self.traitList}

        for _, entry in pairs(lists) do
            entry:SetOnActivatedChangedFunction(ActivationChangedFn)
            ActivationChangedFn(entry, false)
        end
    end
end

function ZO_GamepadSmithingCreation:GenerateTabBarEntries()
    local tabBarEntries = {}
    local function AddTabEntry(filterType)
        if ZO_CraftingUtils_CanSmithingFilterBeCraftedHere(filterType) then
            local entry = {}
            entry.text = GetString("SI_SMITHINGFILTERTYPE", filterType)
            entry.callback = function()
                self.typeFilter = filterType
                self:DirtyAllLists()
            end
            entry.mode = filterType

            table.insert(tabBarEntries, entry)
        end
    end

    AddTabEntry(SMITHING_FILTER_TYPE_SET_WEAPONS)
    AddTabEntry(SMITHING_FILTER_TYPE_SET_ARMOR)
    AddTabEntry(SMITHING_FILTER_TYPE_SET_JEWELRY)
    AddTabEntry(SMITHING_FILTER_TYPE_WEAPONS)
    AddTabEntry(SMITHING_FILTER_TYPE_ARMOR)
    AddTabEntry(SMITHING_FILTER_TYPE_JEWELRY)

    return tabBarEntries
end

function ZO_GamepadSmithingCreation:SetupTabBar(tabBarEntries, savedFilter)
    if #tabBarEntries == 1 then
        self.typeFilter = tabBarEntries[1].mode
        self.shouldActivateTabBar = false
    else
        ZO_GamepadGenericHeader_Activate(self.owner.header)
        self.shouldActivateTabBar = true

        local filterFound = false

        for index, entry in pairs(tabBarEntries) do
            if savedFilter == entry.mode then
                self.typeFilter = savedFilter
                ZO_GamepadGenericHeader_SetActiveTabIndex(self.owner.header, index)
                filterFound = true
                break
            end
        end

        if not filterFound then
            self.typeFilter = tabBarEntries[1].mode
            ZO_GamepadGenericHeader_SetActiveTabIndex(self.owner.header, 1)
        end
    end
end

function ZO_GamepadSmithingCreation:RefreshAvailableFilters(dontReselect)
    self:DirtyAllLists()
end

function ZO_GamepadSmithingCreation:InitializeKeybindStripDescriptors()
    local function ShowUniversalItemKeybind()
        if self.selectedList and self.selectedList:GetToggleType() then
            if self.selectedList:GetToggleType() == GAMEPAD_SMITHING_TOGGLE_TYPE_STYLE then
                return true
            end
        else
            return false
        end
    end

    -- back descriptors for screen / options screen
    local startButton = {
        --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
        name = "Gamepad Smithing Creation Default Exit",
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        keybind = "UI_SHORTCUT_EXIT",
        order = -10000,
        callback = function()
            SCENE_MANAGER:ShowBaseScene()
        end,
        visible = function()
            return not ZO_CraftingUtils_IsPerformingCraftProcess()
        end,
        ethereal = true,
    }

    local backButton = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        name = GetString(SI_GAMEPAD_BACK_OPTION),
        keybind = "UI_SHORTCUT_NEGATIVE",
        order = -10000,
        callback = function()
            SCENE_MANAGER:HideCurrentScene()
        end,
        visible = function()
            return not ZO_CraftingUtils_IsPerformingCraftProcess()
        end
    }

    local optionsBackButton = KEYBIND_STRIP:GetDefaultGamepadBackButtonDescriptor()

    local toggleTypeButton =
    {
        keybind = "UI_SHORTCUT_PRIMARY",
        alignment = KEYBIND_STRIP_ALIGN_LEFT,

        name =  function()
                    local universalStyleItemCount = GetCurrentSmithingStyleItemCount(GetUniversalStyleId())
                    local universalStyleItemCountString = zo_strformat(GetString(SI_GAMEPAD_SMITHING_UNIVERSAL_STYLE_ITEM_COUNT), universalStyleItemCount)

                    if universalStyleItemCount == 0 then
                        universalStyleItemCountString = ZO_ERROR_COLOR:Colorize(universalStyleItemCountString)
                    end

                    return zo_strformat(GetString(SI_GAMEPAD_SMITHING_TOGGLE_UNIVERSAL_STYLE), universalStyleItemCountString)
                end,

        callback = function()
            local haveMaterialChecked = optionFilterMaterials.checked
            local haveKnowledgeChecked = optionFilterKnowledge.checked
            local questOnlyChecked = optionFilterQuests.checked
            self:OnFilterChanged(haveMaterialChecked, haveKnowledgeChecked, not self:GetIsUsingUniversalStyleItem(), questOnlyChecked)
            self:RefreshStyleList()
            self:RefreshUniversalStyleItemTooltip()
        end,

        visible = ShowUniversalItemKeybind
    }

    -- Perform craft
    local craftButton =
    {
        keybind = "UI_SHORTCUT_SECONDARY",
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        gamepadOrder = 1000,

        name = function()
            local cost = GetCostToCraftSmithingItem(self:GetAllCraftingParameters(1))
            return ZO_CraftingUtils_GetCostToCraftString(cost)
        end,

        callback = function()
            self:Create(1)
        end,

        enabled = function()
            return self:ShouldCraftButtonBeEnabled()
        end
    }

    local multiCraftButton = {
        name = GetString(SI_GAMEPAD_CRAFT_MULTIPLE),
        keybind = "UI_SHORTCUT_QUATERNARY",
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        gamepadOrder = 1010,
        callback = function()
            local itemLink = GetSmithingPatternResultLink(self:GetResultCraftingParameters())
            ZO_GamepadCraftingUtils_ShowMultiCraftDialog(self, itemLink)
        end,
        enabled = function()
            return self:ShouldMultiCraftButtonBeEnabled()
        end,
    }

    local optionsButton = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        name = GetString(SI_GAMEPAD_CRAFTING_OPTIONS),
        keybind = "UI_SHORTCUT_TERTIARY",
        gamepadOrder = 1030,

        callback = function()
            self:ShowOptionsMenu()
        end,

        visible = function()
            return not ZO_CraftingUtils_IsPerformingCraftProcess()
        end
    }

    local purchaseButton =
    {
        keybind= "UI_SHORTCUT_RIGHT_STICK",
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        gamepadOrder = 1040,

        name = GetString(SI_GAMEPAD_SMITHING_PURCHASE_MORE),

        callback = function()
            ShowMarketAndSearch("", MARKET_OPEN_OPERATION_UNIVERSAL_STYLE_ITEM)
        end,

        visible = ShowUniversalItemKeybind
    }

    self.keybindStripDescriptor = { }
    table.insert(self.keybindStripDescriptor, startButton)
    table.insert(self.keybindStripDescriptor, backButton)
    table.insert(self.keybindStripDescriptor, toggleTypeButton)
    table.insert(self.keybindStripDescriptor, craftButton)
    table.insert(self.keybindStripDescriptor, multiCraftButton)
    table.insert(self.keybindStripDescriptor, optionsButton)
    table.insert(self.keybindStripDescriptor, purchaseButton)
    ZO_CraftingUtils_ConnectKeybindButtonGroupToCraftingProcess(self.keybindStripDescriptor)
end

function ZO_GamepadSmithingCreation:RefreshUniversalStyleItemTooltip()
    if self.selectedList and self.selectedList:GetToggleType() then
        if self.selectedList:GetToggleType() == GAMEPAD_SMITHING_TOGGLE_TYPE_STYLE then
            if self.savedVars.useUniversalStyleItemChecked then
                GAMEPAD_TOOLTIPS:LayoutUniversalStyleItem(GAMEPAD_LEFT_TOOLTIP, self:GetUniversalStyleItemLink())
            else
                GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_LEFT_TOOLTIP)
            end
        end
    else
        GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_LEFT_TOOLTIP)
    end
end

do
    local ACTIVE = true

    function ZO_GamepadSmithingCreation:InitializeFocusItems()
        self.focus = ZO_GamepadFocus:New(self.control)

        self.activateFocusFunction = function(focus, data)
            self.selectedList = focus
            focus:Activate()
            self:UpdateScrollPanel(focus)
            self:UpdateKeybindStrip()
            self:UpdateBorderHighlight(focus, ACTIVE)
            self:RefreshUniversalStyleItemTooltip()
        end

        self.deactivateFocusFunction = function(focus, data)
            focus:Deactivate()
            self:UpdateBorderHighlight(focus, not ACTIVE)
        end

        local patternEntry = {control = self.patternList}
        local materialEntry = {control = self.materialList}
        local materialQuantityEntry = {
            control = self.materialQuantitySpinner,
            canFocus = function(item) return not item:GetControl():IsHidden() end,
            activate = function(focus, data)
                self.selectedList = nil
                self:UpdateKeybindStrip()
                self:ActivateMaterialQuantitySpinner()
                self:UpdateScrollPanel(focus)
                self:UpdateBorderHighlight(focus, ACTIVE)
                self:RefreshUniversalStyleItemTooltip()
            end,
        }
        local styleEntry = {control = self.styleList}
        local traitEntry = {control = self.traitList}

        self.focusEntryData = {patternEntry, materialEntry, materialQuantityEntry, styleEntry, traitEntry}
        for _, v in pairs(self.focusEntryData) do
            v.activate = v.activate or self.activateFocusFunction
            v.deactivate = self.deactivateFocusFunction
        end
        self.focusEntryDataWithoutStyle = {patternEntry, materialEntry, materialQuantityEntry, traitEntry}

        self:RefreshFocusItems()
    end

    function ZO_GamepadSmithingCreation:RefreshFocusItems(focusIndex)
        local entries
        if self:ShouldIgnoreStyleItems() then
            entries = self.focusEntryDataWithoutStyle
        else
            entries = self.focusEntryData
        end

        self.focus:RemoveAllEntries()
        for _, v in pairs(entries) do
            self.focus:AddEntry(v)
        end

        if focusIndex then
            self.focus:SetFocusByIndex(focusIndex)
        else
            self.focus:SetFocusByIndex(1)
        end
    end

    function ZO_GamepadSmithingCreation:InitializeScrollPanel()
        local create = self.panelControl:GetNamedChild("Create")
        create:SetParent(self.scrollChild)
        create:ClearAnchors()
        create:SetAnchor(TOPLEFT, self.scrollChild, TOPLEFT)
        create:SetAnchor(TOPRIGHT, self.scrollChild, TOPRIGHT)

        self.panelControl:GetNamedChild("ScrollContainerScroll"):SetHandler("OnScrollExtentsChanged", function(...) self:OnScrollExtentsChanged(...) end)

        self:RefreshScrollPanel()
    end

    function ZO_GamepadSmithingCreation:RefreshScrollPanel()
        local lists
        if self:ShouldIgnoreStyleItems() then
            lists = {self.patternList, self.materialList, self.traitList}
        else
            lists = {self.patternList, self.materialList, self.styleList, self.traitList}
        end

        for _, entry in pairs(lists) do
            self:UpdateBorderHighlight(entry, not ACTIVE)
        end
    end

    function ZO_GamepadSmithingCreation:OnRefreshAllLists()
        local traitListControl = self.control:GetNamedChild("TraitList")
        local styleListControl = self.control:GetNamedChild("StyleList")
        traitListControl:ClearAnchors()
        if self:ShouldIgnoreStyleItems() then
            local matListControl = self.control:GetNamedChild("MaterialList")
            traitListControl:SetAnchor(TOPLEFT, matListControl, BOTTOMLEFT, 0, ZO_GAMEPAD_SMITHING_CONTAINER_ITEM_PADDING_Y)
            traitListControl:SetAnchor(TOPRIGHT, matListControl, BOTTOMRIGHT, 0, ZO_GAMEPAD_SMITHING_CONTAINER_ITEM_PADDING_Y)
            styleListControl:SetHidden(true)
        else
            traitListControl:SetAnchor(TOPLEFT, styleListControl, BOTTOMLEFT, 0, ZO_GAMEPAD_SMITHING_CONTAINER_ITEM_PADDING_Y)
            traitListControl:SetAnchor(TOPRIGHT, styleListControl, BOTTOMRIGHT, 0, ZO_GAMEPAD_SMITHING_CONTAINER_ITEM_PADDING_Y)
            styleListControl:SetHidden(false)
        end

        self:RefreshScrollPanel()

        local focusIndex = self.focus:GetFocus()
        self:RefreshFocusItems(focusIndex)
    end
end

function ZO_GamepadSmithingCreation:OnScrollExtentsChanged(scroll, horizontalExtents, verticalExtents)
    -- rescroll visible area if necessary
    if verticalExtents > 0 then
        self:UpdateScrollPanel(self.currentFocus)
    end
end

do
    local SCROLL_PADDING_OFFSET = ZO_GAMEPAD_SMITHING_CONTAINER_ITEM_PADDING_Y * 2

    function ZO_GamepadSmithingCreation:UpdateScrollPanel(focus)
        self.currentFocus = focus
        local focusControlParent = focus:GetControl():GetParent()

        local scrollTop = self.scrollContainer:GetTop() + SCROLL_PADDING_OFFSET
        local scrollBottom = self.scrollContainer:GetBottom() - SCROLL_PADDING_OFFSET
        local controlTop = focusControlParent:GetTop()
        local controlBottom = focusControlParent:GetBottom()
        local controlHeight = focusControlParent:GetHeight() + ZO_GAMEPAD_SMITHING_CONTAINER_ITEM_PADDING_Y

        if controlTop <= scrollTop then
            while(controlTop <= scrollTop) do
                ZO_ScrollRelative(self.scrollContainer, -controlHeight)
                controlTop = controlTop + controlHeight
            end
        elseif controlBottom >= scrollBottom then
            while(controlBottom >= scrollBottom) do
                ZO_ScrollRelative(self.scrollContainer, controlHeight)
                controlBottom = controlBottom - controlHeight
            end
        end
    end
end

function ZO_GamepadSmithingCreation:UpdateBorderHighlight(focus, active)
    local focusControlParent = focus:GetControl():GetParent()
    focusControlParent.inactiveBG:SetHidden(active)
    focusControlParent.activeBG:SetHidden(not active)
end

function ZO_GamepadSmithingCreation:UpdateUniversalStyleItemInfo()
    self:SaveFilters()
    self:RefreshStyleList()
end

function ZO_GamepadSmithingCreation:InitializeInventoryChangedCallback()
    local function HandleInventoryChanged()
        self:UpdateUniversalStyleItemInfo()
    end

    self.control:RegisterForEvent(EVENT_INVENTORY_FULL_UPDATE, HandleInventoryChanged)
    self.control:RegisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, HandleInventoryChanged)
end

--TODO: Is this function even used?
function ZO_GamepadSmithingCreation:UpdateOptionLeftTooltip(selectedData)
    if selectedData then
        if selectedData.optionType == GAMEPAD_SMITHING_CREATION_OPTION_FILTER_KNOWLEDGE then
            GAMEPAD_TOOLTIPS:LayoutTitleAndDescriptionTooltip(GAMEPAD_LEFT_TOOLTIP, selectedData.text, GetString(SI_CRAFTING_HAVE_KNOWLEDGE_TOOLTIP))
        elseif selectedData.optionType == GAMEPAD_SMITHING_CREATION_OPTION_FILTER_MATERIALS then
            GAMEPAD_TOOLTIPS:LayoutTitleAndDescriptionTooltip(GAMEPAD_LEFT_TOOLTIP, selectedData.text, GetString(SI_CRAFTING_HAVE_MATERIALS_TOOLTIP))
        end
    end
end

function ZO_GamepadSmithingCreation:SetupSavedVars()
    local defaults =
    {
        haveMaterialChecked = false,
        haveKnowledgeChecked = false,
        useUniversalStyleItemChecked = false,
        questsOnlyChecked = false,
    }
    self.savedVars = ZO_SavedVars:New("ZO_Ingame_SavedVariables", 3, "GamepadSmithingCreation", defaults)

    self:AddCheckedStateToOption(GAMEPAD_SMITHING_CREATION_OPTION_FILTER_MATERIALS, self.savedVars.haveMaterialChecked)
    self:AddCheckedStateToOption(GAMEPAD_SMITHING_CREATION_OPTION_FILTER_KNOWLEDGE, self.savedVars.haveKnowledgeChecked)
    self:AddCheckedStateToOption(GAMEPAD_SMITHING_CREATION_OPTION_FILTER_QUESTS, self.savedVars.questsOnlyChecked)

    if self.savedVars.haveKnowledgeChecked then
        self:SelectValidKnowledgeIndices()
    end
    self:DirtyAllLists()
end

function ZO_GamepadSmithingCreation:AddCheckedStateToOption(option, checkedState)
    if option == GAMEPAD_SMITHING_CREATION_OPTION_FILTER_MATERIALS then
        optionFilterMaterials.checked = checkedState
    elseif option == GAMEPAD_SMITHING_CREATION_OPTION_FILTER_KNOWLEDGE then
        optionFilterKnowledge.checked = checkedState
    elseif option == GAMEPAD_SMITHING_CREATION_OPTION_FILTER_QUESTS then
        optionFilterQuests.checked = checkedState
    end
end

function ZO_GamepadSmithingCreation:ShowOptionsMenu()
    local dialogData = 
    {
        filters = 
        {
            [GAMEPAD_SMITHING_CREATION_OPTION_FILTER_MATERIALS] = optionFilterMaterials,
            [GAMEPAD_SMITHING_CREATION_OPTION_FILTER_KNOWLEDGE] = optionFilterKnowledge,
            [GAMEPAD_SMITHING_CREATION_OPTION_FILTER_QUESTS] = optionFilterQuests,
        },
        globalActions = g_globalActions,
        finishedCallback =  function()
            self:SaveFilters()
            GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_LEFT_TOOLTIP)
        end
    }
    if not self.craftingOptionsDialogGamepad then
        self.craftingOptionsDialogGamepad = ZO_CraftingOptionsDialogGamepad:New()
    end
    self.craftingOptionsDialogGamepad:ShowOptionsDialog(dialogData)
end

function ZO_GamepadSmithingCreation:SaveFilters()
    local haveMaterialChecked = optionFilterMaterials.checked
    local haveKnowledgeChecked = optionFilterKnowledge.checked
    local questOnlyChecked = optionFilterQuests.checked
    local filterChanged = (haveMaterialChecked ~= self.savedVars.haveMaterialChecked) or
                          (haveKnowledgeChecked ~= self.savedVars.haveKnowledgeChecked) or
                          (questOnlyChecked ~= self.savedVars.questsOnlyChecked)
    if filterChanged then
        self.savedVars.haveMaterialChecked = optionFilterMaterials.checked
        self.savedVars.haveKnowledgeChecked = optionFilterKnowledge.checked
        self.savedVars.questsOnlyChecked = optionFilterQuests.checked
        self:OnFilterChanged(haveMaterialChecked, haveKnowledgeChecked, self:GetIsUsingUniversalStyleItem(), questOnlyChecked)
    end
end

function ZO_GamepadSmithingCreation:SetupResultTooltip(selectedPatternIndex, selectedMaterialIndex, selectedMaterialQuantity, selectedStyleId, selectedTraitIndex)
    self.resultTooltip.tip:LayoutPendingSmithingItem(selectedPatternIndex, selectedMaterialIndex, selectedMaterialQuantity, selectedStyleId, selectedTraitIndex)
end

function ZO_GamepadSmithingCreation:ActivateMaterialQuantitySpinner()
    if not ZO_CraftingUtils_IsPerformingCraftProcess() then
        self.materialQuantitySpinner:Activate()
    end
end

do
    local KEYBOARD_TO_GAMEPAD_LOOKUP = {
        [SI_SMITHING_SELECTED_PATTERN] = SI_GAMEPAD_SMITHING_SELECTED_PATTERN,
        [SI_SMITHING_MATERIAL_QUANTITY] = SI_GAMEPAD_SMITHING_MATERIAL_QUANTITY,
        [SI_SMITHING_STYLE_DESCRIPTION] = SI_GAMEPAD_SMITHING_STYLE_DESCRIPTION,
        [SI_SMITHING_TRAIT_DESCRIPTION] = SI_GAMEPAD_SMITHING_TRAIT_DESCRIPTION,
        [SI_CRAFTING_UNIVERSAL_STYLE_DESCRIPTION] = SI_GAMEPAD_SMITHING_UNIVERSAL_STYLE_DESCRIPTION,
    }

    function ZO_GamepadSmithingCreation:GetPlatformFormattedTextString(stringId, ...)
        return zo_strformat(KEYBOARD_TO_GAMEPAD_LOOKUP[stringId], ...)
    end
end

function ZO_GamepadSmithingCreation:SetLabelHidden(label, hidden)
    if hidden then
        label:SetText("")
    end
end

function ZO_GamepadSmithingCreation:OnStyleChanged(selectedData)
    ZO_SharedSmithingCreation.OnStyleChanged(selectedData)

    self.patternList:RefreshVisible()
end

function ZO_GamepadSmithingCreation:UpdateKeybindStrip()
    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
end
