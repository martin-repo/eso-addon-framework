--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

--[[ Gamepad Visual Data Object ]]--
ZO_GamepadEntryData = ZO_DataSourceObject:Subclass()

function ZO_GamepadEntryData:New(...)
    local entryData = ZO_DataSourceObject.New(self)
    entryData:Initialize(...)
    return entryData
end

function ZO_GamepadEntryData:Initialize(text, icon, selectedIcon, highlight, isNew)
    self.text = text
    self.numIcons = 0
    self:AddIcon(icon, selectedIcon)
    self.highlight = highlight
    self:SetNew(isNew)
    self.fontScaleOnSelection = true
    self.alphaChangeOnSelection = false
    self.showBarEvenWhenUnselected = true
    self.enabled = true
    self.subLabelTemplate = "ZO_GamepadMenuEntrySubLabelTemplateMain"
end

function ZO_GamepadEntryData:InitializeInventoryVisualData(itemData)
    -- Need this on self so that it can be used for a compare by EqualityFunction in ParametricScrollList,
    -- SharedInventory modifies the dataSource's uniqueId before the GamepadEntryData is rebuilt,
    -- so by copying it over, we can still have access to the old one during the Equality check
    self.uniqueId = itemData.uniqueId
    self:SetDataSource(itemData)
    self:AddIcon(itemData.icon)
    if not itemData.questIndex then
        -- self.quality is deprecated, included here for addon backwards compatibility
        self:SetNameColors(self:GetColorsBasedOnQuality(self.displayQuality or self.quality))  --quest items are only white
    end
    self.cooldownIcon = itemData.icon or itemData.iconFile
    self:SetFontScaleOnSelection(false)    --item entries don't grow on selection
end

function ZO_GamepadEntryData:InitializeStoreVisualData(itemData)
    self:InitializeInventoryVisualData(itemData)
    if itemData.entryType == STORE_ENTRY_TYPE_ANTIQUITY_LEAD then
        -- self.quality is deprecated, included here for addon backwards compatibility
        self:SetNameColors(self:GetColorsBasedOnAntiquityQuality(self.displayQuality or self.quality))
    end
    self.meetsUsageRequirement = itemData.meetsRequirementsToBuy and itemData.meetsRequirementsToEquip
    self.currencyType1 = itemData.currencyType1
end

function ZO_GamepadEntryData:InitializeTradingHouseVisualData(itemData)
    self:InitializeInventoryVisualData(itemData)
    self:SetSubLabelColors(ZO_NORMAL_TEXT)
    self:SetShowUnselectedSublabels(true)
end

function ZO_GamepadEntryData:InitializeItemImprovementVisualData(bag, index, stackCount, displayQuality)
    self.bag = bag
    self.index = index
    self:SetStackCount(stackCount)
    self.displayQuality = displayQuality
    -- self.quality is deprecated, included here for addon backwards compatibility
    self.quality = displayQuality
    self:SetFontScaleOnSelection(false)    --item entries don't grow on selection

    if displayQuality then
        self:SetNameColors(self:GetColorsBasedOnQuality(displayQuality))
    else
       self:SetNameColors(ZO_NORMAL_TEXT)
    end
end

function ZO_GamepadEntryData:AddSubLabels(subLabels)
    for _, subLabel in ipairs(subLabels) do
        self:AddSubLabel(subLabel)
    end
end

function ZO_GamepadEntryData:InitializeImprovementKitVisualData(bag, index, stackCount, displayQuality, subLabels)
    self:InitializeItemImprovementVisualData(bag, index, stackCount, displayQuality)
    self:AddSubLabels(subLabels)
    self:SetSubLabelColors(ZO_NORMAL_TEXT)
end

