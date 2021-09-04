--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

--Section Generators

function ZO_Tooltip:AddAbilityProgressBar(currentXP, lastRankXP, nextRankXP)
    local bar = self:AcquireStatusBar(self:GetStyle("abilityProgressBar"))
    if nextRankXP == 0 then
        bar:SetMinMax(0, 1)
        bar:SetValue(1)
    else
        bar:SetMinMax(0, nextRankXP - lastRankXP)
        bar:SetValue(currentXP - lastRankXP)
    end
    self:AddStatusBar(bar)
end

do
    local TANK_ROLE_ICON = zo_iconFormat("EsoUI/Art/LFG/LFG_tank_down_no_glow_64.dds", 40, 40)
    local HEALER_ROLE_ICON = zo_iconFormat("EsoUI/Art/LFG/LFG_healer_down_no_glow_64.dds", 40, 40)
    local DAMAGE_ROLE_ICON = zo_iconFormat("EsoUI/Art/LFG/LFG_dps_down_no_glow_64.dds", 40, 40)
    local g_roleIconTable = {}

    function ZO_Tooltip:AddAbilityStats(abilityId, overrideActiveRank, overrideCasterUnitTag)
        local statsSection = self:AcquireSection(self:GetStyle("abilityStatsSection"))

        --Cast Time
        local channeled, castTime, channelTime = GetAbilityCastInfo(abilityId, overrideActiveRank, overrideCasterUnitTag)
        local castTimePair = statsSection:AcquireStatValuePair(self:GetStyle("statValuePair"))
        if channeled then
            castTimePair:SetStat(GetString(SI_ABILITY_TOOLTIP_CHANNEL_TIME_LABEL), self:GetStyle("statValuePairStat"))
            castTimePair:SetValue(ZO_FormatTimeMilliseconds(channelTime, TIME_FORMAT_STYLE_CHANNEL_TIME, TIME_FORMAT_PRECISION_TENTHS_RELEVANT, TIME_FORMAT_DIRECTION_NONE), self:GetStyle("abilityStatValuePairValue"))
        else
            castTimePair:SetStat(GetString(SI_ABILITY_TOOLTIP_CAST_TIME_LABEL), self:GetStyle("statValuePairStat"))
            castTimePair:SetValue(ZO_FormatTimeMilliseconds(castTime, TIME_FORMAT_STYLE_CAST_TIME, TIME_FORMAT_PRECISION_TENTHS_RELEVANT, TIME_FORMAT_DIRECTION_NONE), self:GetStyle("abilityStatValuePairValue"))
        end
        statsSection:AddStatValuePair(castTimePair)

        --Target
        local targetDescription = GetAbilityTargetDescription(abilityId, overrideActiveRank, overrideCasterUnitTag)
        if targetDescription then
            local targetPair = statsSection:AcquireStatValuePair(self:GetStyle("statValuePair"))
            targetPair:SetStat(GetString(SI_ABILITY_TOOLTIP_TARGET_TYPE_LABEL), self:GetStyle("statValuePairStat"))
            targetPair:SetValue(targetDescription, self:GetStyle("abilityStatValuePairValue"))
            statsSection:AddStatValuePair(targetPair)
        end

        --Range
        local minRangeCM, maxRangeCM = GetAbilityRange(abilityId, overrideActiveRank, overrideCasterUnitTag)
        if maxRangeCM > 0 then
            local rangePair = statsSection:AcquireStatValuePair(self:GetStyle("statValuePair"))
            rangePair:SetStat(GetString(SI_ABILITY_TOOLTIP_RANGE_LABEL), self:GetStyle("statValuePairStat"))
            if minRangeCM == 0 then
                rangePair:SetValue(zo_strformat(SI_ABILITY_TOOLTIP_RANGE, FormatFloatRelevantFraction(maxRangeCM / 100)), self:GetStyle("abilityStatValuePairValue"))
            else
                rangePair:SetValue(zo_strformat(SI_ABILITY_TOOLTIP_MIN_TO_MAX_RANGE, FormatFloatRelevantFraction(minRangeCM / 100), FormatFloatRelevantFraction(maxRangeCM / 100)), self:GetStyle("abilityStatValuePairValue"))
            end
            statsSection:AddStatValuePair(rangePair)
        end

        --Radius/Distance
        local radiusCM = GetAbilityRadius(abilityId, overrideActiveRank, overrideCasterUnitTag)
        local angleDistanceCM = GetAbilityAngleDistance(abilityId)
        if radiusCM > 0 then
            local radiusDistancePair = statsSection:AcquireStatValuePair(self:GetStyle("statValuePair"))
            if angleDistanceCM > 0 then
                radiusDistancePair:SetStat(GetString(SI_ABILITY_TOOLTIP_AREA_LABEL), self:GetStyle("statValuePairStat"))
                -- Angle distance is the distance to the left and right of the caster, not total distance. So we're multiplying by 2 to accurately reflect that in the UI.
                radiusDistancePair:SetValue(zo_strformat(SI_ABILITY_TOOLTIP_AOE_DIMENSIONS, FormatFloatRelevantFraction(radiusCM / 100), FormatFloatRelevantFraction(angleDistanceCM * 2 / 100)), self:GetStyle("abilityStatValuePairValue"))
            else
                radiusDistancePair:SetStat(GetString(SI_ABILITY_TOOLTIP_RADIUS_LABEL), self:GetStyle("statValuePairStat"))
                radiusDistancePair:SetValue(zo_strformat(SI_ABILITY_TOOLTIP_RADIUS, FormatFloatRelevantFraction(radiusCM / 100)), self:GetStyle("abilityStatValuePairValue")) 
            end
            statsSection:AddStatValuePair(radiusDistancePair)
        end

        --Duration
        if IsAbilityDurationToggled(abilityId) then
            local durationPair = statsSection:AcquireStatValuePair(self:GetStyle("statValuePair"))
            durationPair:SetStat(GetString(SI_ABILITY_TOOLTIP_DURATION_LABEL), self:GetStyle("statValuePairStat"))
            durationPair:SetValue(GetString(SI_ABILITY_TOOLTIP_TOGGLE_DURATION), self:GetStyle("abilityStatValuePairValue"))
            statsSection:AddStatValuePair(durationPair)
        else
            local durationMS = GetAbilityDuration(abilityId, overrideActiveRank, overrideCasterUnitTag)
            if durationMS > 0 then
                local durationPair = statsSection:AcquireStatValuePair(self:GetStyle("statValuePair"))
                durationPair:SetStat(GetString(SI_ABILITY_TOOLTIP_DURATION_LABEL), self:GetStyle("statValuePairStat"))
                durationPair:SetValue(ZO_FormatTimeMilliseconds(durationMS, TIME_FORMAT_STYLE_DURATION, TIME_FORMAT_PRECISION_TENTHS_RELEVANT, TIME_FORMAT_DIRECTION_NONE), self:GetStyle("abilityStatValuePairValue"))
                statsSection:AddStatValuePair(durationPair)
            end
        end

        --Cooldown
        local cooldownMS = GetAbilityCooldown(abilityId, overrideCasterUnitTag)
        if cooldownMS > 0 then
            local cooldownPair = statsSection:AcquireStatValuePair(self:GetStyle("statValuePair"))
            cooldownPair:SetStat(GetString(SI_ABILITY_TOOLTIP_COOLDOWN), self:GetStyle("statValuePairStat"))
            cooldownPair:SetValue(ZO_FormatTimeMilliseconds(cooldownMS, TIME_FORMAT_STYLE_DURATION, TIME_FORMAT_PRECISION_TENTHS_RELEVANT, TIME_FORMAT_DIRECTION_NONE), self:GetStyle("abilityStatValuePairValue"))
            statsSection:AddStatValuePair(cooldownPair)
        end

        --Cost
        local cost, mechanic = GetAbilityCost(abilityId, overrideActiveRank)
        if cost > 0 then
            local costPair = statsSection:AcquireStatValuePair(self:GetStyle("statValuePair"))
            costPair:SetStat(GetString(SI_ABILITY_TOOLTIP_RESOURCE_COST_LABEL), self:GetStyle("statValuePairStat"))
            local mechanicName = GetString("SI_COMBATMECHANICTYPE", mechanic)
            local costString = zo_strformat(SI_ABILITY_TOOLTIP_RESOURCE_COST, cost, mechanicName)
            if mechanic == POWERTYPE_MAGICKA then
                costPair:SetValue(costString, self:GetStyle("abilityStatValuePairMagickaValue"))
            elseif mechanic == POWERTYPE_STAMINA then
                costPair:SetValue(costString, self:GetStyle("abilityStatValuePairStaminaValue"))
            elseif mechanic == POWERTYPE_HEALTH then
                costPair:SetValue(costString, self:GetStyle("abilityStatValuePairHealthValue"))
            else
                costPair:SetValue(costString, self:GetStyle("abilityStatValuePairValue"))
            end
            statsSection:AddStatValuePair(costPair)
        end

        local chargeFrequencyMS
        cost, mechanic, chargeFrequencyMS = GetAbilityCostOverTime(abilityId, overrideActiveRank)
        if cost > 0 then
            local costPair = statsSection:AcquireStatValuePair(self:GetStyle("statValuePair"))
            costPair:SetStat(GetString(SI_ABILITY_TOOLTIP_RESOURCE_COST_LABEL), self:GetStyle("statValuePairStat"))

            local mechanicName = GetString("SI_COMBATMECHANICTYPE", mechanic)

            if mechanic == POWERTYPE_MAGICKA or mechanic == POWERTYPE_STAMINA or mechanic == POWERTYPE_HEALTH then
                local mechanicColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER, mechanic))
                cost = mechanicColor:Colorize(cost)
                mechanicName = mechanicColor:Colorize(mechanicName)
            end

            local formattedChargeFrequency = ZO_FormatTimeMilliseconds(chargeFrequencyMS, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT, TIME_FORMAT_PRECISION_TENTHS_RELEVANT, TIME_FORMAT_DIRECTION_NONE)
            local costOverTimeString = zo_strformat(SI_ABILITY_TOOLTIP_RESOURCE_COST_OVER_TIME, cost, mechanicName, formattedChargeFrequency)
            

            costPair:SetValue(costOverTimeString, self:GetStyle("abilityStatValuePairValue"))

            statsSection:AddStatValuePair(costPair)
        end

        --Roles
        local isTankRole, isHealerRole, isDamageRole = GetAbilityRoles(abilityId)
        if isTankRole then
            table.insert(g_roleIconTable, TANK_ROLE_ICON)
        end
        if isHealerRole then
            table.insert(g_roleIconTable, HEALER_ROLE_ICON)
        end
        if isDamageRole then
            table.insert(g_roleIconTable, DAMAGE_ROLE_ICON)
        end
        if #g_roleIconTable > 0 then
            local rolesPair = statsSection:AcquireStatValuePair(self:GetStyle("statValuePair"))
            rolesPair:SetStat(GetString(SI_ABILITY_TOOLTIP_ROLE_LABEL), self:GetStyle("statValuePairStat"))
            local finalIconText = table.concat(g_roleIconTable, "")
            rolesPair:SetValue(finalIconText, self:GetStyle("abilityStatValuePairValue"))
            statsSection:AddStatValuePair(rolesPair)
            ZO_ClearNumericallyIndexedTable(g_roleIconTable)
        end

        self:AddSection(statsSection)
    end
