--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local QUEST_BULLET_ICON = "EsoUI/Art/Miscellaneous/Gamepad/gp_bullet.dds"
-- TODO: These icons may need to be shifted to gamepad icons.
local GROUP_LEADER_ICON = "EsoUI/Art/Compass/groupLeader.dds"
local CURRENT_PLAYER_ICON = "EsoUI/Art/Icons/mapKey/mapKey_player.dds"
local GROUP_MEMBER_ICON = "EsoUI/Art/Icons/mapKey/mapKey_groupMember.dds"
local COMPANION_ICON = "EsoUI/Art/MapPins/activeCompanion_pin.dds"

local TOOLTIP_MONEY_FORMAT

--Section Generators
ZO_MapInformationTooltip_Gamepad_Mixin = {}

function ZO_MapInformationTooltip_Gamepad_Mixin:LayoutIconStringLine(baseSection, icon, string, ...)
    local lineSection = baseSection:AcquireSection(self.tooltip:GetStyle("mapLocationTooltipContentSection"))

    local iconStyle
    if icon then
        iconStyle = self.tooltip:GetStyle("mapLocationTooltipIcon")
    else
        iconStyle = self.tooltip:GetStyle("mapLocationTooltipNoIcon")
    end
    lineSection:AddTexture(icon, iconStyle, ...)

    lineSection:AddLine(string, self.tooltip:GetStyle("mapLocationTooltipContentLabel"), ...)
    baseSection:AddSection(lineSection)
end

function ZO_MapInformationTooltip_Gamepad_Mixin:LayoutLargeIconStringLine(baseSection, icon, string, ...)
    local iconStyle
    if not icon then
        iconStyle = self.tooltip:GetStyle("mapLocationTooltipNoIcon")
    else
        iconStyle = self.tooltip:GetStyle("mapLocationTooltipLargeIcon")
    end

    local lineSection = baseSection:AcquireSection(self.tooltip:GetStyle("mapLocationTooltipContentSection"))
    lineSection:AddTexture(icon, iconStyle, ...)
    lineSection:AddLine(string, self.tooltip:GetStyle("mapLocationTooltipContentLabel"), ...)
    baseSection:AddSection(lineSection)
end

function ZO_MapInformationTooltip_Gamepad_Mixin:LayoutStringLine(baseSection, string, ...)
    local lineSection = baseSection:AcquireSection(self.tooltip:GetStyle("mapLocationTooltipContentSection"))
    lineSection:AddLine(string, self.tooltip:GetStyle("mapLocationTooltipContentLabel"), ...)
    baseSection:AddSection(lineSection)
end

function ZO_MapInformationTooltip_Gamepad_Mixin:LayoutIconStringRightStringLine(baseSection, icon, string, rightString, ...)
    local iconStyle
    if not icon then
        iconStyle = self.tooltip:GetStyle("mapLocationTooltipNoIcon")
    else
        iconStyle = self.tooltip:GetStyle("mapLocationTooltipIcon")
    end

    local lineSection = baseSection:AcquireSection(self.tooltip:GetStyle("mapLocationTooltipContentSection"))
    lineSection:AddTexture(icon, iconStyle, ...)
    lineSection:AddLine(string, self.tooltip:GetStyle("mapLocationTooltipContentLeftLabel"), ...)
    lineSection:AddLine(rightString, self.tooltip:GetStyle("mapLocationTooltipContentRightLabel"), ...)
    baseSection:AddSection(lineSection)
end

function ZO_MapInformationTooltip_Gamepad_Mixin:LayoutGroupHeader(baseSection, icon, string, ...)
    local iconStyle
    if not icon then
        iconStyle = self.tooltip:GetStyle("mapLocationTooltipNoIcon")
    else
        iconStyle = self.tooltip:GetStyle("mapLocationTooltipIcon")
    end

    local lineSection = baseSection:AcquireSection(self.tooltip:GetStyle("mapLocationTooltipContentSection"))
    lineSection:AddTexture(icon, iconStyle)
    local textSection = lineSection:AcquireSection(self.tooltip:GetStyle("mapLocationHeaderTextSection"))
    textSection:AddLine(string, self.tooltip:GetStyle("mapLocationTooltipContentLabel"), ...)
    lineSection:AddSection(textSection)
    baseSection:AddSection(lineSection)
end

