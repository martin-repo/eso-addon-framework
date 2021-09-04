--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_HouseInformation_Shared = ZO_Object:Subclass()

function ZO_HouseInformation_Shared:New(...)
    local houseInformation = ZO_Object.New(self)
    houseInformation:Initialize(...)
    return houseInformation
end

function ZO_HouseInformation_Shared:Initialize(control, fragment, rowTemplate, childVerticalPadding, sectionVerticalPadding)
    self.control = control
    self.rowTemplate = rowTemplate
    self.childVerticalPadding = childVerticalPadding
    self.sectionVerticalPadding = sectionVerticalPadding

    self:SetupControls()
    
    fragment:RegisterCallback("StateChange", function(oldState, newState)
                                                 if newState == SCENE_SHOWING then
                                                     self:UpdateHouseInformation()
                                                     self:UpdateHousePopulation()
                                                     self:UpdatePermissions()
                                                     self:UpdateLimits()
                                                 end
                                             end)
    
    local function RefreshItemLimits()
        if fragment:IsShowing() then
            self:UpdateLimits()
        end
    end

    local function RefreshHouseInformation()
        if fragment:IsShowing() then
            self:UpdateHouseInformation()
        end
    end

    local function RefreshHousePopulation(eventId, population)
        if fragment:IsShowing() then
            self:UpdateHousePopulation(population)
        end
    end

    local function RefreshHousePermissions(eventId, userGroup)
        if fragment:IsShowing() then
            self:UpdatePermissions(userGroup)
        end
    end

    control:RegisterForEvent(EVENT_HOUSING_FURNITURE_PLACED, RefreshItemLimits)
    control:RegisterForEvent(EVENT_HOUSING_FURNITURE_REMOVED, RefreshItemLimits)
    control:RegisterForEvent(EVENT_HOUSING_PRIMARY_RESIDENCE_SET, RefreshHouseInformation)
    control:RegisterForEvent(EVENT_HOUSING_POPULATION_CHANGED, RefreshHousePopulation)
    control:RegisterForEvent(EVENT_HOUSING_PERMISSIONS_CHANGED, RefreshHousePermissions)
end

do
    local function SetupRow(rootControl, controlName)
        local rowControl = rootControl:GetNamedChild(controlName)
        rowControl.nameLabel = rowControl:GetNamedChild("Name")
        rowControl.valueLabel = rowControl:GetNamedChild("Value")
        return rowControl
    end
    
    function ZO_HouseInformation_Shared:SetupControls()
        self.nameRow = SetupRow(self.control, "NameRow")
        self.locationRow = SetupRow(self.control, "LocationRow")
        self.ownerRow = SetupRow(self.control, "OwnerRow")
        self.infoSection = SetupRow(self.control, "InfoSection")
        self.primaryResidenceRow = SetupRow(self.control, "PrimaryResidenceRow")
        self.currentVisitorsRow = SetupRow(self.control, "CurrentVisitorsRow")
        self.individualPermissionsRow = SetupRow(self.control, "IndividualPermissions")
        self.guildPermissionsRow = SetupRow(self.control, "GuildPermissions")
        self.overPopulationWarning = self.currentVisitorsRow:GetNamedChild("Help")
    
        local furnishingLimits = self.infoSection:GetNamedChild("FurnishingLimits")
        local lastRow = nil
        self.limitRows = {}
        for i = HOUSING_FURNISHING_LIMIT_TYPE_ITERATION_BEGIN, HOUSING_FURNISHING_LIMIT_TYPE_ITERATION_END do
            local furnishingLimitRow = CreateControlFromVirtual(furnishingLimits:GetName().."Row"..i, furnishingLimits, self.rowTemplate)
    
            if not lastRow then
                furnishingLimitRow:SetAnchor(TOPLEFT)
            else
                furnishingLimitRow:SetAnchor(TOPLEFT, lastRow, BOTTOMLEFT, 0, self.childVerticalPadding)
            end
            lastRow = furnishingLimitRow
            self.limitRows[i] = SetupRow(furnishingLimits, "Row"..i)
        end
    end
end