function ZO_GamepadEntryData:InitializeCraftingInventoryVisualData(bagId, slotIndex, stackCount, customSortData, customBestCategoryNameFunction, slotData)
    self:SetStackCount(stackCount)
    self.bagId = bagId
    self.slotIndex = slotIndex

    local itemName = GetItemName(self.bagId, self.slotIndex)
    local icon, _, sellPrice, meetsUsageRequirements, _, _, _, functionalQuality, displayQuality = GetItemInfo(self.bagId, self.slotIndex)
    self:AddIcon(icon)
    self.pressedIcon = self.pressedIcon or icon
    self.sellPrice = sellPrice
    self.meetsUsageRequirement = meetsUsageRequirements
    self.functionalQuality = functionalQuality
    self.displayQuality = displayQuality
    -- self.quality is deprecated, included here for addon backwards compatibility
    self.quality = displayQuality
    self.itemType = GetItemType(self.bagId, self.slotIndex)
    self.customSortData = customSortData

    if slotData then
        ZO_ShallowTableCopy(slotData, self)
    end

    if customBestCategoryNameFunction then
        customBestCategoryNameFunction(self)
    else
        self.bestItemCategoryName = zo_strformat(GetString("SI_ITEMTYPE", self.itemType))
    end

    self:SetNameColors(self:GetColorsBasedOnQuality(self.displayQuality))
    self.subLabelSelectedColor = self.selectedNameColor

    self:SetFontScaleOnSelection(false)    --item entries don't grow on selection
end

local LOOT_QUEST_COLOR = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_TOOLTIP, ITEM_TOOLTIP_COLOR_QUEST_ITEM_NAME))
function ZO_GamepadEntryData:InitializeLootVisualData(lootId, count, displayQuality, value, isQuest, isStolen, lootType)
    self.lootId = lootId
    self:SetStackCount(count)
    self.displayQuality = displayQuality
    -- self.quality is deprecated, included here for addon backwards compatibility
    self.quality = displayQuality
    self.value = value
    self.isQuest = isQuest
    self.isStolen = isStolen
    self.lootType = lootType
    self:SetFontScaleOnSelection(false)    --item entries don't grow on selection

    if isQuest then
        self:SetNameColors(LOOT_QUEST_COLOR, LOOT_QUEST_COLOR)
    elseif lootType == LOOT_TYPE_ANTIQUITY_LEAD then
        self:SetNameColors(self:GetColorsBasedOnAntiquityQuality(displayQuality))
    elseif displayQuality then
        self:SetNameColors(self:GetColorsBasedOnQuality(displayQuality))
    else
       self:SetNameColors(ZO_NORMAL_TEXT)
    end
end

--[[ Setters for specific fields and options ]]--
function ZO_GamepadEntryData:SetHeader(header)
    self.header = header
end

function ZO_GamepadEntryData:GetHeader()
    return self.header
end

function ZO_GamepadEntryData:SetNew(isNew)
    self.brandNew = isNew
end

function ZO_GamepadEntryData:IsNew()
    if type(self.brandNew) == "function" then
        return self.brandNew(self)
    else
        return self.brandNew
    end
end

function ZO_GamepadEntryData:SetText(text)
    self.text = text
end

function ZO_GamepadEntryData:GetText()
    return self.text
end

function ZO_GamepadEntryData:SetFontScaleOnSelection(active)
    self.fontScaleOnSelection = active
end

function ZO_GamepadEntryData:SetAlphaChangeOnSelection(active)
    self.alphaChangeOnSelection = active
end

function ZO_GamepadEntryData:SetMaxIconAlpha(alpha)
    self.maxIconAlpha = alpha
end

function ZO_GamepadEntryData:SetIgnoreTraitInformation(ignoreTraitInformation)
    self.ignoreTraitInformation = ignoreTraitInformation
end

function ZO_GamepadEntryData:GetColorsBasedOnQuality(displayQuality)
    local selectedNameColor = GetItemQualityColor(displayQuality)
    local unselectedNameColor = GetDimItemQualityColor(displayQuality)

    return selectedNameColor, unselectedNameColor
end

function ZO_GamepadEntryData:GetColorsBasedOnAntiquityQuality(antiquityQuality)
    local selectedNameColor = GetAntiquityQualityColor(antiquityQuality)
    local unselectedNameColor = GetDimAntiquityQualityColor(antiquityQuality)

    return selectedNameColor, unselectedNameColor
end

function ZO_GamepadEntryData:SetCooldown(remainingMs, durationMs)
    self.timeCooldownRecordedMs = GetFrameTimeMilliseconds()
    self.cooldownRemainingMs = remainingMs
    self.cooldownDurationMs = durationMs
