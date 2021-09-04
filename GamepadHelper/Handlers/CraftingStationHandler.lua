--#region Usings

--#region Framework usings
---@type Array
local Array = EsoAddonFramework_Framework_Array
---@type Color
local Color = EsoAddonFramework_Framework_Color
---@type Console
local Console = EsoAddonFramework_Framework_Console
---@type Event
local Event = EsoAddonFramework_Framework_Eso_Event
---@type EventManager
local EventManager = EsoAddonFramework_Framework_Eso_EventManager
---@type FrameworkMessageType
local FrameworkMessageType = EsoAddonFramework_Framework_MessageType
---@type Log
local Log = EsoAddonFramework_Framework_Log
---@type LogLevel
local LogLevel = EsoAddonFramework_Framework_LogLevel
---@type Map
local Map = EsoAddonFramework_Framework_Map
---@type Messenger
local Messenger = EsoAddonFramework_Framework_Messenger
---@type Pack
local Pack = EsoAddonFramework_Framework_Eso_Pack
---@type Storage
local Storage = EsoAddonFramework_Framework_Storage
---@type StorageScope
local StorageScope = EsoAddonFramework_Framework_StorageScope
---@type String
local String = EsoAddonFramework_Framework_String
---@type StringBuilder
local StringBuilder = EsoAddonFramework_Framework_StringBuilder
---@type Type
local Type = EsoAddonFramework_Framework_Eso_Type
---@type UnitTag
local UnitTag = EsoAddonFramework_Framework_Eso_UnitTag
--#endregion

--#region Addon usings
---@type AddonMessageType
local AddonMessageType = GamepadHelper_Types_MessageType
---@type ItemAssessment
local ItemAssessment = GamepadHelper_Types_ItemAssessment
---@type ItemAssessmentManager
local ItemAssessmentManager = GamepadHelper_Globals_ItemAssessmentManager
---@type ItemAssessmentFilter
local ItemAssessmentFilter = GamepadHelper_Types_ItemAssessmentFilter
local Lang = GamepadHelper_Lang
---@type UnitManager
local Unit = GamepadHelper_Globals_UnitManager
--#endregion

--#endregion
-- Constants

local DefaultSettings = {
    IsEnabled = true
}

LaunderItemType = {
    Ingredient = ITEMTYPE_INGREDIENT,
    Recipe = ITEMTYPE_RECIPE,
    StyleMaterial = ITEMTYPE_STYLE_MATERIAL,
    Tool = ITEMTYPE_TOOL,
}

local Name = "GamepadHelper_Handlers_CraftingStationHandler"

SellItemType = {
    Armor = ITEMTYPE_ARMOR,
    Treasure = ITEMTYPE_TREASURE,
}

-- Fields

local _log
local _settings = DefaultSettings

-- Local functions

local function CreateSettingsControls()
    local descriptionBuilder = StringBuilder.CreateInstance()
    descriptionBuilder:AppendLine("Automatically {research:Orange} and {deconstruct:Orange} items at crafting stations. Uses {Item assessment:Blue} rules.")
    descriptionBuilder:AppendLine()
    descriptionBuilder:AppendLine("When a research slot is open, {research:Orange} any available trait.")
    descriptionBuilder:Append("When a crafting skill is not maxed out, {deconstruct:Orange} any available gear.")
    local description = String.Format(descriptionBuilder:ToString())

    local settingsControls = {
        {
            type = "description",
            text = description
        },
        {
            type = "checkbox",
            name = "Enabled",
            getFunc = function() return _settings.IsEnabled end,
            setFunc = function(value) _settings.IsEnabled = value end
        }
    }

    return {
        DisplayName = "Crafting station automation",
        Controls = settingsControls
    }
end

---@param craftingSkillType TradeskillType
---@return number availableResearchSlotCount
---@return table availableResearchTraits # Map of ResearchLineIndex => researchTraitData array
local function GetAvailableResearchInfo(craftingSkillType)
    local researchTotalSlotCount = GetMaxSimultaneousSmithingResearch(craftingSkillType)
    local researchUsedSlotCount = 0

    local availableResearchTraits = { }

    local researchLinesCount = GetNumSmithingResearchLines(craftingSkillType)
    for researchLineIndex = 1, researchLinesCount do
        local researchLineInfo = Pack.GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
        if (researchLineInfo.NumTraits > 0) then
            for traitIndex = 1, researchLineInfo.NumTraits do
                local traitInfo = Pack.GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
                if (not traitInfo.Known) then
                    local traitTimesInfo = Pack.GetSmithingResearchLineTraitTimes(craftingSkillType, researchLineIndex, traitIndex)
                    if (traitTimesInfo.Duration ~= nil) then
                        researchUsedSlotCount = researchUsedSlotCount + 1
                    else
                        if (availableResearchTraits[researchLineIndex] == nil) then
                            availableResearchTraits[researchLineIndex] = { }
                        end

                        Array.Add(availableResearchTraits[researchLineIndex], {
                            ResearchLineIndex = researchLineIndex,
                            TraitIndex = traitIndex,
                            ItemTraitType = traitInfo.TraitType
                        })
                    end
                end
            end
        end
    end

    local availableResearchSlotCount = researchTotalSlotCount - researchUsedSlotCount
    return availableResearchSlotCount, availableResearchTraits
end