function ZO_MapInformationTooltip_Gamepad_Mixin:AppendUnitName(unitTag)
    local icon
    local isGrouped = IsUnitGrouped(unitTag)
    local isPlayer = unitTag == "player"
    local isCompanion = unitTag == "companion"
    if isGrouped and IsUnitGroupLeader(unitTag) then
        icon = GROUP_LEADER_ICON
    elseif isPlayer then
        icon = CURRENT_PLAYER_ICON
    elseif isGrouped then
        icon = GROUP_MEMBER_ICON
    elseif isCompanion then
        icon = COMPANION_ICON
    end

    local colorStyle
    if isGrouped or isPlayer then
        colorStyle = self.tooltip:GetStyle("mapAllyUnitName")
    else
        colorStyle =
        {
            fontColorType = INTERFACE_COLOR_TYPE_UNIT_REACTION_COLOR,
            fontColorField = GetUnitReactionColorType(unitTag),
        }
    end

    local text = GenerateUnitNameTooltipLine(unitTag)
    if icon then
        self:LayoutIconStringLine(self.tooltip, icon, ZO_FormatUserFacingDisplayName(text), colorStyle, self.tooltip:GetStyle("keepBaseTooltipContent"))
    else
        self:LayoutStringLine(self.tooltip, ZO_FormatUserFacingDisplayName(text), colorStyle, self.tooltip:GetStyle("keepBaseTooltipContent"))
    end
end

function ZO_MapInformationTooltip_Gamepad_Mixin:AppendQuestEnding(questIndex)
    local isFocusedQuest = GetTrackedIsAssisted(TRACK_TYPE_QUEST, questIndex)
    local colorStyle = self.tooltip:GetStyle(isFocusedQuest and "mapQuestFocused" or "mapQuestNonFocused")

    local text = GenerateQuestEndingTooltipLine(questIndex)
    self:LayoutIconStringLine(self.tooltip, QUEST_BULLET_ICON, text, colorStyle, self.tooltip:GetStyle("keepBaseTooltipContent"))
end

function ZO_MapInformationTooltip_Gamepad_Mixin:AppendQuestCondition(questIndex, stepIndex, conditionIndex)
    local isFocusedQuest = GetTrackedIsAssisted(TRACK_TYPE_QUEST, questIndex)
    local colorStyle = self.tooltip:GetStyle(isFocusedQuest and "mapQuestFocused" or "mapQuestNonFocused")

    local text = GenerateQuestConditionTooltipLine(questIndex, stepIndex, conditionIndex)

    if text ~= "" then
        self:LayoutIconStringLine(self.tooltip, QUEST_BULLET_ICON, text, colorStyle, self.tooltip:GetStyle("keepBaseTooltipContent"))
    end
end

function ZO_MapInformationTooltip_Gamepad_Mixin:AppendMapPing(pinType, unitTag)
    local text = GenerateMapPingTooltipLine(pinType, unitTag)
    self:LayoutIconStringLine(self.tooltip, nil, text, self.tooltip:GetStyle("keepBaseTooltipContent"))
end

function ZO_MapInformationTooltip_Gamepad_Mixin:AppendAvAObjective(queryType, keepId, objectiveId, objectivePinTier)
    local text, interfaceColorType, color = GenerateAvAObjectiveConditionTooltipLine(queryType, keepId, objectiveId, objectivePinTier)
    local objectiveColorStyle =
    {
        fontColorType = interfaceColorType,
        fontColorField = color,
    }
    self:LayoutIconStringLine(self.tooltip, nil, text, objectiveColorStyle, self.tooltip:GetStyle("keepBaseTooltipContent"))
end

function ZO_MapInformationTooltip_Gamepad_Mixin:AddMoney(baseSection, amount, reason, notEnough, ...)
    -- Lazy setup of the local money format as the global one is not available at the time this file is loaded.
    if not TOOLTIP_MONEY_FORMAT then
        TOOLTIP_MONEY_FORMAT = ZO_ShallowTableCopy(ZO_GAMEPAD_CURRENCY_OPTIONS_LONG_FORMAT)
        TOOLTIP_MONEY_FORMAT.font = "ZoFontGamepad42"
        TOOLTIP_MONEY_FORMAT.iconSize = 40
    end

    local lineSection = baseSection:AcquireSection(self.tooltip:GetStyle("mapLocationTooltipDoubleContentSection"))
    lineSection:AddTexture(nil, self.tooltip:GetStyle("mapLocationTooltipNoIcon"))
    if reason then
        lineSection:AddLine(reason, ...)
    end
    if amount > 0 then
        lineSection:AddSimpleCurrency(CURT_MONEY, amount, TOOLTIP_MONEY_FORMAT, CURRENCY_DONT_SHOW_ALL, notEnough, ...)
    end
    baseSection:AddSection(lineSection)
