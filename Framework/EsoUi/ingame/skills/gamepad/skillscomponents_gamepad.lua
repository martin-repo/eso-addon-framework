--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

do
    local POINT_ACTION_TEXTURES =
    {
        [ZO_SKILL_POINT_ACTION.PURCHASE] = "EsoUI/Art/Progression/Gamepad/gp_purchase.dds",
        [ZO_SKILL_POINT_ACTION.SELL] = "EsoUI/Art/Buttons/Gamepad/gp_minus.dds",
        [ZO_SKILL_POINT_ACTION.INCREASE_RANK] = "EsoUI/Art/Progression/Gamepad/gp_purchase.dds",
        [ZO_SKILL_POINT_ACTION.DECREASE_RANK] = "EsoUI/Art/Buttons/Gamepad/gp_minus.dds",
        [ZO_SKILL_POINT_ACTION.MORPH] = "EsoUI/Art/Progression/Gamepad/gp_morph.dds",
        [ZO_SKILL_POINT_ACTION.UNMORPH] = "EsoUI/Art/Buttons/Gamepad/gp_minus.dds",
        [ZO_SKILL_POINT_ACTION.REMORPH] = "EsoUI/Art/Progression/Gamepad/gp_remorph.dds",
    }

    function ZO_Skills_GetGamepadSkillPointActionIcon(skillPointAction)
        return POINT_ACTION_TEXTURES[skillPointAction]
    end
end

function ZO_GamepadSkillLineXpBar_Setup(skillLineData, xpBar, nameControl, noWrap)
    local formattedName = skillLineData:GetFormattedName()
    local advised = skillLineData:IsAdvised()
    local lastXP, nextXP, currentXP = skillLineData:GetRankXPValues() 
    if skillLineData:IsAvailable() then
        local skillLineRank = skillLineData:GetCurrentRank()
        ZO_SkillInfoXPBar_SetValue(xpBar, skillLineRank, lastXP, nextXP, currentXP, noWrap)
    elseif skillLineData:IsAdvised() then
        local RANK_NOT_SHOWN = 1
        local CURRENT_XP_NOT_SHOWN = 0
        ZO_SkillInfoXPBar_SetValue(xpBar, RANK_NOT_SHOWN, lastXP, nextXP, CURRENT_XP_NOT_SHOWN, noWrap)
    end
    if nameControl then
        nameControl:SetText(formattedName)
    end
end

function ZO_GamepadSkillLineEntryTemplate_Setup(control, skillLineEntry, selected, activated)
    local skillLineData = skillLineEntry.skillLineData
    local xpBar = control.barContainer.xpBar
    local noWrap = false
    if xpBar.skillLineData ~= skillLineData then
        xpBar.skillLineData = skillLineData
        xpBar:Reset()
        noWrap = true
    end

    local NO_NAME_CONTROL = nil
    ZO_GamepadSkillLineXpBar_Setup(skillLineData, xpBar, NO_NAME_CONTROL, noWrap)

    control.barContainer:SetHidden(not selected)
end

function ZO_GamepadSkillLineEntryTemplate_OnLevelChanged(xpBar, rank)
    xpBar:GetControl():GetParent().rank:SetText(rank)
end

function ZO_GamepadSkillEntryTemplate_SetEntryInfoFromAllocator(skillEntry)
    local skillData = skillEntry.skillData
    
    --Derive the progression specific info from the point allocator progression. This is done here so we can just do a RefreshVisible when the point allocator changes.
    local skillPointAllocator = skillData:GetPointAllocator()
    local skillProgressionData = skillPointAllocator:GetProgressionData()
    skillEntry:SetText(skillProgressionData:GetDetailedGamepadName())
    skillEntry:ClearIcons()
    skillEntry:AddIcon(skillProgressionData:GetIcon())
    if skillEntry.isPreview then
        local color = skillPointAllocator:IsPurchased() and ZO_SELECTED_TEXT or ZO_DISABLED_TEXT
        skillEntry:SetNameColors(color, color)
    end
end

