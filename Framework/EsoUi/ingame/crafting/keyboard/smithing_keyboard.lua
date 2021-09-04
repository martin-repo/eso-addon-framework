--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local SMITHING_SCENE_NAME = "smithing"

ZO_Smithing = ZO_Smithing_Common:Subclass()

function ZO_Smithing:New(...)
    return ZO_Smithing_Common.New(self, ...)
end

function ZO_Smithing:Initialize(control)
    ZO_Smithing_Common.Initialize(self, control)

    self.refinementPanel = ZO_SmithingRefinement:New(self.control:GetNamedChild("RefinementPanel"), self)
    self.creationPanel = ZO_SmithingCreation:New(self.control:GetNamedChild("CreationPanel"), self)
    self.improvementPanel = ZO_SmithingImprovement:New(self.control:GetNamedChild("ImprovementPanel"), self)
    self.deconstructionPanel = ZO_SmithingExtraction:New(self.control:GetNamedChild("DeconstructionPanel"), self)
    self.researchPanel = ZO_SmithingResearch:New(self.control:GetNamedChild("ResearchPanel"), self)

    self:InitializeKeybindStripDescriptors()
    self:InitializeModeBar()

    SMITHING_SCENE = self:CreateInteractScene(SMITHING_SCENE_NAME)
    SMITHING_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            local craftingType = GetCraftingInteractionType()
            ZO_Skills_TieSkillInfoHeaderToCraftingSkill(self.control:GetNamedChild("SkillInfo"), craftingType)

            local isCraftingTypeDifferent = not self.interactingWithSameStation or self.oldCraftingType ~= craftingType
            self.refinementPanel:SetCraftingType(craftingType, self.oldCraftingType, isCraftingTypeDifferent)
            self.creationPanel:SetCraftingType(craftingType, self.oldCraftingType, isCraftingTypeDifferent)
            self.improvementPanel:SetCraftingType(craftingType, self.oldCraftingType, isCraftingTypeDifferent)
            self.deconstructionPanel:SetCraftingType(craftingType, self.oldCraftingType, isCraftingTypeDifferent)
            self.researchPanel:SetCraftingType(craftingType, self.oldCraftingType, isCraftingTypeDifferent)
            self.oldCraftingType = craftingType

            KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)

           self:AddTabsToMenuBar(craftingType, isCraftingTypeDifferent)
        elseif newState == SCENE_HIDDEN then
            ZO_InventorySlot_RemoveMouseOverKeybinds()
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)

            self:DirtyAllPanels()

            ZO_Skills_UntieSkillInfoHeaderToCraftingSkill(self.control:GetNamedChild("SkillInfo"))

            CRAFTING_RESULTS:SetCraftingTooltip(nil)
        end
    end)

    self.control:RegisterForEvent(EVENT_CRAFTING_STATION_INTERACT, function(eventCode, craftingType, sameStation)
        if ZO_Smithing_IsSmithingStation(craftingType) and not IsInGamepadPreferredMode() then
            self.interactingWithSameStation = sameStation
            SCENE_MANAGER:Show(SMITHING_SCENE_NAME)
        end
    end)

    self.control:RegisterForEvent(EVENT_END_CRAFTING_STATION_INTERACT, function(eventCode, craftingType)
        if ZO_Smithing_IsSmithingStation(craftingType) and not IsInGamepadPreferredMode() then
            SCENE_MANAGER:Hide(SMITHING_SCENE_NAME)
        end
    end)

    local function HandleDirtyEvent()
        self:DirtyAllPanels()
    end

    self.control:RegisterForEvent(EVENT_INVENTORY_FULL_UPDATE, HandleDirtyEvent)
    self.control:RegisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, HandleDirtyEvent)

    self.control:RegisterForEvent(EVENT_NON_COMBAT_BONUS_CHANGED, function(eventCode, nonCombatBonusType)
        if SMITHING_BONUSES[nonCombatBonusType] then
            HandleDirtyEvent()
        end
    end)

    self.control:RegisterForEvent(EVENT_SMITHING_TRAIT_RESEARCH_STARTED, HandleDirtyEvent)
    self.control:RegisterForEvent(EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, HandleDirtyEvent)
end