function ZO_HouseInformation_Shared:UpdateHouseInformation()
    local currentHouseId = GetCurrentZoneHouseId()
    local houseCollectibleId = GetCollectibleIdForHouse(currentHouseId)
    local houseCollectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(houseCollectibleId)

    local isPrimaryHouse = IsPrimaryHouse(currentHouseId)

    self.nameRow.valueLabel:SetText(houseCollectibleData:GetFormattedName())
    self.locationRow.valueLabel:SetText(houseCollectibleData:GetFormattedHouseLocation())
    self.primaryResidenceRow.valueLabel:SetText(isPrimaryHouse and GetString(SI_YES) or GetString(SI_NO))

    local ownerDisplayName = GetCurrentHouseOwner()
    if ownerDisplayName ~= "" then
        self.ownerRow.valueLabel:SetText(ZO_FormatUserFacingDisplayName(ownerDisplayName))
        self.ownerRow:SetHidden(false)
        self.infoSection:SetAnchor(TOPLEFT, self.ownerRow, BOTTOMLEFT, 0, self.sectionVerticalPadding)
    else
        self.ownerRow:SetHidden(true)
        self.infoSection:SetAnchor(TOPLEFT, self.locationRow, BOTTOMLEFT, 0, self.sectionVerticalPadding)
    end
end

function ZO_HouseInformation_Shared:UpdateHousePopulation(population)
    local currentPopulation = population or GetCurrentHousePopulation()
    local maxPopulation = GetCurrentHousePopulationCap()
    self.currentVisitorsRow.valueLabel:SetText(zo_strformat(SI_HOUSE_INFORMATION_COUNT_FORMAT, currentPopulation, maxPopulation));
    
    local overpopulated = currentPopulation > maxPopulation
    self.overPopulationWarning:SetHidden(not overpopulated)
end

function ZO_HouseInformation_Shared:UpdatePermissions(userGroup)
    if userGroup == HOUSE_PERMISSION_USER_GROUP_INDIVIDUAL or userGroup == nil then
        local numIndividualPermissions = GetNumHousingPermissions(GetCurrentZoneHouseId(), HOUSE_PERMISSION_USER_GROUP_INDIVIDUAL)
        local textColor = numIndividualPermissions >= HOUSING_MAX_INDIVIDUAL_USER_GROUP_ENTRIES and ZO_ERROR_COLOR or ZO_SELECTED_TEXT
        self.individualPermissionsRow.valueLabel:SetText(textColor:Colorize(zo_strformat(SI_HOUSING_NUM_PERMISSIONS_FORMAT, numIndividualPermissions, HOUSING_MAX_INDIVIDUAL_USER_GROUP_ENTRIES)))
    end

    if userGroup == HOUSE_PERMISSION_USER_GROUP_GUILD or userGroup == nil then
        local numGuildPermissions = GetNumHousingPermissions(GetCurrentZoneHouseId(), HOUSE_PERMISSION_USER_GROUP_GUILD)
        textColor = numGuildPermissions >= HOUSING_MAX_GUILD_USER_GROUP_ENTRIES and ZO_ERROR_COLOR or ZO_SELECTED_TEXT
        self.guildPermissionsRow.valueLabel:SetText(textColor:Colorize(zo_strformat(SI_HOUSING_NUM_PERMISSIONS_FORMAT, numGuildPermissions, HOUSING_MAX_GUILD_USER_GROUP_ENTRIES)))
    end
end

do
    local function UpdateRow(rowControl, name, value)
        rowControl.nameLabel:SetText(name)
        rowControl.valueLabel:SetText(value)
    end
    
    function ZO_HouseInformation_Shared:UpdateLimits()
        local currentHouseId = GetCurrentZoneHouseId()
    
        for i = HOUSING_FURNISHING_LIMIT_TYPE_ITERATION_BEGIN, HOUSING_FURNISHING_LIMIT_TYPE_ITERATION_END do
            local limit = GetHouseFurnishingPlacementLimit(currentHouseId, i)
            local currentlyPlaced = GetNumHouseFurnishingsPlaced(i)
            UpdateRow(self.limitRows[i], GetString("SI_HOUSINGFURNISHINGLIMITTYPE", i), zo_strformat(SI_HOUSE_INFORMATION_COUNT_FORMAT, currentlyPlaced, limit))
        end
    end
end