end

function ZO_GamepadEntryData:GetCooldownDurationMs()
    return self.cooldownDurationMs or 0
end

function ZO_GamepadEntryData:GetCooldownTimeRemainingMs()
    if self.timeCooldownRecordedMs and self.cooldownRemainingMs then
        local timeOffsetMs = GetFrameTimeMilliseconds() - self.timeCooldownRecordedMs
        return self.cooldownRemainingMs - timeOffsetMs
    end
    return 0
end

function ZO_GamepadEntryData:IsOnCooldown()
    return self:GetCooldownDurationMs() > 0 and self:GetCooldownTimeRemainingMs() > 0
end

function ZO_GamepadEntryData:AddIconSubtype(subtypeName, texture)
    if texture then
        if not self[subtypeName] then
            self[subtypeName] = {}
            for i = 1, self.numIcons do
                table.insert(self[subtypeName], false)
            end
        end
        table.insert(self[subtypeName], texture)
    end
end

function ZO_GamepadEntryData:GetNumIcons()
    return self.numIcons
end

function ZO_GamepadEntryData:GetSubtypeIcon(subtypeName, index)
    if self[subtypeName] then
        return self[subtypeName][index] or nil
    end
end

function ZO_GamepadEntryData:GetIcon(index, selected)
    if selected then
        local selectedIcon = self:GetSubtypeIcon("iconsSelected", index)
        if selectedIcon then
            return selectedIcon
        end
    end

    return self:GetSubtypeIcon("iconsNormal", index)
end

function ZO_GamepadEntryData:AddIcon(normalTexture, selectedTexture)
    if normalTexture or selectedTexture then
        self:AddIconSubtype("iconsNormal", normalTexture)
        self:AddIconSubtype("iconsSelected", selectedTexture)
        self.numIcons = self.numIcons + 1
    end
end

function ZO_GamepadEntryData:ClearIcons()
    if self.iconsNormal then
        ZO_ClearNumericallyIndexedTable(self.iconsNormal)
    end
    if self.iconsSelected then
        ZO_ClearNumericallyIndexedTable(self.iconsSelected)
    end
end

function ZO_GamepadEntryData:GetNameColor(selected)
    if self.enabled then
        if selected then
            return self.selectedNameColor or ZO_GAMEPAD_SELECTED_COLOR
        else
            return self.unselectedNameColor or ZO_GAMEPAD_UNSELECTED_COLOR
        end
    else
        return self:GetNameDisabledColor(selected)
    end
end

function ZO_GamepadEntryData:SetIconTintOnSelection(selected)
    self:SetIconTint(selected and ZO_GAMEPAD_SELECTED_COLOR, selected and ZO_GAMEPAD_UNSELECTED_COLOR)
end

function ZO_GamepadEntryData:GetSubLabelColor(selected)
    if selected then
        return self.selectedSubLabelColor or ZO_GAMEPAD_SELECTED_COLOR
    else
        return self.unselectedSubLabelColor or ZO_GAMEPAD_UNSELECTED_COLOR
    end
end

function ZO_GamepadEntryData:SetNameColors(selectedColor, unselectedColor)
    self.selectedNameColor = selectedColor
    self.unselectedNameColor = unselectedColor
end

function ZO_GamepadEntryData:SetSubLabelColors(selectedColor, unselectedColor)
    self.selectedSubLabelColor = selectedColor
    self.unselectedSubLabelColor = unselectedColor
end

function ZO_GamepadEntryData:GetSubLabelTemplate()
    return self.subLabelTemplate
end

function ZO_GamepadEntryData:SetSubLabelTemplate(template)
    self.subLabelTemplate = template
end

function ZO_GamepadEntryData:SetIconTint(selectedColor, unselectedColor)
    self.selectedIconTint = selectedColor
    self.unselectedIconTint = unselectedColor
end

-- If this is set for one data entry in a list for a given data type, it must be set for all entries in that list for that data type
-- Otherwise it will not be reset when the control gets recycled
function ZO_GamepadEntryData:SetIconDesaturation(desaturation)
    self.iconDesaturation = desaturation