do
    local function SetupAbilityIconFrame(control, isPassive, isActive, isAdvised)
        local iconTexture = control.icon

        local DOUBLE_FRAME_THICKNESS = 9
        local SINGLE_FRAME_THICKNESS = 5
        --Circle Frame (Passive)
        local circleFrameTexture = control.circleFrame
        if circleFrameTexture then
            if isPassive then
                circleFrameTexture:SetHidden(false)
                local frameOffsetFromIcon
                if isAdvised then
                    frameOffsetFromIcon = DOUBLE_FRAME_THICKNESS
                    circleFrameTexture:SetTexture("EsoUI/Art/SkillsAdvisor/gamepad/gp_passiveDoubleFrame_64.dds")
                else
                    frameOffsetFromIcon = SINGLE_FRAME_THICKNESS
                    circleFrameTexture:SetTexture("EsoUI/Art/Miscellaneous/Gamepad/gp_passiveFrame_64.dds")
                end
                circleFrameTexture:ClearAnchors()
                circleFrameTexture:SetAnchor(TOPLEFT, iconTexture, TOPLEFT, -frameOffsetFromIcon, -frameOffsetFromIcon)
                circleFrameTexture:SetAnchor(BOTTOMRIGHT, iconTexture, BOTTOMRIGHT, frameOffsetFromIcon, frameOffsetFromIcon)
            else
                control.circleFrame:SetHidden(true)
            end
        end

        --Edge Frame (Active)
        local SKILLS_ADVISOR_ACTIVE_DOUBLE_FRAME_WIDTH = 128
        local SKILLS_ADVISOR_ACTIVE_DOUBLE_FRAME_HEIGHT = 16
        local edgeFrameBackdrop = control.edgeFrame
        if isActive then
            edgeFrameBackdrop:SetHidden(false)
            local frameOffsetFromIcon
            if isAdvised then 
                frameOffsetFromIcon = DOUBLE_FRAME_THICKNESS
                edgeFrameBackdrop:SetEdgeTexture("EsoUI/Art/SkillsAdvisor/gamepad/edgeDoubleframeGamepadBorder.dds", SKILLS_ADVISOR_ACTIVE_DOUBLE_FRAME_WIDTH, SKILLS_ADVISOR_ACTIVE_DOUBLE_FRAME_HEIGHT)
            else
                frameOffsetFromIcon = SINGLE_FRAME_THICKNESS
                edgeFrameBackdrop:SetEdgeTexture("EsoUI/Art/Miscellaneous/Gamepad/edgeframeGamepadBorder.dds", SKILLS_ADVISOR_ACTIVE_DOUBLE_FRAME_WIDTH, SKILLS_ADVISOR_ACTIVE_DOUBLE_FRAME_HEIGHT)
            end
            edgeFrameBackdrop:ClearAnchors()
            edgeFrameBackdrop:SetAnchor(TOPLEFT, iconTexture, TOPLEFT, -frameOffsetFromIcon, -frameOffsetFromIcon)
            edgeFrameBackdrop:SetAnchor(BOTTOMRIGHT, iconTexture, BOTTOMRIGHT, frameOffsetFromIcon, frameOffsetFromIcon)
        else
            edgeFrameBackdrop:SetHidden(true)
        end

    end

    local function SetBindingTextForSkill(keybindLabel, skillData)
        local hasBinding = false
        local keybindWidth = 0
        --The spot where the keybind goes is occupied by the decrease button in the respec modes
        if SKILLS_AND_ACTION_BAR_MANAGER:GetSkillPointAllocationMode() == SKILL_POINT_ALLOCATION_MODE_PURCHASE_ONLY and skillData:IsActive() then
            local slot = skillData:GetSlotOnCurrentHotbar()
            if slot then
                hasBinding = true
                local hotbarCategory = ACTION_BAR_ASSIGNMENT_MANAGER:GetCurrentHotbarCategory()
                local GAMEPAD_MODE = true
                local actionName = ACTION_BAR_ASSIGNMENT_MANAGER:GetActionNameForSlot(slot, hotbarCategory, GAMEPAD_MODE)
                local bindingText = ""
                if actionName then
                    bindingText = ZO_Keybindings_GetHighestPriorityBindingStringFromAction(actionName, KEYBIND_TEXT_OPTIONS_FULL_NAME, KEYBIND_TEXTURE_OPTIONS_EMBED_MARKUP, GAMEPAD_MODE)                    
                    local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName(actionName)
                    if layerIndex then
                        local key = GetActionBindingInfo(layerIndex, categoryIndex, actionIndex, 1)
                        if IsKeyCodeChordKey(key) then 
                            keybindWidth = 90   --width minus double keybind width (RB+LB)
                        else
                            keybindWidth = 50   --width minus single keybind
                        end
                    end
                else
                    bindingText = zo_iconFormat("EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_equipped.dds", "100%", "100%")
                    keybindWidth = 50   --width minus single keybind
                end
                keybindLabel:SetText(bindingText)
            end
        end

        if hasBinding then
            keybindLabel:SetHidden(false)
        else
            keybindLabel:SetHidden(true)
            -- other controls depend on the keybind width for layout so let's reset its size too
            keybindLabel:SetText("")
        end

        return keybindWidth
    end

    local function SetupIndicatorsForSkill(leftIndicator, rightIndicator, skillData, showIncrease, showDecrease, showNew)
        local indicatorRightWidth = 0

        --If we don't have a left indicator then we aren't going to have a right indicator either, so exit the function
        if not leftIndicator then
            return indicatorRightWidth
        end
        local skillPointAllocator = skillData:GetPointAllocator()

        local increaseMultiIcon
        local decreaseMultiIcon
        if rightIndicator == nil then
            increaseMultiIcon = leftIndicator
            decreaseMultiIcon = leftIndicator
            leftIndicator:ClearIcons()
        elseif SKILLS_AND_ACTION_BAR_MANAGER:DoesSkillPointAllocationModeBatchSave() then
            increaseMultiIcon = rightIndicator
            decreaseMultiIcon = leftIndicator
            leftIndicator:ClearIcons()
            rightIndicator:ClearIcons()
        else
            increaseMultiIcon = leftIndicator
            decreaseMultiIcon = rightIndicator
            leftIndicator:ClearIcons()
            rightIndicator:ClearIcons()
        end

        --Increase (Morph, Purchase, Increase Rank) Icon
        local increaseAction = ZO_SKILL_POINT_ACTION.NONE
        if showIncrease then
            increaseAction = skillPointAllocator:GetIncreaseSkillAction()
        elseif isMorph then
            -- this is used more as an indicator that this skill has been morphed, than an indicator that you _should_ morph it
            increaseAction = ZO_SKILL_POINT_ACTION.MORPH
        end

        if increaseAction ~= ZO_SKILL_POINT_ACTION.NONE then
            increaseMultiIcon:AddIcon(ZO_Skills_GetGamepadSkillPointActionIcon(increaseAction))
        end

        --Decrease (Unmorph, Sell, Decrease Rank)
        if showDecrease then
            local decreaseAction = skillPointAllocator:GetDecreaseSkillAction()
            if decreaseAction ~= ZO_SKILL_POINT_ACTION.NONE then
                decreaseMultiIcon:AddIcon(ZO_Skills_GetGamepadSkillPointActionIcon(decreaseAction))
            end

            --Always carve out space for the decrease icon even if it isn't active so the name doesn't dance around as it appears and disappears
            indicatorRightWidth = 40
        end

        --New Indicator
        if showNew then
            if skillData:HasUpdatedStatus() then
                leftIndicator:AddIcon("EsoUI/Art/Inventory/newItem_icon.dds")
            end
        end

        leftIndicator:Show()
        if rightIndicator then
            rightIndicator:Show()
        end

        return indicatorRightWidth
    end

    local SKILL_ENTRY_LABEL_WIDTH = 289

    function ZO_GamepadSkillEntryTemplate_Setup(control, skillEntry, selected, activated, displayView)
        --Some skill entries want to target a specific progression data (such as the morph dialog showing two specific morphs). Otherwise they use the skill progression that matches the current point spending.
        local skillData = skillEntry.skillData or skillEntry.skillProgressionData:GetSkillData()
        local skillProgressionData = skillEntry.skillProgressionData or skillData:GetPointAllocatorProgressionData()
        local skillPointAllocator = skillData:GetPointAllocator()
        local isUnlocked = skillProgressionData:IsUnlocked()
        local isMorph = skillData:IsActive() and skillProgressionData:IsMorph()
        local isPurchased = skillPointAllocator:IsPurchased()
        local isInSkillBuild = skillProgressionData:IsAdvised()

        --Icon
        local iconTexture = control.icon
        if displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE then
            if isPurchased then
                iconTexture:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
            else
                iconTexture:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
            end
        end

        SetupAbilityIconFrame(control, skillData:IsPassive(), skillData:IsActive(), isInSkillBuild)

        --Label Color
        if displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE then
            if not skillEntry.isPreview and isPurchased then
                control.label:SetColor((selected and PURCHASED_COLOR or PURCHASED_UNSELECTED_COLOR):UnpackRGBA())
            end
        else
            control.label:SetColor(PURCHASED_COLOR:UnpackRGBA())
        end    

        --Lock Icon
        if control.lock then
            control.lock:SetHidden(isUnlocked)
        end

        local labelWidth = SKILL_ENTRY_LABEL_WIDTH
        
        local showIncrease = (displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE)
        local showDecrease = SKILLS_AND_ACTION_BAR_MANAGER:DoesSkillPointAllocationModeAllowDecrease()
        local showNew = (displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE)
        local indicatorWidth = SetupIndicatorsForSkill(control.leftIndicator, control.rightIndicator, skillData, showIncrease, showDecrease, showNew)
        labelWidth = labelWidth - indicatorWidth

        if displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE then
            --Current Binding Text
            if control.keybind then
                local keybindWidth = SetBindingTextForSkill(control.keybind, skillData)
                labelWidth = labelWidth - keybindWidth
            end
        end

        --Size the label to allow space for the keybind and decrease icon
        control.label:SetWidth(labelWidth)
    end

    function ZO_GamepadCompanionSkillEntryTemplate_Setup(control, skillEntry, selected, activated, displayView)
        local skillData = skillEntry.skillData
        local skillProgressionData = skillData:GetPointAllocatorProgressionData()
        local skillPointAllocator = skillData:GetPointAllocator()
        local isUnlocked = skillProgressionData:IsUnlocked()
        local isPurchased = skillPointAllocator:IsPurchased()

        --Icon
        local iconTexture = control.icon
        if displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE then
            if isPurchased then
                iconTexture:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
            else
                iconTexture:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
            end
        end

        local NOT_ADVISED = false
        SetupAbilityIconFrame(control, skillData:IsPassive(), skillData:IsActive(), NOT_ADVISED)

        --Label Color
        if displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE then
            if not skillEntry.isPreview and isPurchased then
                control.label:SetColor((selected and PURCHASED_COLOR or PURCHASED_UNSELECTED_COLOR):UnpackRGBA())
            end
        else
            control.label:SetColor(PURCHASED_COLOR:UnpackRGBA())
        end    

        --Lock Icon
        if control.lock then
            control.lock:SetHidden(isUnlocked)
        end

        local labelWidth = SKILL_ENTRY_LABEL_WIDTH
        local DONT_SHOW_INCREASE = false
        local DONT_SHOW_DECREASE = false
        local SHOW_NEW = true
        local indicatorWidth = SetupIndicatorsForSkill(control.leftIndicator, control.rightIndicator, skillData, DONT_SHOW_INCREASE, DONT_SHOW_DECREASE, SHOW_NEW)
        labelWidth = labelWidth - indicatorWidth

        if displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE then
            --Current Binding Text
            if control.keybind then
                local keybindWidth = SetBindingTextForSkill(control.keybind, skillData)
                labelWidth = labelWidth - keybindWidth
            end
        end

        --Size the label to allow space for the keybind and decrease icon
        control.label:SetWidth(labelWidth)
    end

    function ZO_GamepadSkillEntryPreviewRow_Setup(control, skillData)
        local skillProgressionData = skillData:GetPointAllocatorProgressionData()
        local skillPointAllocator = skillData:GetPointAllocator()
        local isUnlocked = skillProgressionData:IsUnlocked()
        local isPurchased = skillPointAllocator:IsPurchased()
        local isMorph = skillData:IsPlayerSkill() and skillData:IsActive() and skillProgressionData:IsMorph()

        --Icon
        local iconTexture = control.icon
        iconTexture:SetTexture(skillProgressionData:GetIcon())
        if isPurchased then
            iconTexture:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
        else
            iconTexture:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
        end

        SetupAbilityIconFrame(control, skillData:IsPassive(), skillData:IsActive(), skillProgressionData:IsAdvised())

        --Label
        control.label:SetText(skillProgressionData:GetDetailedGamepadName())
        local color = skillPointAllocator:IsPurchased() and ZO_SELECTED_TEXT or ZO_DISABLED_TEXT
        control.label:SetColor(color:UnpackRGBA())

        --Lock Icon
        control.lock:SetHidden(isUnlocked)

        -- indicator
        local labelWidth = SKILL_ENTRY_LABEL_WIDTH
        local NO_RIGHT_INDICATOR = nil
        local SHOW_INCREASE = true
        local showDecrease = SKILLS_AND_ACTION_BAR_MANAGER:DoesSkillPointAllocationModeAllowDecrease()
        local SHOW_NEW = true
        local indicatorWidth = SetupIndicatorsForSkill(control.leftIndicator, NO_RIGHT_INDICATOR, skillData, SHOW_INCREASE, showDecrease, SHOW_NEW)
        labelWidth = labelWidth - indicatorWidth

        local keybindWidth = SetBindingTextForSkill(control.keybind, skillData)
        labelWidth = labelWidth - keybindWidth

        --Size the label to allow space for the keybind and decrease icon
        control.label:SetWidth(labelWidth)
    end
end
