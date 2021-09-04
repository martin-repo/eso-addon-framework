--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

function ZO_Tooltip:AddAntiquityLeadStatus(antiquityId)
    local antiquityData = ANTIQUITY_DATA_MANAGER:GetAntiquityData(antiquityId)
    if antiquityData and antiquityData:GetType() == ZO_ANTIQUITY_TYPE_INDIVIDUAL then
        local leadTimeRemainingS = antiquityData:GetLeadTimeRemainingS()
        if leadTimeRemainingS > 0 then
            local leadTimeRemainingText = ZO_FormatAntiquityLeadTime(leadTimeRemainingS)
            self:AddLine(ZO_SELECTED_TEXT:Colorize(zo_strformat(SI_ANTIQUITY_TOOLTIP_LEAD_EXPIRATION, leadTimeRemainingText)), self:GetStyle("bodyDescription"))
        end
    end
end

function ZO_Tooltip:AddAntiquityZone(antiquityId)
    local antiquityData = ANTIQUITY_DATA_MANAGER:GetAntiquityData(antiquityId)
    if antiquityData and antiquityData:GetType() == ZO_ANTIQUITY_TYPE_INDIVIDUAL then
        local zoneName = GetZoneNameById(antiquityData:GetZoneId())
        if zoneName ~= "" then
            local locationSection = self:AcquireSection(self:GetStyle("bodySection"))
            local formattedLocation = zo_strformat(SI_ANTIQUITY_TOOLTIP_ZONE, ZO_SELECTED_TEXT:Colorize(zoneName))
            locationSection:AddLine(formattedLocation, self:GetStyle("bodyDescription"))
            self:AddSection(locationSection)
        end
    end
end

function ZO_Tooltip:LayoutAntiquityLead(antiquityId)
    local antiquityData = ANTIQUITY_DATA_MANAGER:GetAntiquityData(antiquityId)
    if antiquityData then
        local topSection = self:AcquireSection(self:GetStyle("topSection"))
        topSection:AddLine(GetString(SI_ANTIQUITY_LEAD_TOOLTIP_TAG))
        self:AddSection(topSection)

        local quality = antiquityData:GetQuality()
        local qualityStyle = ZO_TooltipStyles_GetAntiquityQualityStyle(quality)
        local formattedName = zo_strformat(SI_ANTIQUITY_LEAD_NAME_FORMATTER, antiquityData:GetName())
        self:AddLine(formattedName, qualityStyle, self:GetStyle("title"))

        local bodySection = self:AcquireSection(self:GetStyle("antiquityInfoSection"))
        local descriptionStyle = self:GetStyle("bodyDescription")
        local formattedDescription = zo_strformat(SI_ANTIQUITY_LEAD_TOOLTIP_DESCRIPTION, antiquityData:GetColorizedName())
        bodySection:AddLine(formattedDescription, descriptionStyle)
        self:AddSection(bodySection)

        self:AddAntiquityZone(antiquityId)
    end
end

function ZO_Tooltip:LayoutAntiquitySetFragment(antiquityId)
    local antiquityData = ANTIQUITY_DATA_MANAGER:GetAntiquityData(antiquityId)
    if antiquityData then
        local antiquitySetData = antiquityData:GetAntiquitySetData()
        if antiquitySetData then
            local topSection = self:AcquireSection(self:GetStyle("topSection"))
            topSection:AddLine(GetString(SI_ANTIQUITY_SET_FRAGMENT_TOOLTIP_TAG))
            self:AddSection(topSection)

            local meetsLeadRequirements = antiquityData:MeetsLeadRequirements()
            local isHidden = not meetsLeadRequirements and not antiquityData:HasRecovered()
            local isRepeatable = antiquityData:IsRepeatable()
            if isHidden then
                self:AddLine(GetString(SI_ANTIQUITY_NAME_HIDDEN), self:GetStyle("title"))
            else
                local formattedName = antiquityData:GetColorizedFormattedName()
                self:AddLine(formattedName, self:GetStyle("title"))
            end

            local bodySection = self:AcquireSection(self:GetStyle("antiquityInfoSection"))
            local formattedSetDescription = zo_strformat(SI_ANTIQUITY_FRAGMENT_SET_DESCRIPTOR, antiquitySetData:GetNumAntiquities(), antiquitySetData:GetName())
            bodySection:AddLine(formattedSetDescription, self:GetStyle("bodyDescription"))
            self:AddSection(bodySection)

            if meetsLeadRequirements then
                self:AddAntiquityZone(antiquityId)
                self:AddAntiquityLeadStatus(antiquityId)
            --If the antiquity is not repeatable and has been collected before, it doesn't make sense to display this line
            elseif isHidden or isRepeatable then
                local missingLeadSection = self:AcquireSection(self:GetStyle("bodySection"))
                missingLeadSection:AddLine(GetString(SI_ANTIQUITY_REQUIRES_LEAD), self:GetStyle("bodyDescription"))
                self:AddSection(missingLeadSection)
            end
        end
    end
end

function ZO_Tooltip:LayoutAntiquityReward(antiquityId)
    local antiquityData = ANTIQUITY_DATA_MANAGER:GetAntiquityData(antiquityId)
    if antiquityData and antiquityData:HasReward() and antiquityData:HasDiscovered() then
        local rewardId = antiquityData:GetRewardId()
        self:LayoutReward(rewardId)
        self:AddAntiquityZone(antiquityId)
        self:AddAntiquityLeadStatus(antiquityId)
    end
end

function ZO_Tooltip:LayoutAntiquitySetReward(antiquitySetId)
    local antiquitySetData = ANTIQUITY_DATA_MANAGER:GetAntiquitySetData(antiquitySetId)
    if antiquitySetData and antiquitySetData:HasReward() and antiquitySetData:HasDiscovered() then
        local rewardId = antiquitySetData:GetRewardId()
        self:LayoutReward(rewardId)
        self:AddAntiquityZone(antiquityId)
    end
end