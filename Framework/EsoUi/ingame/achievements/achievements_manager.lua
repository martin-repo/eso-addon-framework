--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_ACHIEVEMENTS_ROOT_SUBCATEGORY = "root"

ZO_ACHIEVEMENTS_COMPLETION_STATUS = 
{
    NOT_APPLICABLE = 1,
    INCOMPLETE = 2,
    IN_PROGRESS = 3,
    COMPLETE = 4,
}

local Achievements_Manager = ZO_CallbackObject:Subclass()

function Achievements_Manager:New(...)
    local manager = ZO_CallbackObject.New(self)
    manager:Initialize(...)
    return manager
end

function Achievements_Manager:Initialize()
    self.searchString = ""
    self.searchResults = {}

    local function OnAchievementsUpdated()
        -- When the data is getting rebuilt, the indicies can change so our old search results are no longer any good
        if self:GetSearchResults() then
            local currentSearch = self.searchString
            ZO_ClearTable(self.searchResults)
            self:SetSearchString("")
            self:SetSearchString(currentSearch)
        end
    end

    EVENT_MANAGER:RegisterForEvent("Achievements_Manager", EVENT_ACHIEVEMENTS_UPDATED, OnAchievementsUpdated)
    EVENT_MANAGER:RegisterForEvent("Achievements_Manager", EVENT_ACHIEVEMENTS_SEARCH_RESULTS_READY, function() self:UpdateSearchResults() end)
end

function Achievements_Manager:ClearSearch(requiresImmediateRefresh)
    if self.searchString ~= "" then
        self:SetSearchString("")
    end

    if requiresImmediateRefresh then
        -- If we're relying on results being cleared this frame, do this now so any checks will work, and let the "search" run in the background
        -- so that C stays in sync.  This will result in a double update, but sometimes it can't be avoided
        ZO_ClearTable(self.searchResults)
        self:FireCallbacks("UpdateSearchResults")
    end
end

function Achievements_Manager:SetSearchString(searchString)
    self.searchString = searchString or ""
    StartAchievementSearch(self.searchString)
end

function Achievements_Manager:UpdateSearchResults()
    ZO_ClearTable(self.searchResults)

    local searchResults = self.searchResults
    for i = 1, GetNumAchievementsSearchResults() do
        local categoryIndex, subcategoryIndex, achievementIndex = GetAchievementsSearchResult(i)

        local categoryData = searchResults[categoryIndex]
        if not categoryData then
            categoryData = {}
            searchResults[categoryIndex] = categoryData
        end

        local effectiveSubcategoryIndex = subcategoryIndex or ZO_ACHIEVEMENTS_ROOT_SUBCATEGORY
        local effectiveSubcategoryData = categoryData[effectiveSubcategoryIndex]
        if not effectiveSubcategoryData then
            effectiveSubcategoryData = {}
            categoryData[effectiveSubcategoryIndex] = effectiveSubcategoryData
        end

        effectiveSubcategoryData[achievementIndex] = true
    end

    self:FireCallbacks("UpdateSearchResults")
end

function Achievements_Manager:GetSearchResults()
    if zo_strlen(self.searchString) > 1 then
        return self.searchResults
    end
    return nil
end

function Achievements_Manager:IsInSearchResults(categoryIndex, subcategoryIndex, achievementIndex)
    local searchResults = self:GetSearchResults()

    if searchResults then
        local effectiveSubcategoryIndex = subcategoryIndex or ZO_ACHIEVEMENTS_ROOT_SUBCATEGORY
        return searchResults[categoryIndex] and searchResults[categoryIndex][effectiveSubcategoryIndex] and searchResults[categoryIndex][effectiveSubcategoryIndex][achievementIndex]
    else
        return true
    end
end

function Achievements_Manager:GetAchievementStatus(achievementId)
    local completed = 0
    local total = 0
    local numCriteria = GetAchievementNumCriteria(achievementId)
    for criterionIndex = 1, numCriteria do
        local _, numCompleted, numRequired = GetAchievementCriterion(achievementId, criterionIndex)
        completed = completed + numCompleted
        total = total + numRequired
    end

    if total > 0 then
        if completed > 0 then
            if completed == total then
                return ZO_ACHIEVEMENTS_COMPLETION_STATUS.COMPLETE
            else
                return ZO_ACHIEVEMENTS_COMPLETION_STATUS.IN_PROGRESS
            end
        else
            return ZO_ACHIEVEMENTS_COMPLETION_STATUS.INCOMPLETE
        end
    end

    return ZO_ACHIEVEMENTS_COMPLETION_STATUS.NOT_APPLICABLE
end

ACHIEVEMENTS_MANAGER = Achievements_Manager:New()