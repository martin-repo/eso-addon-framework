--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local function HasMapLocationTooltip(self, locationIndex)
    local headerText = GetMapLocationTooltipHeader(locationIndex)
    if(headerText == "") then
        return false
    end

    local numTooltipLines = GetNumMapLocationTooltipLines(locationIndex)
    if(numTooltipLines == 0) then
        return false
    end

    return true
end

local MIN_HEADER_WIDTH = 150

local function SortGroupings(a, b)
    return a.id < b.id
end

local function SortGrouping(a, b)
    return a.name < b.name
end

local function GetMapLocationLines(locationIndex)
    local groupings = {}

    local numTooltipLines = GetNumMapLocationTooltipLines(locationIndex)
    for lineIndex = 1, numTooltipLines do
        if(IsMapLocationTooltipLineVisible(locationIndex, lineIndex)) then
            --Create labels for the lines. The size of the header depends on the lines.
            local icon, name, groupingId, categoryName = GetMapLocationTooltipLineInfo(locationIndex, lineIndex)

            --Search for an existing grouping
            local grouping
            for groupingIndex = 1, #groupings do
                if(groupings[groupingIndex].id == groupingId) then
                    grouping = groupings[groupingIndex]
                end
            end

            --if there isn't an existing one, make it
            if(grouping == nil) then
                grouping = {}
                grouping.id = groupingId
                table.insert(groupings, grouping)
            end

            local showName = name ~= categoryName
            table.insert(grouping, { name = name, categoryName = categoryName, icon = icon, showName = showName, })
        end
    end

    table.sort(groupings, SortGroupings)

    for groupingIndex = 1, #groupings do
        local grouping = groupings[groupingIndex]
        table.sort(grouping, SortGrouping)
    end

    return groupings
end

local function CreateLineLabel(self, text, indentation, currentLargestWidth)
    if indentation > 0 then
        self:AddVerticalPadding(-5)
    end
    local label = self.labelPool:AcquireObject()
    label.indentation = indentation
    label:SetDimensions(0,0)
    label:SetText(text)

    self:AddControl(label)
    label:SetAnchor(CENTER, nil, CENTER, indentation, 0)
    self:AddVerticalPadding(-8)

    local labelWidth = label:GetTextWidth() + indentation + 5
    return zo_max(currentLargestWidth, labelWidth)
end

local function SetMapLocation(self, locationIndex)
    self:ClearLines()

    local largestWidth = MIN_HEADER_WIDTH

    --add header
    local headerText = GetMapLocationTooltipHeader(locationIndex)
    if headerText ~= "" then
        self.header:SetWidth(0)
        self.header:SetText(headerText)
        self:AddControl(self.header)
        self.header:SetAnchor(CENTER)
        largestWidth = zo_max(self.header:GetTextWidth(), largestWidth)

        self:AddVerticalPadding(-5)
        self:AddControl(self.divider)
        self.divider:SetAnchor(CENTER)
    end

    --add lines
    local groupings = GetMapLocationLines(locationIndex)
    for groupingIndex = 1, #groupings do
        local grouping = groupings[groupingIndex]
        for _, entry in ipairs(grouping) do
            local iconText = zo_iconFormat(entry.icon, 32, 32)
            local NO_INDENT = 0 
            largestWidth = CreateLineLabel(self, zo_strformat(SI_TOOLTIP_MAP_LOCATION_CATEGORY_FORMAT, iconText, entry.categoryName), NO_INDENT, largestWidth)
            
            if entry.showName then
                local NAME_INDENT = 32
                largestWidth = CreateLineLabel(self, zo_strformat(SI_TOOLTIP_UNIT_NAME, entry.name), NAME_INDENT, largestWidth)
            end
        end
    end

    self.header:SetWidth(largestWidth)
    self.divider:SetWidth(largestWidth)
    local labels = self.labelPool:GetActiveObjects()
    for _, label in pairs(labels) do
        label:SetWidth(largestWidth - label.indentation)
    end
end

local function SetMapLocation_Gamepad(self, locationIndex)
    local mainSection = self.tooltip:AcquireSection(self.tooltip:GetStyle("mapLocationSection"))

    --add header
    local headerText = GetMapLocationTooltipHeader(locationIndex)
    if headerText ~= "" then
        self:LayoutGroupHeader(mainSection, nil, headerText, self.tooltip:GetStyle("mapTitle"))
    end

    local groupsSection = self.tooltip:AcquireSection(self.tooltip:GetStyle("mapGroupsSection"))

    local groupSectionStyle = self.tooltip:GetStyle("mapLocationGroupSection")
    local entryStyle = self.tooltip:GetStyle("mapLocationEntrySection")
    local titleStyle = self.tooltip:GetStyle("mapLocationTooltipContentTitle")
    local nameSectionStyle = self.tooltip:GetStyle("mapLocationTooltipNameSection")
    local nameStyle = self.tooltip:GetStyle("mapLocationTooltipContentName")
    --add lines
    local groupings = GetMapLocationLines(locationIndex)
    for _, grouping in ipairs(groupings) do
        local groupSection = groupsSection:AcquireSection(groupSectionStyle)

        for _, entry in ipairs(grouping) do
            local entrySection = groupSection:AcquireSection(entryStyle)
            local name = zo_strformat(SI_TOOLTIP_UNIT_NAME, entry.name)
            local icon = entry.icon

            icon = icon:gsub("servicetooltipicons/", "servicetooltipicons/gamepad/gp_")

            self:LayoutLargeIconStringLine(entrySection, icon, entry.categoryName, titleStyle)
            if entry.showName then
                local nameSection = entrySection:AcquireSection(nameSectionStyle)
                self:LayoutStringLine(nameSection, name, nameStyle)
                entrySection:AddSection(nameSection)
            end
            groupSection:AddSection(entrySection)
        end

        groupsSection:AddSection(groupSection)
    end

    mainSection:AddSection(groupsSection)
    self.tooltip:AddSection(mainSection)
end

--Global XML

function ZO_MapLocationTooltip_OnCleared(self)
    self.labelPool:ReleaseAllObjects()
end

function ZO_MapLocationTooltip_OnInitialized(self)
    self.SetMapLocation = SetMapLocation
    self.HasMapLocationTooltip = HasMapLocationTooltip
    self.labelPool = ZO_ControlPool:New("ZO_MapLocationTooltipLabel", self, "Label")

    self.header = self:GetNamedChild("Header")
    self.divider = self:GetNamedChild("Divider")
end

function ZO_MapLocationTooltip_Gamepad_OnInitialized(self)
    ZO_ScrollTooltip_Gamepad:Initialize(self, ZO_TOOLTIP_STYLES, "worldMapTooltip")

    ZO_KeepTooltip_Gamepad_OnInitialized(self)

    self.SetMapLocation = SetMapLocation_Gamepad
    self.HasMapLocationTooltip = HasMapLocationTooltip

    zo_mixin(self, ZO_MapInformationTooltip_Gamepad_Mixin)

    local ALWAYS_ANIMATE = true
    GAMEPAD_WORLD_MAP_TOOLTIP_FRAGMENT = ZO_FadeSceneFragment:New(self:GetParent(), ALWAYS_ANIMATE)

    ZO_Scroll_Gamepad_SetScrollIndicatorSide(self.scrollIndicator, self:GetParent(), LEFT)
end