end

function ZO_Tooltip:AddAbilityDescription(abilityId, overrideDescription, overrideCasterUnitTag)
    local descriptionHeader = GetAbilityDescriptionHeader(abilityId, overrideCasterUnitTag)
    local NO_OVERRIDE_RANK = nil
    local description = overrideDescription or GetAbilityDescription(abilityId, NO_OVERRIDE_RANK, overrideCasterUnitTag)
    if descriptionHeader ~= "" or description ~= "" then
        local descriptionSection = self:AcquireSection(self:GetStyle("bodySection"))
        if descriptionHeader ~= "" then
            --descriptionHeader has already been run through grammar
            descriptionSection:AddLine(descriptionHeader, self:GetStyle("bodyHeader"))
        end
        if description ~= "" then
            --description has already been run through grammar
            descriptionSection:AddLine(description, self:GetStyle("bodyDescription"))
        end
        self:AddSection(descriptionSection)
    end
end

function ZO_Tooltip:AddAbilityNewEffects(...)
    local numNewEffectReturns = select("#", ...)
    if(numNewEffectReturns > 0) then
        for i = 1, numNewEffectReturns do
            local newEffect = select(i, ...)
            local newEffectSection = self:AcquireSection(self:GetStyle("bodySection"))
            newEffectSection:AddLine(GetString(SI_ABILITY_TOOLTIP_NEW_EFFECT), self:GetStyle("newEffectTitle"), self:GetStyle("bodyHeader"))
            newEffectSection:AddLine(newEffect, self:GetStyle("newEffectBody"), self:GetStyle("bodyDescription"))
            self:AddSection(newEffectSection)
        end
    end
end

--Layout Functions

function ZO_Tooltip:LayoutSimpleAbility(abilityId)
    local headerSection = self:AcquireSection(self:GetStyle("abilityHeaderSection"))

    self:AddSectionEvenIfEmpty(headerSection)

    local formattedAbilityName = ZO_CachedStrFormat(SI_ABILITY_NAME, GetAbilityName(abilityId))
    self:AddLine(formattedAbilityName, self:GetStyle("title"))

    if not IsAbilityPassive(abilityId) then
        self:AddAbilityStats(abilityId)
    end
    self:AddAbilityDescription(abilityId)
end