end

function ZO_MapInformationTooltip_Gamepad_Mixin:AppendWayshrineTooltip(pin)
    local wayshrineSection = self.tooltip:AcquireSection(self.tooltip:GetStyle("mapLocationTooltipSection"))

    local nodeIndex = pin:GetFastTravelNodeIndex()
    local known, name, _, _, icon, glowIcon, poiType, isShown, linkedCollectibleIsLocked = GetFastTravelNodeInfo(nodeIndex) --TODO: Implement a tooltip for linkedCollectibleIsLocked

    self:LayoutIconStringLine(wayshrineSection, icon, zo_strformat(SI_WORLD_MAP_LOCATION_NAME, name), self.tooltip:GetStyle("mapLocationTooltipWayshrineHeader"))

    local currentNodeIndex = ZO_Map_GetFastTravelNode()
    local isCurrentLoc = (currentNodeIndex == nodeIndex)
    local isUsingRecall = currentNodeIndex == nil
    local isOutboundOnly, outboundOnlyErrorStringId = GetFastTravelNodeOutboundOnlyInfo(nodeIndex)
    local nodeIsHousePreview = poiType == POI_TYPE_HOUSE and not HasCompletedFastTravelNodePOI(nodeIndex)

    if isCurrentLoc then --NO BUTTON: Can't travel to origin
        self:LayoutIconStringLine(wayshrineSection, nil, zo_strformat(SI_TOOLTIP_WAYSHRINE_CURRENT_LOC, name), self.tooltip:GetStyle("mapKeepAt"), self.tooltip:GetStyle("keepBaseTooltipContent"))
    elseif isUsingRecall and IsInCampaign() then --NO BUTTON: Can't recall while inside AvA zone
        self:LayoutIconStringLine(wayshrineSection, nil, zo_strformat(SI_TOOLTIP_WAYSHRINE_CANT_RECALL_AVA, name), self.tooltip:GetStyle("mapKeepInaccessible"), self.tooltip:GetStyle("keepBaseTooltipContent"))
    elseif isOutboundOnly then --NO BUTTON: Can't travel to this wayshrine, only from it
        local message = GetErrorString(outboundOnlyErrorStringId)
        self:LayoutIconStringLine(wayshrineSection, nil, message, self.tooltip:GetStyle("mapKeepInaccessible"), self.tooltip:GetStyle("keepBaseTooltipContent"))
    elseif not CanLeaveCurrentLocationViaTeleport() then --NO BUTTON: Current Zone or Subzone restricts jumping
        local cantLeaveStringId
        if IsInOutlawZone() then
            cantLeaveStringId = SI_TOOLTIP_WAYSHRINE_CANT_RECALL_OUTLAW_REFUGE
        else
            cantLeaveStringId = SI_TOOLTIP_WAYSHRINE_CANT_RECALL_FROM_LOCATION
        end
        self:LayoutIconStringLine(wayshrineSection, nil, GetString(cantLeaveStringId), self.tooltip:GetStyle("mapKeepInaccessible"), self.tooltip:GetStyle("keepBaseTooltipContent"))
    elseif pin:IsLockedByLinkedCollectible() then --BUTTON: Open the store/Upgrade Chapter
        local currencyIcon
        if pin:GetLinkedCollectibleType() == COLLECTIBLE_CATEGORY_TYPE_DLC then
            currencyIcon = ZO_Currency_GetGamepadCurrencyIcon(CURT_CROWNS)
        end
        self:LayoutIconStringLine(wayshrineSection, currencyIcon, ZO_WorldMap_GetWayshrineTooltipCollectibleLockedText(pin), self.tooltip:GetStyle("mapLocationTooltipWayshrineLinkedCollectibleLockedText"))
    elseif IsUnitDead("player") then -- NO BUTTON: Dead
        local message = GetString(SI_TOOLTIP_WAYSHRINE_CANT_RECALL_WHEN_DEAD)
        self:LayoutIconStringLine(wayshrineSection, nil, message, self.tooltip:GetStyle("mapKeepInaccessible"), self.tooltip:GetStyle("keepBaseTooltipContent"))
    elseif isUsingRecall then --Recall
        local keyText = ZO_Keybindings_GenerateIconKeyMarkup(KEY_GAMEPAD_BUTTON_1)
        local travelStringId = nodeIsHousePreview and SI_GAMEPAD_TOOLTIP_WAYSHRINE_PREVIEW_HOUSE_INTERACT or SI_GAMEPAD_TOOLTIP_WAYSHRINE_RECALL_INTERACT
        local travelText = zo_strformat(travelStringId, keyText)
        self:LayoutIconStringLine(wayshrineSection, nil, travelText, self.tooltip:GetStyle("mapKeepAccessible"), self.tooltip:GetStyle("keepBaseTooltipContent"))

        local _, premiumTimeLeft = GetRecallCooldown()
        if premiumTimeLeft == 0 then --BUTTON: Recall
            local cost = GetRecallCost(nodeIndex)
            if cost > 0 then
                local currency = GetRecallCurrency(nodeIndex)
                local hasEnoughMoney = (cost <= GetCurrencyAmount(currency, CURRENCY_LOCATION_CHARACTER))
                self:AddMoney(wayshrineSection, cost, GetString(SI_GAMEPAD_WORLD_MAP_TOOLTIP_RECALL_COST), not hasEnoughMoney, self.tooltip:GetStyle("mapLocationTooltipContentLeftLabel"), self.tooltip:GetStyle("mapRecallCost"))
            end
        else --NO BUTTON: Waiting on cooldown
            local cooldownText = zo_strformat(SI_TOOLTIP_WAYSHRINE_RECALL_COOLDOWN, ZO_FormatTimeMilliseconds(premiumTimeLeft, TIME_FORMAT_STYLE_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS))
            self:LayoutIconStringLine(wayshrineSection, nil, cooldownText, self.tooltip:GetStyle("mapKeepInaccessible"), self.tooltip:GetStyle("keepBaseTooltipContent"))
        end
    else --BUTTON: Fast Travel
        local keyText = ZO_Keybindings_GenerateIconKeyMarkup(KEY_GAMEPAD_BUTTON_1)
        local travelStringId = nodeIsHousePreview and SI_GAMEPAD_TOOLTIP_WAYSHRINE_PREVIEW_HOUSE_INTERACT or SI_GAMEPAD_TOOLTIP_WAYSHRINE_FAST_TRAVEL_INTERACT
        local travelText = zo_strformat(travelStringId, keyText)
        self:LayoutIconStringLine(wayshrineSection, nil, travelText, self.tooltip:GetStyle("mapKeepAccessible"), self.tooltip:GetStyle("keepBaseTooltipContent"))
    end

    self.tooltip:AddSection(wayshrineSection)