end

-- See comment for SetIconDesaturation
function ZO_GamepadEntryData:SetIconSampleProcessingWeight(type, weight)
    if not self.textureSampleProcessingWeights then
        self.textureSampleProcessingWeights = {}
    end
    self.textureSampleProcessingWeights[type] = weight
end

-- See comment for SetIconDesaturation
function ZO_GamepadEntryData:SetIconSampleProcessingWeightTable(typeToWeightTable)
    self.textureSampleProcessingWeights = typeToWeightTable
end

-- See comment for SetIconDesaturation
function ZO_GamepadEntryData:SetIconColor(color)
    self.iconColor = color
end

function ZO_GamepadEntryData:AddSubLabel(text)
    if not self.subLabels then
        self.subLabels = {}
    end
    table.insert(self.subLabels, text)
end

function ZO_GamepadEntryData:ClearSubLabels()
    if self.subLabels then
        ZO_ClearNumericallyIndexedTable(self.subLabels)
    end
end

function ZO_GamepadEntryData:SetShowUnselectedSublabels(showUnselectedSublabels)
    self.showUnselectedSublabels = showUnselectedSublabels
end

function ZO_GamepadEntryData:SetChannelActive(isChannelActive)
    self.isChannelActive = isChannelActive
end

function ZO_GamepadEntryData:SetLocked(isLocked)
    self.isLocked = isLocked
end

function ZO_GamepadEntryData:SetSelected(isSelected)
    self.isSelected = isSelected
end

function ZO_GamepadEntryData:SetChannelActive(isChannelActive)
    self.isChannelActive = isChannelActive
end

-- Functions for displaying an entry as disabled

function ZO_GamepadEntryData:SetEnabled(isEnabled)
    self.enabled = isEnabled
end

function ZO_GamepadEntryData:IsEnabled()
    return self.enabled
end

function ZO_GamepadEntryData:SetDisabledNameColors(selectedColor, unselectedColor)
    self.selectedNameDisabledColor = selectedColor
    self.unselectedNameDisabledColor = unselectedColor
end

function ZO_GamepadEntryData:SetDisabledIconTint(selectedColor, unselectedColor)
    self.selectedIconDisabledTint = selectedColor
    self.unselectedIconDisabledTint = unselectedColor
end

function ZO_GamepadEntryData:GetNameDisabledColor(selected)
    if selected then
        return self.selectedNameDisabledColor or ZO_GAMEPAD_DISABLED_SELECTED_COLOR
    else
        return self.unselectedNameDisabledColor or ZO_GAMEPAD_DISABLED_UNSELECTED_COLOR
    end
end

function ZO_GamepadEntryData:SetIconDisabledTintOnSelection(selected)
    self:SetDisabledIconTint(selected and ZO_GAMEPAD_DISABLED_SELECTED_COLOR, selected and ZO_GAMEPAD_DISABLED_UNSELECTED_COLOR)
end

function ZO_GamepadEntryData:SetModifyTextType(modifyTextType)
    self.modifyTextType = modifyTextType
end

function ZO_GamepadEntryData:SetIsHiddenByWardrobe(isHidden)
    self.isHiddenByWardrobe = isHidden
end

function ZO_GamepadEntryData:SetStackCount(stackCount)
    self.stackCount = stackCount
end

function ZO_GamepadEntryData:SetCooldownIcon(icon)
    self.cooldownIcon = icon
end

function ZO_GamepadEntryData:SetCanLevel(canLevel)
    self.canLevel = canLevel
end

function ZO_GamepadEntryData:CanLevel()
    if self.canLevel then
        if type(self.canLevel) == "function" then
            return self.canLevel()
        else
            return self.canLevel
        end
    else
        return false
    end
end

function ZO_GamepadEntryData:SetBarValues(min, max, value)
    self.barMin = min
    self.barMax = max
    self.barValue = value
end

function ZO_GamepadEntryData:SetShowBarEvenWhenUnselected(showBarEvenWhenUnselected)
    self.showBarEvenWhenUnselected = showBarEvenWhenUnselected
end