local function ResearchItems(craftingSkillType)
    -- Get available research data
    -- availableResearchSlotCount, total available research slots
    -- availableResearchTraits, available traits in each research line
    local availableResearchSlotCount, availableResearchTraits = GetAvailableResearchInfo(craftingSkillType)
    if (availableResearchSlotCount == 0 or not Map.Any(availableResearchTraits)) then
        return
    end

    local function CanResearchItemTrait(bagId, slotIndex, itemTraitType, researchTraitDatas)
        -- Iterate each trait in the research line to see if it matches the inventory item
        for _, researchTraitData in Array.Enumerate(researchTraitDatas) do
            if (itemTraitType == researchTraitData.ItemTraitType and
                CanItemBeSmithingTraitResearched(bagId, slotIndex, craftingSkillType, researchTraitData.ResearchLineIndex, researchTraitData.TraitIndex))
            then
                return true
            end
        end

        return false
    end

    local function ResearchItemTrait(bagId, slotIndex, itemTraitType, itemLink)
        -- Iterate over each research line
        for researchLineIndex, researchTraitDatas in Map.Enumerate(availableResearchTraits) do
            if (CanResearchItemTrait(bagId, slotIndex, itemTraitType, researchTraitDatas)) then
                local craftingSkillName = GetCraftingSkillName(craftingSkillType)
                _log:Debug("Researching {1}", itemLink)

                ResearchSmithingTrait(bagId, slotIndex)
                availableResearchSlotCount = availableResearchSlotCount - 1
                Map.Remove(availableResearchTraits, researchLineIndex)
                return
            end
        end
    end

    -- Iterate over all items in backpack
    local bagId = Type.Bag.Backpack
    local totalSlotCount = GetBagSize(bagId)
    for slotIndex = 0, totalSlotCount - 1 do
        local itemLink = GetItemLink(bagId, slotIndex, Type.LinkStyle.Brackets)
        -- Only attempt to research valid items
        if (itemLink ~= "" and
            not IsItemPlayerLocked(bagId, slotIndex) and
            GetItemLinkCraftingSkillType(itemLink) == craftingSkillType and
            GetItemTraitInformation(bagId, slotIndex) == Type.ItemTraitInformation.CanBeResearched and
            ItemAssessmentManager.AssessItem(itemLink, ItemAssessmentFilter.GearOnly) == ItemAssessment.Dispose)
        then
            local itemTraitType = GetItemLinkTraitType(itemLink)
            ResearchItemTrait(bagId, slotIndex, itemTraitType, itemLink)

            if (availableResearchSlotCount == 0 or not Map.Any(availableResearchTraits)) then
                return
            end
        end
    end
end

local function DeconstructItems(craftingSkillType)
    local function GetSkillLineIndex()
        local skillLineCount = GetNumSkillLines(Type.SkillType.Tradeskill)
        for skillLineIndex = 1, skillLineCount do
            if (GetSkillLineCraftingGrowthTypeById(skillLineIndex) == craftingSkillType) then
                return skillLineIndex
            end
        end

        return nil
    end

    local skillLineIndex = GetSkillLineIndex()
    local skillLineXpInfo = Pack.GetSkillLineXPInfo(Type.SkillType.Tradeskill, skillLineIndex)

    local craftingSkillName = GetCraftingSkillName(craftingSkillType)
    if (skillLineXpInfo.NextRankXP == 0) then
        _log:Debug("{1) is maxed out. Will not deconstruct.", craftingSkillName)
        return
    end

    local anyItemAdded = false
    PrepareDeconstructMessage()

    local bagId = Type.Bag.Backpack
    local totalSlotCount = GetBagSize(bagId)
    for slotIndex = 0, totalSlotCount - 1 do
        local itemLink = GetItemLink(bagId, slotIndex, Type.LinkStyle.Brackets)
        -- Only attempt to deconstruct valid items
        if (itemLink ~= "" and
            not IsItemPlayerLocked(bagId, slotIndex) and
            GetItemLinkCraftingSkillType(itemLink) == craftingSkillType and
            CanItemBeDeconstructed(bagId, slotIndex, craftingSkillType) and
            ItemAssessmentManager.AssessItem(itemLink) == ItemAssessment.Dispose)
        then
            local count = GetSlotStackSize(bagId, slotIndex)
            _log:Debug("Deconstructing {1} x{2}", itemLink, count)
            anyItemAdded = AddItemToDeconstructMessage(bagId, slotIndex, count) or anyItemAdded
        end
    end

    if (anyItemAdded) then
        SendDeconstructMessage()
    end
end

local function OnCraftingStationInteract(event, craftSkill, sameStation)
    if (not _settings.IsEnabled) then
        return
    end

    _log:Debug("Using {1} station", GetCraftingSkillName(craftSkill))

    if (IsSmithingCraftingType(craftSkill)) then
        ResearchItems(craftSkill)
    end

    -- Items used for research are not removed from backpack fast enough,
    -- the deconstruct function will attempt to use them. Wait a short while
    -- after researching to make sure that registration is complete.
    zo_callLater(function() DeconstructItems(craftSkill) end, 500)
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _log = Log.CreateInstance(Name)

    EventManager:RegisterForEvent(Name, Event.CraftingStationInteract, OnCraftingStationInteract)

    Messenger.Subscribe(FrameworkMessageType.SettingsControlsRequest, CreateSettingsControls)

    _settings = Storage.GetEntry(Name, DefaultSettings, StorageScope.Account)
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)