end

function ZO_MapInformationTooltip_Gamepad_Mixin:AppendSuggestionActivity(pin)
    local shortDescription = pin:GetShortDescription()
    if shortDescription then
        self:LayoutIconStringLine(self.tooltip, QUEST_BULLET_ICON, shortDescription, self.tooltip:GetStyle("keepBaseTooltipContent"))
    end
end

function ZO_MapInformationTooltip_Gamepad_Mixin:LayoutKeepUpgrade(name, description)
    local keepUpgradeSection = self.tooltip:AcquireSection(self.tooltip:GetStyle("keepInfoSection"))
    self:LayoutStringLine(keepUpgradeSection, name, self.tooltip:GetStyle("mapTitle"))
    self:LayoutStringLine(keepUpgradeSection, description, self.tooltip:GetStyle("keepUpgradeTooltipContent"))
    self.tooltip:AddSection(keepUpgradeSection)
end

function ZO_MapInformationTooltip_Gamepad_Mixin:AppendDigSiteAntiquities(digSiteId)
    local antiquityIds = { GetInProgressAntiquitiesForDigSite(digSiteId) }
    local antiquitiesSection = self.tooltip:AcquireSection(self.tooltip:GetStyle("keepInfoSection"))
    for index, antiquityId in ipairs(antiquityIds) do
        local antiquityData = ANTIQUITY_DATA_MANAGER:GetAntiquityData(antiquityId)
        if antiquityData then
            local antiquityName = antiquityData:GetName()
            local colorDef = GetAntiquityQualityColor(antiquityData:GetQuality())
            local coloredAntiquityName = colorDef:Colorize(antiquityName)
            local digSiteString = zo_strformat(SI_ANTIQUITY_DIG_SITE_MAP_TOOLTIP, coloredAntiquityName)
            self:LayoutStringLine(antiquitiesSection, digSiteString, self.tooltip:GetStyle("keepBaseTooltipContent"))
        end
    end
    self.tooltip:AddSection(antiquitiesSection)
end