function ZO_Smithing:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,

        -- Perform craft/extract/improve
        {
            name = function()
                if self.mode == SMITHING_MODE_CREATION then
                    local cost = GetCostToCraftSmithingItem(self.creationPanel:GetAllCraftingParameters())
                    return ZO_CraftingUtils_GetCostToCraftString(cost)
                elseif self.mode == SMITHING_MODE_REFINEMENT then
                    local action = self.refinementPanel:IsMultiExtract() and "SI_DECONSTRUCTACTIONNAME_PERFORMMULTIPLE" or "SI_DECONSTRUCTACTIONNAME"
                    return GetString(action, DECONSTRUCT_ACTION_NAME_REFINE)
                elseif self.mode == SMITHING_MODE_DECONSTRUCTION then
                    local action = self.deconstructionPanel:IsMultiExtract() and "SI_DECONSTRUCTACTIONNAME_PERFORMMULTIPLE" or "SI_DECONSTRUCTACTIONNAME"
                    return GetString(action, DECONSTRUCT_ACTION_NAME_DECONSTRUCT)
                elseif self.mode == SMITHING_MODE_IMPROVEMENT then
                    return GetString(SI_SMITHING_IMPROVE)
                elseif self.mode == SMITHING_MODE_RESEARCH then
                    return GetString(SI_ITEM_ACTION_RESEARCH)
                end
            end,
            keybind = "UI_SHORTCUT_SECONDARY",
        
            callback = function()
                if self.mode == SMITHING_MODE_REFINEMENT then
                    self.refinementPanel:ConfirmRefine()
                elseif self.mode == SMITHING_MODE_CREATION then
                    self.creationPanel:ConfirmCreate()
                elseif self.mode == SMITHING_MODE_DECONSTRUCTION then
                    self.deconstructionPanel:ConfirmExtractAll()
                elseif self.mode == SMITHING_MODE_IMPROVEMENT then
                    self.improvementPanel:Improve()
                elseif self.mode == SMITHING_MODE_RESEARCH then
                    self.researchPanel:Research()
                end
            end,

            enabled = function()
                if ZO_CraftingUtils_IsPerformingCraftProcess() then
                    return false
                end
                if self.mode == SMITHING_MODE_REFINEMENT then
                    return self.refinementPanel:IsExtractable()
                elseif self.mode == SMITHING_MODE_CREATION then
                    return self.creationPanel:ShouldCraftButtonBeEnabled()
                elseif self.mode == SMITHING_MODE_DECONSTRUCTION then
                    return self.deconstructionPanel:IsExtractable()
                elseif self.mode == SMITHING_MODE_IMPROVEMENT then
                    return self.improvementPanel:IsImprovable()
                elseif self.mode == SMITHING_MODE_RESEARCH then
                    return self.researchPanel:IsResearchable()
                end
            end,
        },

        -- Clear selections / Cancel Research
        {
            name = function()
                if self.mode == SMITHING_MODE_RESEARCH then
                    return GetString(SI_CRAFTING_CANCEL_RESEARCH)
                else
                    return GetString(SI_CRAFTING_CLEAR_SELECTIONS)
                end
            end,
            keybind = "UI_SHORTCUT_NEGATIVE",
        
            callback = function()
                if self.mode == SMITHING_MODE_REFINEMENT then
                    self.refinementPanel:ClearSelections()
                elseif self.mode == SMITHING_MODE_DECONSTRUCTION then
                    self.deconstructionPanel:ClearSelections()
                elseif self.mode == SMITHING_MODE_IMPROVEMENT then
                    self.improvementPanel:ClearSelections()
                elseif self.mode == SMITHING_MODE_RESEARCH then
                    return self.researchPanel:CancelResearch()
                end 
            end,

            visible = function()
                if not ZO_CraftingUtils_IsPerformingCraftProcess() then 
                    if self.mode == SMITHING_MODE_REFINEMENT then
                        return self.refinementPanel:HasSelections() 
                    elseif self.mode == SMITHING_MODE_DECONSTRUCTION then
                        return self.deconstructionPanel:HasSelections() 
                    elseif self.mode == SMITHING_MODE_IMPROVEMENT then
                        return self.improvementPanel:HasSelections() 
                    elseif self.mode == SMITHING_MODE_RESEARCH then
                        return self.researchPanel:CanCancelResearch()
                    end 
                end
            end,
        },

        -- Crown Store opening action
        {
            name = function()
                if self.mode == SMITHING_MODE_CREATION then
                    return GetString(SI_SMITHING_BUY_CRAFTING_ITEMS)
                end
            end,

            keybind = "UI_SHORTCUT_TERTIARY",

            callback = function()
                if self.mode == SMITHING_MODE_CREATION then
                    self.creationPanel:BuyCraftingItems()
                end
            end,

            visible = function()
                if not ZO_CraftingUtils_IsPerformingCraftProcess() then
                    if self.mode == SMITHING_MODE_CREATION and not self.creationPanel:ShouldIgnoreStyleItems() then
                        return true
                    end
                    return false
                end
            end,
        },
    }

    ZO_CraftingUtils_ConnectKeybindButtonGroupToCraftingProcess(self.keybindStripDescriptor)
end

function ZO_Smithing:InitializeModeBar()
    self.modeBar = self.control:GetNamedChild("ModeMenuBar")
    self.modeBarLabel = self.modeBar:GetNamedChild("Label")

    local function CreateModeData(name, mode, normal, pressed, highlight, disabled)
        return {
            categoryName = name,

            descriptor = mode,
            normal = normal,
            pressed = pressed,
            highlight = highlight,
            disabled = disabled,
            callback = function(tabData)
                self.modeBarLabel:SetText(GetString(name))
                self:SetMode(mode)
            end,
        }
    end

    self.refinementTab = CreateModeData(SI_SMITHING_TAB_REFINEMENT, SMITHING_MODE_REFINEMENT, "EsoUI/Art/Crafting/smithing_tabIcon_refine_up.dds", "EsoUI/Art/Crafting/smithing_tabIcon_refine_down.dds", "EsoUI/Art/Crafting/smithing_tabIcon_refine_over.dds", "EsoUI/Art/Crafting/smithing_tabIcon_refine_disabled.dds")
    self.creationTab = CreateModeData(SI_SMITHING_TAB_CREATION, SMITHING_MODE_CREATION, "EsoUI/Art/Crafting/smithing_tabIcon_creation_up.dds", "EsoUI/Art/Crafting/smithing_tabIcon_creation_down.dds", "EsoUI/Art/Crafting/smithing_tabIcon_creation_over.dds", "EsoUI/Art/Crafting/smithing_tabIcon_creation_disabled.dds")
    self.deconstructionTab = CreateModeData(SI_SMITHING_TAB_DECONSTRUCTION, SMITHING_MODE_DECONSTRUCTION, "EsoUI/Art/Crafting/enchantment_tabIcon_deconstruction_up.dds", "EsoUI/Art/Crafting/enchantment_tabIcon_deconstruction_down.dds", "EsoUI/Art/Crafting/enchantment_tabIcon_deconstruction_over.dds", "EsoUI/Art/Crafting/enchantment_tabIcon_deconstruction_disabled.dds")
    self.improvementTab = CreateModeData(SI_SMITHING_TAB_IMPROVEMENT, SMITHING_MODE_IMPROVEMENT, "EsoUI/Art/Crafting/smithing_tabIcon_improve_up.dds", "EsoUI/Art/Crafting/smithing_tabIcon_improve_down.dds", "EsoUI/Art/Crafting/smithing_tabIcon_improve_over.dds", "EsoUI/Art/Crafting/smithing_tabIcon_improve_disabled.dds")
    self.researchTab = CreateModeData(SI_SMITHING_TAB_RESEARCH, SMITHING_MODE_RESEARCH, "EsoUI/Art/Crafting/smithing_tabIcon_research_up.dds", "EsoUI/Art/Crafting/smithing_tabIcon_research_down.dds", "EsoUI/Art/Crafting/smithing_tabIcon_research_over.dds", "EsoUI/Art/Crafting/smithing_tabIcon_research_disabled.dds")

    self.recipeTab =
    {
        descriptor = SMITHING_MODE_RECIPES,
        callback = function(tabData)
            self.modeBarLabel:SetText(GetString(tabData.categoryName))
            self:SetMode(SMITHING_MODE_RECIPES)
        end,
    }

    ZO_CraftingUtils_ConnectMenuBarToCraftingProcess(self.modeBar)
end

function ZO_Smithing:AddTabsToMenuBar(craftingType, isCraftingTypeDifferent)
    local oldMode = self.mode
    self.mode = nil
    
    local recipeCraftingSystem = GetTradeskillRecipeCraftingSystem(craftingType)
    local recipeCraftingSystemNameStringId = _G["SI_RECIPECRAFTINGSYSTEM"..recipeCraftingSystem]
    local normal, pressed, highlight, disabled = GetKeyboardRecipeCraftingSystemButtonTextures(recipeCraftingSystem)

    local recipeTab = self.recipeTab
    recipeTab.categoryName = recipeCraftingSystemNameStringId
    recipeTab.normal = normal
    recipeTab.pressed = pressed
    recipeTab.highlight = highlight
    recipeTab.disabled = disabled

    ZO_MenuBar_ClearButtons(self.modeBar)
    self.refinementButton = ZO_MenuBar_AddButton(self.modeBar, self.refinementTab)
    self.creationButton = ZO_MenuBar_AddButton(self.modeBar, self.creationTab)
    ZO_MenuBar_AddButton(self.modeBar, self.deconstructionTab)
    self.improvementButton = ZO_MenuBar_AddButton(self.modeBar, self.improvementTab)
    ZO_MenuBar_AddButton(self.modeBar, self.researchTab)
    self.recipeButton = ZO_MenuBar_AddButton(self.modeBar, self.recipeTab)

    if isCraftingTypeDifferent or not oldMode then
        ZO_MenuBar_SelectDescriptor(self.modeBar, SMITHING_MODE_REFINEMENT)
    else
        ZO_MenuBar_SelectDescriptor(self.modeBar, oldMode)
    end   
end

function ZO_Smithing:OnItemReceiveDrag(slotControl, bagId, slotIndex)
    if self.mode == SMITHING_MODE_REFINEMENT then
        self.refinementPanel:OnItemReceiveDrag(slotControl, bagId, slotIndex)
    elseif self.mode == SMITHING_MODE_IMPROVEMENT then
        self.improvementPanel:OnItemReceiveDrag(slotControl, bagId, slotIndex)
    elseif self.mode == SMITHING_MODE_DECONSTRUCTION then
        self.deconstructionPanel:OnItemReceiveDrag(slotControl, bagId, slotIndex)
    end
end

function ZO_Smithing:SetMode(mode)
    if self.mode ~= mode then
        local oldMode = self.mode
        self.mode = mode

        if oldMode == SMITHING_MODE_DECONSTRUCTION then
            self.deconstructionPanel:ClearSelections()
        end

        CRAFTING_RESULTS:SetCraftingTooltip(nil)

        if mode == SMITHING_MODE_RECIPES then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
            PROVISIONER:EmbedInCraftingScene()
        else
            if oldMode == SMITHING_MODE_RECIPES then
                PROVISIONER:RemoveFromCraftingScene()
                KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
            end
            KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
            TriggerTutorial(self.GetTutorialTrigger(self, GetCraftingInteractionType(), mode))
        end

        self.refinementPanel:SetHidden(mode ~= SMITHING_MODE_REFINEMENT)
        self.creationPanel:SetHidden(mode ~= SMITHING_MODE_CREATION)
        self.improvementPanel:SetHidden(mode ~= SMITHING_MODE_IMPROVEMENT)
        self.deconstructionPanel:SetHidden(mode ~= SMITHING_MODE_DECONSTRUCTION)
        self.researchPanel:SetHidden(mode ~= SMITHING_MODE_RESEARCH)
    end
end

function ZO_Smithing:UpdateSharedKeybindStrip()
    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
end

function ZO_Smithing:GetResearchPanel()
    return self.researchPanel
end

function ZO_Smithing:UpdateQuestPins()
    if self.refinementButton then
        self.refinementButton.questPin:SetHidden(not self.shouldRefineForQuest)
    end

    if self.creationButton then
        self.creationButton.questPin:SetHidden(not self.shouldCraftForQuest)
    end

    if self.improvementButton then
        self.improvementButton.questPin:SetHidden(not self.shouldImproveForQuest)
    end

    if self.recipeButton then
        self.recipeButton.questPin:SetHidden(not self.usesProvisioningForQuest)
    end
end

function ZO_Smithing_Initialize(control)
    SMITHING = ZO_Smithing:New(control)

    ZO_Smithing_AddScene(SMITHING_SCENE_NAME, SMITHING)
end