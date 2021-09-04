--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_COLLECTIBLE_DATA_FILTERS = 
{
    INCLUDE_LOCKED = true,
    EXCLUDE_LOCKED = false,
    INCLUDE_INVALID_FOR_PLAYER = true,
    EXCLUDE_INVALID_FOR_PLAYER = false,
}

ZO_COLLECTION_UPDATE_TYPE =
{
    REBUILD = 1,
    FORCE_REINITIALIZE = 2,
    UNLOCK_STATE_CHANGES = 3,
    BLACKLIST_CHANGED = 4,
}

----------------------------------
-- Set Default Collectible Data --
----------------------------------

ZO_SetDefaultCollectibleData = ZO_InitializingObject:Subclass()

function ZO_SetDefaultCollectibleData:Initialize(categoryTypeToSetDefault)
    self.categoryTypeToSetDefault = categoryTypeToSetDefault
end

function ZO_SetDefaultCollectibleData.IsSetDefaultData()
    return true
end

function ZO_SetDefaultCollectibleData:GetCategoryTypeToSetDefault()
    return self.categoryTypeToSetDefault
end

function ZO_SetDefaultCollectibleData:GetName()
    return ZO_CachedStrFormat(SI_SET_DEFAULT_COLLECTIBLE_NAME_FORMAT, GetString("SI_COLLECTIBLECATEGORYTYPE", self:GetCategoryTypeToSetDefault()))
end

do
    local DESCRIPTION_FORMATTERS =
    {
        [GAMEPLAY_ACTOR_CATEGORY_COMPANION] = SI_COMPANION_SET_DEFAULT_COLLECTIBLE_DESCRIPTION_FORMAT,
    }

    function ZO_SetDefaultCollectibleData:GetDescription(actorCategory)
        local descriptionFormatter = DESCRIPTION_FORMATTERS[actorCategory]
        if descriptionFormatter then
            return ZO_CachedStrFormat(descriptionFormatter, GetString("SI_COLLECTIBLECATEGORYTYPE", self:GetCategoryTypeToSetDefault()))
        end
        return nil
    end
end

do
    local COLLECTIBLE_CATEGORY_TYPE_DEFAULT_ICONS =
    {
        [COLLECTIBLE_CATEGORY_TYPE_MOUNT] = "EsoUI/Art/Collections/Default/collections_default_mount.dds",
    }

    function ZO_SetDefaultCollectibleData:GetIcon()
        return COLLECTIBLE_CATEGORY_TYPE_DEFAULT_ICONS[self.categoryTypeToSetDefault]
    end
end

function ZO_SetDefaultCollectibleData:IsActive(actorCategory)
    return IsCollectibleCategoryTypeSetToDefault(self.categoryTypeToSetDefault, actorCategory)
end

function ZO_SetDefaultCollectibleData:Use(actorCategory)
    SetCollectibleCategoryTypeToDefault(self.categoryTypeToSetDefault, actorCategory)
end

function ZO_SetDefaultCollectibleData:GetPrimaryInteractionStringId(actorCategory)
    -- Function signature mirrors the one on ZO_CollectibleData,
    -- but right now there's no support for anything other than Set Active variants
    return SI_COLLECTIBLE_ACTION_SET_ACTIVE
end

----------------------
-- Collectible Data --
----------------------

ZO_CollectibleData = ZO_InitializingObject:Subclass()

function ZO_CollectibleData:Initialize()
    self.isActiveByActorCategory = {}
end

function ZO_CollectibleData.IsSetDefaultData()
    return false
end

function ZO_CollectibleData:Reset()
    self.cachedNameWithNickname = nil
end

function ZO_CollectibleData:BuildData(categoryData, collectibleIndex)
    self.categoryData = categoryData
    local categoryIndex, subcategoryIndex = categoryData:GetCategoryIndicies()
    local collectibleId = GetCollectibleId(categoryIndex, subcategoryIndex, collectibleIndex)

    self.collectibleIndex = collectibleIndex
    self.collectibleId = collectibleId
    self.name = GetCollectibleName(collectibleId)
    self.icon = GetCollectibleIcon(collectibleId)
    self.categoryType = GetCollectibleCategoryType(collectibleId)
    local specializedCategoryType = GetSpecializedCollectibleType(collectibleId)
    if specializedCategoryType == SPECIALIZED_COLLECTIBLE_TYPE_NONE then
        specializedCategoryType = nil -- Very rare, this is a memory optimization
    end
    self.specializedCategoryType = specializedCategoryType
    self.referenceId = GetCollectibleReferenceId(collectibleId)
    self.hasVisualAppearence = DoesCollectibleHaveVisibleAppearance(collectibleId)
    self.hideMode = GetCollectibleHideMode(collectibleId)

    self:SetStoriesData()
    self:SetHousingData()
    self:SetOutfitStyleData()

    self:SetupGridCategoryName()

    self:Refresh()
    ZO_COLLECTIBLE_DATA_MANAGER:MapCollectibleData(self)
end

function ZO_CollectibleData:SetStoriesData()
    if self:IsStory() then
        self.unlockedViaSubscription = DoesESOPlusUnlockCollectible(self.collectibleId)
        self.questName, self.questDescription = GetCollectibleQuestPreviewInfo(self.collectibleId)
    else
        self.unlockedViaSubscription = false
        self.questName = nil
        self.questDescription = nil
    end
end

function ZO_CollectibleData:SetHousingData()
    if self:IsHouse() then
        local referenceId = self.referenceId
        local houseFoundInZoneId = GetHouseFoundInZoneId(referenceId)
        self.houseLocation = GetZoneNameById(houseFoundInZoneId)
        self.houseCategoryType = GetHouseCategoryType(referenceId)
        self.isPrimaryResidence = IsPrimaryHouse(referenceId)
    else
        self.houseLocation = nil
        self.houseCategoryType = nil
        self.isPrimaryResidence = nil
    end
end

function ZO_CollectibleData:SetOutfitStyleData()
    if self:IsOutfitStyle() then
        local referenceId = self.referenceId
        self.isArmorStyle = IsOutfitStyleArmor(referenceId)
        self.isWeaponStyle = IsOutfitStyleWeapon(referenceId)
        self.visualArmorType = self.isArmorStyle and GetOutfitStyleVisualArmorType(referenceId) or nil
        self.weaponModelType = self.isWeaponStyle and GetOutfitStyleWeaponModelType(referenceId) or nil
        self.outfitStyleItemStyleId = GetOutfitStyleItemStyleId(referenceId)
        self.outfitStyleFreeConversionCollectible = GetOutfitStyleFreeConversionCollectibleId(referenceId)
    else
        self.isArmorStyle = nil
        self.isWeaponStyle = nil
        self.visualArmorType = nil
        self.weaponModelType = nil
        self.outfitStyleItemStyleId = nil
        self.outfitStyleFreeConversionCollectible = nil
    end
end

function ZO_CollectibleData:SetupGridCategoryName()
    if self:IsOutfitStyle() then
        if self.isArmorStyle then
            self.gridHeaderName = GetString("SI_VISUALARMORTYPE", self.visualArmorType)
        else
            self.gridHeaderName = GetString("SI_WEAPONMODELTYPE", self.weaponModelType)
        end
    else
        -- If we ever want to support more grid based layouts of collectibles, we can design layouts for the groupings and use categoryName to control it, based on the collectible types
        self.gridHeaderName = nil
    end
end

function ZO_CollectibleData:Refresh()
    local collectibleId = self.collectibleId
    local previousUnlockState = self.unlockState
    for actorCategory = GAMEPLAY_ACTOR_CATEGORY_ITERATION_BEGIN, GAMEPLAY_ACTOR_CATEGORY_ITERATION_END do
        self.isActiveByActorCategory[actorCategory] = IsCollectibleActive(collectibleId, actorCategory)
    end
    self.nickname = GetCollectibleNickname(collectibleId)
    self.unlockState = GetCollectibleUnlockStateById(collectibleId)
    self:SetNew(IsCollectibleNew(collectibleId))
    self.isRenameable = IsCollectibleRenameable(collectibleId)
    self.isSlottable = IsCollectibleSlottable(collectibleId)
    self.cachedNameWithNickname = nil
    self.isBlacklisted = IsCollectibleBlacklisted(collectibleId)
    self.questState = GetCollectibleAssociatedQuestState(collectibleId)

    local categoryData = self:GetCategoryData()
    if categoryData then
        local specializedSortedCollectibles = categoryData:GetSpecializedSortedCollectiblesObject()
        if previousUnlockState ~= self.unlockState then
            specializedSortedCollectibles:HandleLockStatusChanged(self)
        end
    end
end

function ZO_CollectibleData:RefreshHousingData()
    if self:IsHouse() then
        local wasPrimaryResidence = self.isPrimaryResidence
        self.isPrimaryResidence = IsPrimaryHouse(self.referenceId)

        local categoryData = self:GetCategoryData()
        if categoryData then
            local specializedSortedCollectibles = categoryData:GetSpecializedSortedCollectiblesObject()
            if wasPrimaryResidence ~= self.isPrimaryResidence then
                specializedSortedCollectibles:HandlePrimaryResidenceChanged(self)
            end
        end
    end
end

function ZO_CollectibleData:GetCategoryData()
    return self.categoryData
end

function ZO_CollectibleData:GetIndex()
    return self.collectibleIndex
end

function ZO_CollectibleData:GetId()
    return self.collectibleId
end

function ZO_CollectibleData:GetName()
    return self.name
end

function ZO_CollectibleData:GetFormattedName()
    return ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, self.name)
end

function ZO_CollectibleData:GetNameWithNickname()
    if not self.cachedNameWithNickname then
        local nickname = self.nickname
        if nickname and nickname ~= "" then
            self.cachedNameWithNickname = zo_strformat(SI_COLLECTIBLE_NAME_WITH_NICKNAME_FORMATTER, self.name, nickname)
        else
            self.cachedNameWithNickname = ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, self.name)
        end
    end

    return self.cachedNameWithNickname
end

function ZO_CollectibleData:GetRawNameWithNickname()
    local nickname = self.nickname
    if nickname and nickname ~= "" then
        return zo_strformat(SI_COLLECTIBLE_NAME_WITH_NICKNAME_RAW, self.name, nickname)
    else
        return self.name
    end
end

function ZO_CollectibleData:GetDescription()
    return GetCollectibleDescription(self.collectibleId)
end

function ZO_CollectibleData:GetIcon()
    return self.icon
end

function ZO_CollectibleData:GetUnlockState()
    return self.unlockState
end

function ZO_CollectibleData:IsUnlocked()
    return self.unlockState ~= COLLECTIBLE_UNLOCK_STATE_LOCKED
end

function ZO_CollectibleData:IsLocked()
    return self.unlockState == COLLECTIBLE_UNLOCK_STATE_LOCKED
end

function ZO_CollectibleData:IsOwned()
    return self.unlockState == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED
end

function ZO_CollectibleData:IsPurchasable()
    return IsCollectiblePurchasable(self.collectibleId)
end

function ZO_CollectibleData:IsActive(actorCategory)
    local actorCategory = actorCategory or GAMEPLAY_ACTOR_CATEGORY_PLAYER
    return self.isActiveByActorCategory[actorCategory]
end

function ZO_CollectibleData:IsBlacklisted()
    return self.isBlacklisted
end

function ZO_CollectibleData:GetCategoryType()
    return self.categoryType
end

function ZO_CollectibleData:GetSpecializedCategoryType()
    return self.specializedCategoryType or SPECIALIZED_COLLECTIBLE_TYPE_NONE
end

function ZO_CollectibleData:GetCategoryTypeDisplayName()
    if self.specializedCategoryType then
        return GetString("SI_SPECIALIZEDCOLLECTIBLETYPE", self.specializedCategoryType)
    else
        return GetString("SI_COLLECTIBLECATEGORYTYPE", self.categoryType)
    end
end

function ZO_CollectibleData:IsCategoryType(categoryType)
    return self.categoryType == categoryType
end

function ZO_CollectibleData:GetCollectibleAssociatedQuestState()
    return self.questState
end

do
    local DEFAULT_HOUSE_HINT = GetString(SI_HOUSING_BOOK_AVAILABLE_FOR_PURCHASE)

    function ZO_CollectibleData:GetHint()
        local hint = GetCollectibleHint(self.collectibleId)
        if self:IsHouse() and hint == "" then
            hint = DEFAULT_HOUSE_HINT
        end
        return hint
    end
end

function ZO_CollectibleData:GetKeyboardBackgroundImage()
    return GetCollectibleKeyboardBackgroundImage(self.collectibleId)
end

function ZO_CollectibleData:GetGamepadBackgroundImage()
    return GetCollectibleGamepadBackgroundImage(self.collectibleId)
end

function ZO_CollectibleData:GetNickname()
    return self.nickname
end

function ZO_CollectibleData:GetFormattedNickname()
    if self.nickname ~= "" then
        return ZO_CachedStrFormat(SI_TOOLTIP_COLLECTIBLE_NICKNAME, self.nickname)
    else
        return ""
    end
end

function ZO_CollectibleData:IsRenameable()
    return self.isRenameable
end

function ZO_CollectibleData:IsSlottable()
    return self.isSlottable
end

function ZO_CollectibleData:IsNew()
    return self.isNew
end

function ZO_CollectibleData:SetNew(isNew)
    if self.isNew ~= isNew then
        self.isNew = isNew
        local categoryData = self:GetCategoryData()
        if categoryData then
            categoryData:UpdateNewCache(self)
        end
    end
end

function ZO_CollectibleData:GetReferenceId()
    return self.referenceId
end

function ZO_CollectibleData:GetSortOrder()
    return GetCollectibleSortOrder(self.collectibleId)
end

function ZO_CollectibleData:IsStory()
    return self.categoryType == COLLECTIBLE_CATEGORY_TYPE_DLC or self.categoryType == COLLECTIBLE_CATEGORY_TYPE_CHAPTER
end

function ZO_CollectibleData:IsUnlockedViaSubscription()
    return self.unlockedViaSubscription
end

function ZO_CollectibleData:GetQuestName()
    return self.questName
end

function ZO_CollectibleData:GetQuestDescription()
    return self.questDescription
end

function ZO_CollectibleData:IsHouse()
    return self.categoryType == COLLECTIBLE_CATEGORY_TYPE_HOUSE
end

function ZO_CollectibleData:GetHouseLocation()
    return self.houseLocation
end

function ZO_CollectibleData:GetFormattedHouseLocation()
    return ZO_CachedStrFormat(SI_ZONE_NAME, self.houseLocation)
end

function ZO_CollectibleData:GetHouseCategoryType()
    return self.houseCategoryType
end

function ZO_CollectibleData:IsPrimaryResidence()
    return self.isPrimaryResidence
end

function ZO_CollectibleData:IsOutfitStyle()
    return self.categoryType == COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE
end

function ZO_CollectibleData:IsArmorStyle()
    return self.isArmorStyle
end

function ZO_CollectibleData:IsWeaponStyle()
    return self.isWeaponStyle
end

function ZO_CollectibleData:GetVisualArmorType()
    return self.visualArmorType
end

function ZO_CollectibleData:GetWeaponModelType()
    return self.weaponModelType
end

function ZO_CollectibleData:GetOutfitGearType()
    return self:IsArmorStyle() and self:GetVisualArmorType() or self:GetWeaponModelType()
end

function ZO_CollectibleData:GetOutfitStyleItemStyleId()
    return self.outfitStyleItemStyleId
end

function ZO_CollectibleData:GetOutfitStyleItemStyleName()
    return GetItemStyleName(self.outfitStyleItemStyleId)
end

function ZO_CollectibleData:GetOutfitStyleCost()
    if self:IsOutfitStyle() then
        local outfitStyleCost = GetOutfitStyleCost(self.referenceId)
        if outfitStyleCost ~= 0 and self.outfitStyleFreeConversionCollectible then
            local freeConversionCollectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(self.outfitStyleFreeConversionCollectible)
            if freeConversionCollectibleData and freeConversionCollectibleData:IsUnlocked() then
                return 0
            end
        end
        return outfitStyleCost
    end
    return 0 -- No one should ever hit this code
end

function ZO_CollectibleData:GetOutfitStyleFreeConversionCollectible()
    return self.outfitStyleFreeConversionCollectible
end

function ZO_CollectibleData:IsBlocked()
    return IsCollectibleBlocked(self.collectibleId)
end

function ZO_CollectibleData:IsCollectibleAvailableToActorCategory(aActorCategory)
    return IsCollectibleAvailableToActorCategory(self.collectibleId, aActorCategory)
end

function ZO_CollectibleData:IsCollectibleAvailableToCompanion()
    return self:IsCollectibleAvailableToActorCategory(GAMEPLAY_ACTOR_CATEGORY_COMPANION)
end

function ZO_CollectibleData:IsCollectibleCategoryUsable(actorCategory)
    return IsCollectibleCategoryUsable(self.categoryType, actorCategory)
end

function ZO_CollectibleData:IsCollectibleCategoryCompanionUsable()
    return self:IsCollectibleCategoryUsable(GAMEPLAY_ACTOR_CATEGORY_COMPANION)
end

function ZO_CollectibleData:IsUsable(actorCategory)
    local actorCategory = actorCategory or GAMEPLAY_ACTOR_CATEGORY_PLAYER
    return IsCollectibleUsable(self.collectibleId, actorCategory)
end

function ZO_CollectibleData:Use(actorCategory)
    -- combination fragment collectibles can consume collectibles on use
    -- so we want to show a confirmation dialog if it consumes a non-fragment collectible
    if self:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT) then
        if not CheckPlayerCanPerformCombinationAndWarn(self.referenceId) then
            return
        end
        -- this combination might be acting as an "evolution" of a collectible into another collectible
        -- like the indrik, so find the first non-fragment collectible and treat that as the base collectible
        local baseCollectibleId = GetCombinationFirstNonFragmentCollectibleComponentId(self.referenceId)
        if baseCollectibleId ~= 0 then
            local function AcceptCombinationCallback()
                UseCollectible(self.collectibleId, actorCategory)
            end

            local function DeclineCombinationCallback()
            end

            local unlockedCollectibleId = GetCombinationUnlockedCollectible(self.referenceId)
            ZO_CombinationPromptManager_ShowEvolutionPrompt(baseCollectibleId, unlockedCollectibleId, AcceptCombinationCallback, DeclineCombinationCallback)
            return
        end
    end

    UseCollectible(self.collectibleId, actorCategory)
end

function ZO_CollectibleData:GetPrimaryInteractionStringId(actorCategory)
    local categoryType = self.categoryType
    if self:IsActive(actorCategory) then
        if categoryType == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET or categoryType == COLLECTIBLE_CATEGORY_TYPE_ASSISTANT or categoryType == COLLECTIBLE_CATEGORY_TYPE_COMPANION then
            return SI_COLLECTIBLE_ACTION_DISMISS
        else
            return SI_COLLECTIBLE_ACTION_PUT_AWAY
        end
    else
        if categoryType == COLLECTIBLE_CATEGORY_TYPE_MEMENTO then
            return SI_COLLECTIBLE_ACTION_USE
        elseif categoryType == COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT then
            return SI_COLLECTIBLE_ACTION_COMBINE
        elseif categoryType == COLLECTIBLE_CATEGORY_TYPE_COMPANION then
            local activeState = self:GetCollectibleAssociatedQuestState()
            if activeState == COLLECTIBLE_ASSOCIATED_QUEST_STATE_INACTIVE then
                return SI_COLLECTIBLE_ACTION_ACCEPT_QUEST
            elseif activeState == COLLECTIBLE_ASSOCIATED_QUEST_STATE_ACCEPTED then
                return nil
            else
                return SI_COLLECTIBLE_ACTION_SET_ACTIVE
            end               
        else
            return SI_COLLECTIBLE_ACTION_SET_ACTIVE
        end
    end
end

function ZO_CollectibleData:IsPlaceableFurniture()
    return IsCollectibleCategoryPlaceableFurniture(self.categoryType)
end

function ZO_CollectibleData:IsValidForPlayer()
    return IsCollectibleValidForPlayer(self.collectibleId)
end

function ZO_CollectibleData:HasVisualAppearence()
    return self.hasVisualAppearence
end

function ZO_CollectibleData:WouldBeHidden(actorCategory)
    return WouldCollectibleBeHidden(self.collectibleId, actorCategory)
end

function ZO_CollectibleData:IsVisualLayerHidden(actorCategory)
    return self.hasVisualAppearence and self:IsActive(actorCategory) and self:WouldBeHidden(actorCategory)
end

function ZO_CollectibleData:IsVisualLayerShowing(actorCategory)
    return self.hasVisualAppearence and self:IsActive(actorCategory) and not self:WouldBeHidden(actorCategory)
end

function ZO_CollectibleData:GetNotificationId()
    return self.notificationId
end

function ZO_CollectibleData:SetNotificationId(notificationId)
    self.notificationId = notificationId
end

do
    local IS_HIDDEN_FROM_COLLECTION_MODE =
    {
        [COLLECTIBLE_HIDE_MODE_NONE] = function() return false end,
        [COLLECTIBLE_HIDE_MODE_ALWAYS] = function() return true end,
        [COLLECTIBLE_HIDE_MODE_WHEN_LOCKED] = function(collectibleData) return collectibleData:IsLocked() end,
        [COLLECTIBLE_HIDE_MODE_WHEN_LOCKED_REQUIREMENT] = function(collectibleData) return collectibleData:IsCollectibleDynamicallyHidden() end,
    }

    function ZO_CollectibleData:IsHiddenFromCollection()
        local modeFunction = IS_HIDDEN_FROM_COLLECTION_MODE[self.hideMode]
        return modeFunction(self)
    end
end

function ZO_CollectibleData:IsCollectibleDynamicallyHidden()
    return self:IsLocked() and IsCollectibleDynamicallyHidden(self.collectibleId)
end

function ZO_CollectibleData:IsShownInCollection()
    return not self:IsHiddenFromCollection()
end

do
    local ARMOR_VISUAL_TO_SOUND_ID =
    {
        [VISUAL_ARMORTYPE_LIGHT]        = SOUNDS.OUTFIT_ARMOR_TYPE_LIGHT,
        [VISUAL_ARMORTYPE_MEDIUM]       = SOUNDS.OUTFIT_ARMOR_TYPE_MEDIUM,
        [VISUAL_ARMORTYPE_HEAVY]        = SOUNDS.OUTFIT_ARMOR_TYPE_HEAVY,
        [VISUAL_ARMORTYPE_UNDAUNTED]    = SOUNDS.OUTFIT_ARMOR_TYPE_UNDAUNTED,
        [VISUAL_ARMORTYPE_CLOTHING]     = SOUNDS.OUTFIT_ARMOR_TYPE_CLOTHING,
        [VISUAL_ARMORTYPE_SIGNATURE]    = SOUNDS.OUTFIT_ARMOR_TYPE_SIGNATURE,
    }

    local WEAPON_VISUAL_TO_SOUND_ID =
    {
        [WEAPON_MODEL_TYPE_AXE]     = SOUNDS.OUTFIT_WEAPON_TYPE_AXE,
        [WEAPON_MODEL_TYPE_HAMMER]  = SOUNDS.OUTFIT_WEAPON_TYPE_MACE,
        [WEAPON_MODEL_TYPE_SWORD]   = SOUNDS.OUTFIT_WEAPON_TYPE_SWORD,
        [WEAPON_MODEL_TYPE_DAGGER]  = SOUNDS.OUTFIT_WEAPON_TYPE_DAGGER,
        [WEAPON_MODEL_TYPE_BOW]     = SOUNDS.OUTFIT_WEAPON_TYPE_BOW,
        [WEAPON_MODEL_TYPE_STAFF]   = SOUNDS.OUTFIT_WEAPON_TYPE_STAFF,
        [WEAPON_MODEL_TYPE_SHIELD]  = SOUNDS.OUTFIT_WEAPON_TYPE_SHIELD,
        [WEAPON_MODEL_TYPE_RUNE]    = SOUNDS.OUTFIT_WEAPON_TYPE_RUNE,
    }

    function ZO_CollectibleData:GetOutfitStyleEquipSound()
        if self.visualArmorType then
            return ARMOR_VISUAL_TO_SOUND_ID[self.visualArmorType]
        elseif self.weaponModelType then
            return WEAPON_VISUAL_TO_SOUND_ID[self.weaponModelType]
        end
    end
end

-----------------------------------
-- Specialized Sorted Collectibles
-----------------------------------

ZO_SpecializedSortedCollectibles = ZO_Object:Subclass()

function ZO_SpecializedSortedCollectibles:New(...)
    local object = ZO_Object:New(self)
    object:Initialize(...)
    return object
end

function ZO_SpecializedSortedCollectibles:Initialize()
    self.dirty = false
    self.sortedCollectibles = {}
end

function ZO_SpecializedSortedCollectibles:GetCollectibles()
    if self.dirty then
        self:RefreshSort()
    end

    return self.sortedCollectibles
end

function ZO_SpecializedSortedCollectibles:InsertCollectible(collectibleData)
    assert(false) -- override in derived classes
end

function ZO_SpecializedSortedCollectibles:OnInsertFinished()
    assert(false) -- override in derived classes
end

function ZO_SpecializedSortedCollectibles:RefreshSort()
    assert(false) -- override in derived classes
end

function ZO_SpecializedSortedCollectibles:CanIterateCollectibles()
    return true
end

function ZO_SpecializedSortedCollectibles:HandleLockStatusChanged(collectibleData)
    -- By default, do nothing
end

function ZO_SpecializedSortedCollectibles:HandlePrimaryResidenceChanged(collectibleData)
    -- By default, do nothing
end

-----------------------------
-- Default Sorted Collectible
-----------------------------

ZO_DefaultSortedCollectibles = ZO_SpecializedSortedCollectibles:Subclass()

function ZO_DefaultSortedCollectibles:New(...)
    return ZO_SpecializedSortedCollectibles.New(self, ...)
end

function ZO_DefaultSortedCollectibles:Initialize(owner)
    ZO_SpecializedSortedCollectibles.Initialize(self)
    self.owner = owner

    self.collectibleNameLookupTable = {}
end


function ZO_DefaultSortedCollectibles:InsertCollectible(collectibleData)
    table.insert(self.sortedCollectibles, collectibleData)

    local collectibleId = collectibleData:GetId()
    if not self.collectibleNameLookupTable[collectibleId] then
        self.collectibleNameLookupTable[collectibleId] =
        {
            name = collectibleData:GetName(),
            id = collectibleId
        }
    end

    self.dirty = true
end

function ZO_DefaultSortedCollectibles:HandleLockStatusChanged(collectibleData)
    self.dirty = true
end

function ZO_DefaultSortedCollectibles:RefreshSort()
    if self.dirty then
        local collectibleNameLookupTable = self.collectibleNameLookupTable
        table.sort(self.sortedCollectibles, function(left, right) 
            if left:IsUnlocked() ~= right:IsUnlocked() then
                return left:IsUnlocked()
            elseif left:GetSortOrder() ~= right:GetSortOrder() then
                return left:GetSortOrder() < right:GetSortOrder()
            elseif left:IsValidForPlayer() ~= right:IsValidForPlayer() then
                return left:IsValidForPlayer()
            else
                return collectibleNameLookupTable[left:GetId()] < collectibleNameLookupTable[right:GetId()]
            end
        end)
    end

    self.dirty = false
end

function ZO_DefaultSortedCollectibles:OnInsertFinished()
    local tempTable = {}
    for _, collectibleNameData in pairs(self.collectibleNameLookupTable) do
        table.insert(tempTable, collectibleNameData)
    end

    table.sort(tempTable, function(left, right)
        return left.name < right.name
    end)

    self.collectibleNameLookupTable = {}
    
    for position, collectibleNameData in ipairs(tempTable) do
        self.collectibleNameLookupTable[collectibleNameData.id] = position
    end
end

-------------------------------------------------------
-- Specialized Sorted Collectibles Outfit Style Types
-------------------------------------------------------

ZO_SpecializedSortedOutfitStyleTypes = ZO_SpecializedSortedCollectibles:Subclass()

function ZO_SpecializedSortedOutfitStyleTypes:New(...)
    return ZO_SpecializedSortedCollectibles.New(self, ...)
end

function ZO_SpecializedSortedOutfitStyleTypes:Initialize()
    ZO_SpecializedSortedCollectibles.Initialize(self)

    self.itemStyleNameLookupTable = {}
end

function ZO_SpecializedSortedOutfitStyleTypes:InsertCollectible(collectibleData)
    local type = collectibleData:GetOutfitGearType()
    if type then
        local styles = self.sortedCollectibles[type] 
        if not styles then
            styles = ZO_SpecializedSortedOutfitStyles:New(self)
            self.sortedCollectibles[type] = styles
        end

        local itemStyleId = collectibleData:GetOutfitStyleItemStyleId()
        if not self.itemStyleNameLookupTable[itemStyleId] then
            self.itemStyleNameLookupTable[itemStyleId] =
            {
                name = collectibleData:GetOutfitStyleItemStyleName(),
                id = itemStyleId
            }
        end

        styles:InsertCollectible(collectibleData)
        self.dirty = true
    end
end

function ZO_SpecializedSortedOutfitStyleTypes:HandleLockStatusChanged(collectibleData)
    local type = collectibleData:GetOutfitGearType()
    if type and self.sortedCollectibles[type] then
        self.sortedCollectibles[type]:HandleLockStatusChanged(collectibleData)
        self.dirty = true
    end
end

function ZO_SpecializedSortedOutfitStyleTypes:RefreshSort()
    if self.dirty then
        for _, collectibleDataForType in pairs(self.sortedCollectibles) do
            collectibleDataForType:RefreshSort()
        end

        self.dirty = false
    end
end

function ZO_SpecializedSortedOutfitStyleTypes:OnInsertFinished()
    local tempTable = {}
    for _, styleNameData in pairs(self.itemStyleNameLookupTable) do
        table.insert(tempTable, styleNameData)
    end

    table.sort(tempTable, function(left, right)
        return left.name < right.name
    end)
    
    for position, styleNameData in ipairs(tempTable) do
        self.itemStyleNameLookupTable[styleNameData.id] = position
    end

    for _, collectibleDataForType in pairs(self.sortedCollectibles) do
        collectibleDataForType:OnInsertFinished()
    end

    self:RefreshSort()
end

function ZO_SpecializedSortedOutfitStyleTypes:CanIterateCollectibles()
    -- Outfit styles are sorted with a custom structure that requires manual looping
    return false
end

--------------------------------------------------
-- Specialized Sorted Collectibles Outfit Styles
--------------------------------------------------

ZO_SpecializedSortedOutfitStyles = ZO_DefaultSortedCollectibles:Subclass()

function ZO_SpecializedSortedOutfitStyles:New(...)
    return ZO_DefaultSortedCollectibles.New(self, ...)
end

function ZO_SpecializedSortedOutfitStyles:RefreshSort()
    if self.dirty then
        local itemStyleNameLookupTable = self.owner.itemStyleNameLookupTable
        local collectibleNameLookupTable = self.collectibleNameLookupTable
        table.sort(self.sortedCollectibles, function(left, right) 
            if left:IsUnlocked() ~= right:IsUnlocked() then
                return left:IsUnlocked()
            elseif left:GetOutfitStyleItemStyleId() ~= right:GetOutfitStyleItemStyleId() then
                return itemStyleNameLookupTable[left:GetOutfitStyleItemStyleId()] < itemStyleNameLookupTable[right:GetOutfitStyleItemStyleId()]
            elseif left:GetSortOrder() ~= right:GetSortOrder() then
                return left:GetSortOrder() < right:GetSortOrder()
            else
                return collectibleNameLookupTable[left:GetId()] < collectibleNameLookupTable[right:GetId()]
            end
        end)
    end

    self.dirty = false
end

-----------------------------------------
-- Specialized Sorted Collectibles Houses
-----------------------------------------

ZO_SpecializedSortedHouses = ZO_DefaultSortedCollectibles:Subclass()

function ZO_SpecializedSortedHouses:New(...)
    return ZO_DefaultSortedCollectibles.New(self, ...)
end

function ZO_SpecializedSortedHouses:HandlePrimaryResidenceChanged(collectibleData)
    self.dirty = true
end

function ZO_SpecializedSortedHouses:RefreshSort()
    if self.dirty then
        local collectibleNameLookupTable = self.collectibleNameLookupTable
        table.sort(self.sortedCollectibles, function(left, right)
            if left:IsPrimaryResidence() ~= right:IsPrimaryResidence() then
                return left:IsPrimaryResidence()
            elseif left:IsUnlocked() ~= right:IsUnlocked() then
                return left:IsUnlocked()
            elseif left:GetSortOrder() ~= right:GetSortOrder() then
                return left:GetSortOrder() < right:GetSortOrder()
            else
                return collectibleNameLookupTable[left:GetId()] < collectibleNameLookupTable[right:GetId()]
            end
        end)
    end

    self.dirty = false
end

------------------------------------------
-- Specialized Sorted Collectibles Stories
------------------------------------------

ZO_SpecializedSortedStories = ZO_DefaultSortedCollectibles:Subclass()

function ZO_SpecializedSortedStories:New(...)
    return ZO_DefaultSortedCollectibles.New(self, ...)
end

function ZO_SpecializedSortedStories:HandleLockStatusChanged(collectibleData)
    -- Do nothing, stories don't re-sort, their order is based on release date
end

function ZO_SpecializedSortedStories:RefreshSort()
    if self.dirty then
        local collectibleNameLookupTable = self.collectibleNameLookupTable
        table.sort(self.sortedCollectibles, function(left, right)
            if left:GetSortOrder() ~= right:GetSortOrder() then
                return left:GetSortOrder() < right:GetSortOrder()
            else
                return collectibleNameLookupTable[left:GetId()] < collectibleNameLookupTable[right:GetId()]
            end
        end)
    end

    self.dirty = false
end
-------------------
-- Category Base --
-------------------

ZO_CollectibleCategoryData = ZO_Object:Subclass()

function ZO_CollectibleCategoryData:New(...)
    local object = ZO_Object:New(self)
    object:Initialize(...)
    return object
end

function ZO_CollectibleCategoryData:Initialize(masterCollectibleObjectPool, masterSubcategoryObjectPool)
    -- orderedCollectibles is the order they came from C in.  specializedSortedCollectibles is the sorted list, based on criterea set for the category type
    self.orderedCollectibles = {}
    self.newCollectibleIdsCache = {}
    self.collectibleObjectPool = ZO_MetaPool:New(masterCollectibleObjectPool)
    
    if masterSubcategoryObjectPool then
        self.orderedSubcategories = {}
        self.subcategoryObjectPool = ZO_MetaPool:New(masterSubcategoryObjectPool)
        self.isTopLevelCategory = true
    else
        self.isTopLevelCategory = false
    end
end

function ZO_CollectibleCategoryData:Reset()
    ZO_ClearNumericallyIndexedTable(self.orderedCollectibles)
    ZO_ClearTable(self.newCollectibleIdsCache)
    self.collectibleObjectPool:ReleaseAllObjects()

    if self.isTopLevelCategory then
        ZO_ClearNumericallyIndexedTable(self.orderedSubcategories)
        self.subcategoryObjectPool:ReleaseAllObjects()
    end
end

function ZO_CollectibleCategoryData:IsTopLevelCategory()
    return self.isTopLevelCategory
end

function ZO_CollectibleCategoryData:IsSubcategory()
    return not self.isTopLevelCategory
end

function ZO_CollectibleCategoryData:GetParentData()
    if self:IsSubcategory() then
        return ZO_COLLECTIBLE_DATA_MANAGER:GetCategoryDataByIndicies(self.categoryIndex)
    end
    return nil
end

function ZO_CollectibleCategoryData:GetId()
    return self.categoryId
end

function ZO_CollectibleCategoryData:GetCategorySpecialization()
    return self.categorySpecialization
end

function ZO_CollectibleCategoryData:IsSpecializedCategory(specializedCategoryType)
    return self.categorySpecialization == specializedCategoryType
end

function ZO_CollectibleCategoryData:IsOutfitStylesCategory()
    return self.categorySpecialization == COLLECTIBLE_CATEGORY_SPECIALIZATION_OUTFIT_STYLES
end

function ZO_CollectibleCategoryData:IsHousingCategory()
    return self.categorySpecialization == COLLECTIBLE_CATEGORY_SPECIALIZATION_HOUSING
end

function ZO_CollectibleCategoryData:IsDLCCategory()
    return self.categorySpecialization == COLLECTIBLE_CATEGORY_SPECIALIZATION_DLC
end

function ZO_CollectibleCategoryData:IsStandardCategory()
    return self.categorySpecialization == COLLECTIBLE_CATEGORY_SPECIALIZATION_NONE
end

function ZO_CollectibleCategoryData:GetCategoryIndicies()
    return self.categoryIndex, self.subcategoryIndex
end

function ZO_CollectibleCategoryData:BuildData(categoryIndex, subcategoryIndex)
    self.categoryIndex, self.subcategoryIndex = categoryIndex, subcategoryIndex
    self.categoryId = GetCollectibleCategoryId(categoryIndex, subcategoryIndex)

    self.name = GetCollectibleCategoryNameByCategoryId(self.categoryId)
    self.keyboardNormalIcon, self.keyboardPressedIcon, self.keyboardMousedOverIcon, self.disabledIcon = GetCollectibleCategoryKeyboardIcons(categoryIndex, subcategoryIndex)
    self.gamepadIcon = GetCollectibleCategoryGamepadIcon(categoryIndex, subcategoryIndex)

    if self.isTopLevelCategory then
        local numSubcategories = GetNumSubcategoriesInCollectibleCategory(categoryIndex)
        for loopSubcategoryIndex = 1, numSubcategories do
            local subcategoryData = self.subcategoryObjectPool:AcquireObject()
            subcategoryData:BuildData(categoryIndex, loopSubcategoryIndex)
            table.insert(self.orderedSubcategories, subcategoryData)
        end
    else
        self.numSubcategories = 0
    end

    self.categorySpecialization = GetCollectibleCategorySpecialization(categoryIndex)
    self.specializedSortedCollectibles = self:CreateSpecializedSortedCollectiblesTable()

    local numCollectibles = GetNumCollectiblesInCollectibleCategory(categoryIndex, subcategoryIndex)
    for collectibleIndex = 1, numCollectibles do
        local collectibleData = self.collectibleObjectPool:AcquireObject()
        collectibleData:BuildData(self, collectibleIndex)
        table.insert(self.orderedCollectibles, collectibleData)
        self.specializedSortedCollectibles:InsertCollectible(collectibleData)
    end

    self.specializedSortedCollectibles:OnInsertFinished()

    ZO_COLLECTIBLE_DATA_MANAGER:MapCategoryData(self)
end

function ZO_CollectibleCategoryData:CreateSpecializedSortedCollectiblesTable()
    if self:IsOutfitStylesCategory() then
        return ZO_SpecializedSortedOutfitStyleTypes:New()
    elseif self:IsHousingCategory() then
        return ZO_SpecializedSortedHouses:New()
    elseif self:IsDLCCategory() then
        return ZO_SpecializedSortedStories:New()
    else
        return ZO_DefaultSortedCollectibles:New()
    end
end

function ZO_CollectibleCategoryData:GetName()
    return self.name
end

function ZO_CollectibleCategoryData:GetFormattedName()
    return ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, self.name)
end

function ZO_CollectibleCategoryData:GetKeyboardIcons()
    return self.keyboardNormalIcon, self.keyboardPressedIcon, self.keyboardMousedOverIcon, self.disabledIcon
end

function ZO_CollectibleCategoryData:GetGamepadIcon()
    return self.gamepadIcon
end

function ZO_CollectibleCategoryData:GetNumSubcategories()
    return #self.orderedSubcategories
end

function ZO_CollectibleCategoryData:GetSubcategoryData(subcategoryIndex)
    if self.isTopLevelCategory then
        return self.orderedSubcategories[subcategoryIndex]
    end
    return nil
end

function ZO_CollectibleCategoryData:SubcategoryIterator(subcategoryFilterFunctions) -- ... Are filter functions that take categoryData as a param
    return ZO_FilteredNumericallyIndexedTableIterator(self.orderedSubcategories, subcategoryFilterFunctions)
end

function ZO_CollectibleCategoryData:GetNumCollectibles()
    return #self.orderedCollectibles
end

function ZO_CollectibleCategoryData:GetCollectibleDataByIndex(collectibleIndex)
    return self.orderedCollectibles[collectibleIndex]
end

function ZO_CollectibleCategoryData:GetCollectibleDataBySpecializedSort()
    return self.specializedSortedCollectibles:GetCollectibles()
end

function ZO_CollectibleCategoryData:GetSpecializedSortedCollectiblesObject()
    return self.specializedSortedCollectibles
end

function ZO_CollectibleCategoryData:SortedCollectibleIterator(collectibleFilterFunctions)
    local collectiblesTable = self.specializedSortedCollectibles:CanIterateCollectibles() and self.specializedSortedCollectibles:GetCollectibles() or self.orderedCollectibles
    return ZO_FilteredNumericallyIndexedTableIterator(collectiblesTable, collectibleFilterFunctions)
end

function ZO_CollectibleCategoryData:CollectibleIterator(collectibleFilterFunctions)
    return ZO_FilteredNumericallyIndexedTableIterator(self.orderedCollectibles, collectibleFilterFunctions)
end

function ZO_CollectibleCategoryData:GetAllCollectibleDataObjects(collectibleFilterFunctions, sorted) 
    local foundCollectibleDataObjects = {}
    return self:AppendAllCollectibleDataObjects(foundCollectibleDataObjects, collectibleFilterFunctions, sorted)
end

function ZO_CollectibleCategoryData:AppendAllCollectibleDataObjects(foundCollectibleDataObjects, collectibleFilterFunctions, sorted)
    local iterator = sorted and ZO_CollectibleCategoryData.SortedCollectibleIterator or ZO_CollectibleCategoryData.CollectibleIterator

    for _, collectibleData in iterator(self, collectibleFilterFunctions) do
        table.insert(foundCollectibleDataObjects, collectibleData)
    end

    if self.isTopLevelCategory then
        for _, subcategoryData in ipairs(self.orderedSubcategories) do
            subcategoryData:AppendAllCollectibleDataObjects(foundCollectibleDataObjects, collectibleFilterFunctions, sorted)
        end
    end

    return foundCollectibleDataObjects
end

function ZO_CollectibleCategoryData:HasAnyNewCollectibles()
    if NonContiguousCount(self.newCollectibleIdsCache) > 0 then
        return true
    end

    if self.isTopLevelCategory then
        for _, subcategoryData in ipairs(self.orderedSubcategories) do
            if subcategoryData:HasAnyNewCollectibles() then
                return true
            end
        end
    end

    return false
end

function ZO_CollectibleCategoryData:HasAnyNewCompanionCollectibles()
    if NonContiguousCount(self.newCollectibleIdsCache) > 0 and self:HasAnyCompanionUsableCollectibles() then
        return true
    end

    if self.isTopLevelCategory then
        for _, subcategoryData in ipairs(self.orderedSubcategories) do
            if subcategoryData:HasAnyNewCompanionCollectibles() then
                return true
            end
        end
    end

    return false
end

function ZO_CollectibleCategoryData:UpdateNewCache(collectibleData)
    local collectibleId = collectibleData:GetId()
    local isNew = collectibleData:IsNew()
    self.newCollectibleIdsCache[collectibleId] = isNew or nil
end

function ZO_CollectibleCategoryData:HasAnyUnlockedCollectibles()
    for _, collectibleData in ipairs(self.orderedCollectibles) do
        if collectibleData:IsUnlocked() then
            return true
        end
    end

    if self.isTopLevelCategory then
        for _, subcategoryData in ipairs(self.orderedSubcategories) do
            if subcategoryData:HasAnyUnlockedCollectibles() then
                return true
            end
        end
    end

    return false
end

function ZO_CollectibleCategoryData:HasShownCollectiblesInCollection()
    for _, collectibleData in ipairs(self.orderedCollectibles) do
        if not collectibleData:IsHiddenFromCollection() then
            return true
        end
    end

    if self.isTopLevelCategory then
        for _, subcategoryData in ipairs(self.orderedSubcategories) do
            if subcategoryData:HasShownCollectiblesInCollection() then
                return true
            end
        end
    end

    return false
end

function ZO_CollectibleCategoryData:HasAnyCompanionUsableCollectibles()
    for _, collectibleData in ipairs(self.orderedCollectibles) do
        if collectibleData:IsCollectibleCategoryCompanionUsable() and collectibleData:IsCollectibleAvailableToCompanion() then
            return true
        end
    end

    if self.isTopLevelCategory then
        for _, subcategoryData in ipairs(self.orderedSubcategories) do
            if subcategoryData:HasAnyCompanionUsableCollectibles() then
                return true
            end
        end
    end

    return false
end

function ZO_CollectibleCategoryData:GetCollectibleCategoryTypesInCategory()
    if not self.collectibleCategoryTypesInCategory then
        local collectibleCategoryTypesInCategory = {}
        for _, collectibleData in self:CollectibleIterator() do
            collectibleCategoryTypesInCategory[collectibleData:GetCategoryType()] = true
        end

        if self.isTopLevelCategory then
            for _, subcategoryData in self:SubcategoryIterator() do
                local collectibleCategoryTypesInSubcategory = subcategoryData:GetCollectibleCategoryTypesInCategory()
                for categoryType in pairs(collectibleCategoryTypesInSubcategory) do
                    collectibleCategoryTypesInCategory[categoryType] = true
                end
            end
        end

        self.collectibleCategoryTypesInCategory = collectibleCategoryTypesInCategory
    end

    return self.collectibleCategoryTypesInCategory
end

------------------
-- Data Manager --
------------------

ZO_CollectibleDataManager = ZO_InitializingCallbackObject:Subclass()

function ZO_CollectibleDataManager:Initialize()
    self.collectibleIdToDataMap = {}
    self.collectibleCategoryIdToDataMap = {}
    self.collectibleCategoryTypeToSetDefaultCollectibleDataMap = {}

    ZO_COLLECTIBLE_DATA_MANAGER = self

    local function CreateCategoryData()
        return ZO_CollectibleCategoryData:New(self.collectibleObjectPool, self.subcategoryObjectPool)
    end

    local function CreateSubcategoryData()
        return ZO_CollectibleCategoryData:New(self.collectibleObjectPool)
    end

    local function CreateCollectibleData()
        return ZO_CollectibleData:New()
    end

    local function ResetData(data)
        data:Reset()
    end

    self.categoryObjectPool = ZO_ObjectPool:New(CreateCategoryData, ResetData)
    self.subcategoryObjectPool = ZO_ObjectPool:New(CreateSubcategoryData, ResetData)
    self.collectibleObjectPool = ZO_ObjectPool:New(CreateCollectibleData, ResetData)

    --[[
        EVENT_COLLECTIBLE_UPDATED fires when a nickname changes or a collectible is set as active/inactive. It does not encompass unlock state changes.
        EVENT_COLLECTION_UPDATED happens on init or when a command forces all collectibles to lock/unlock (re-init). Those cases don't use dirty unlock mappings from C, so we do that delta work here while we refresh everything.
        EVENT_ESO_PLUS_FREE_TRIAL_STATUS_CHANGED can happen at any time, and is an event that tells us to re-evaluate unlock status for everything because anything could be based on that. Like with EVENT_COLLECTION_UPDATED, we handle the delta here, not in C.
        EVENT_COLLECTIBLES_UNLOCK_STATE_CHANGED happens when the client maps out dirty unlock states (collectibles go on trial or ownership changes like crown store or rewards). We consume the dirty mapping from C and broadcast it out.
        EVENT_COLLECTIBLE_BLACKLIST_UPDATED happens when the client maps out dirty blacklist states. We consume the dirty mapping from C and broadcast it out.
        The later 4 all fire the same callback ("OnCollectionUpdated") to all systems registering with the callback manager with info to help determine what happened: collectionUpdateType (ZO_COLLECTION_UPDATE_TYPE), collectiblesByNewUnlockState
    --]]

    EVENT_MANAGER:RegisterForEvent("ZO_CollectibleDataManager", EVENT_COLLECTIBLE_UPDATED, function(_, ...) self:OnCollectibleUpdated(...) end)
    EVENT_MANAGER:RegisterForEvent("ZO_CollectibleDataManager", EVENT_COLLECTION_UPDATED, function(_, ...) self:OnCollectionUpdated(...) end)
    EVENT_MANAGER:RegisterForEvent("ZO_CollectibleDataManager", EVENT_ESO_PLUS_FREE_TRIAL_STATUS_CHANGED, function(_, ...) self:OnESOPlusFreeTrialStatusChanged(...) end)
    EVENT_MANAGER:RegisterForEvent("ZO_CollectibleDataManager", EVENT_COLLECTIBLES_UNLOCK_STATE_CHANGED, function(_, ...) self:OnCollectiblesUnlockStateChanged(...) end)
    EVENT_MANAGER:RegisterForEvent("ZO_CollectibleDataManager", EVENT_COLLECTIBLE_BLACKLIST_UPDATED, function(_, ...) self:OnCollectibleBlacklistUpdated(...) end)
    EVENT_MANAGER:RegisterForEvent("ZO_CollectibleDataManager", EVENT_COLLECTIBLE_NEW_STATUS_CLEARED, function(_, ...) self:OnCollectibleNewStatusCleared(...) end)
    EVENT_MANAGER:RegisterForEvent("ZO_CollectibleDataManager", EVENT_COLLECTIBLE_CATEGORY_NEW_STATUS_CLEARED, function(_, ...) self:OnCollectibleCategoryNewStatusCleared(...) end)
    EVENT_MANAGER:RegisterForEvent("ZO_CollectibleDataManager", EVENT_COLLECTIBLE_NOTIFICATION_NEW, function(_, ...) self:OnCollectibleNotificationNew(...) end)
    EVENT_MANAGER:RegisterForEvent("ZO_CollectibleDataManager", EVENT_COLLECTIBLE_NOTIFICATION_REMOVED, function(_, ...) self:OnCollectibleNotificationRemoved(...) end)
    EVENT_MANAGER:RegisterForEvent("ZO_CollectibleDataManager", EVENT_HOUSING_PRIMARY_RESIDENCE_SET, function(_, ...) self:OnPrimaryResidenceSet(...) end)

    self:RebuildCollection()
end

function ZO_CollectibleDataManager:OnCollectibleUpdated(collectibleId)
    local collectibleData = self:GetCollectibleDataById(collectibleId)
    if collectibleData then
        collectibleData:Refresh()
        self:FireCallbacks("OnCollectibleUpdated", collectibleId)
    else
        local errorString = string.format("EVENT_COLLECTIBLE_UPDATED fired with invalid collectible id (%d)", collectibleId)
        internalassert(false, errorString)
    end
end

-- Begin Collection Update Functions --

function ZO_CollectibleDataManager:MarkCollectionDirty()
    self.isCollectionDirty = true
end

function ZO_CollectibleDataManager:CleanCollection()
    if self.isCollectionDirty then
        self:RebuildCollection()
    end
end

function ZO_CollectibleDataManager:RebuildCollection()
    self.isCollectionDirty = false

    ZO_ClearTable(self.collectibleIdToDataMap)
    ZO_ClearTable(self.collectibleCategoryIdToDataMap)

    self.categoryObjectPool:ReleaseAllObjects()

    for categoryIndex = 1, GetNumCollectibleCategories() do
        local categoryData = self.categoryObjectPool:AcquireObject(categoryIndex)
        categoryData:BuildData(categoryIndex)
    end

    -- No state to track changes for
    local collectiblesByNewUnlockState = {}
    self:FinalizeCollectionUpdates(ZO_COLLECTION_UPDATE_TYPE.REBUILD, collectiblesByNewUnlockState)
end

do
    local function ProcessCollectibleDataForUnlockStateChange(collectibleData, collectiblesByUnlockState)
        local oldUnlockState = collectibleData:GetUnlockState()

        collectibleData:Refresh()
        collectibleData:SetNotificationId(nil)

        local newUnlockState = collectibleData:GetUnlockState()
        if oldUnlockState ~= newUnlockState then
            local unlockStateTable = collectiblesByUnlockState[newUnlockState]
            if not unlockStateTable then
                unlockStateTable = {}
                collectiblesByUnlockState[newUnlockState] = unlockStateTable
            end
            table.insert(unlockStateTable, collectibleData)
        end
    end

    function ZO_CollectibleDataManager:OnCollectionUpdated()
        local collectiblesByNewUnlockState = {}

        for _, collectibleData in self:CollectibleIterator() do
            ProcessCollectibleDataForUnlockStateChange(collectibleData, collectiblesByNewUnlockState)
        end

        self:FinalizeCollectionUpdates(ZO_COLLECTION_UPDATE_TYPE.FORCE_REINITIALIZE, collectiblesByNewUnlockState)
    end

    function ZO_CollectibleDataManager:OnESOPlusFreeTrialStatusChanged()
        local collectiblesByNewUnlockState = {}

        for _, collectibleData in self:CollectibleIterator() do
            ProcessCollectibleDataForUnlockStateChange(collectibleData, collectiblesByNewUnlockState)
        end

        self:FinalizeCollectionUpdates(ZO_COLLECTION_UPDATE_TYPE.UNLOCK_STATE_CHANGES, collectiblesByNewUnlockState)
    end

    local function GetNextDirtyUnlockStateCollectibleIdIter(_, lastCollectibleId)
        return GetNextDirtyUnlockStateCollectibleId(lastCollectibleId)
    end

    local function GetNextDirtyBlacklistCollectibleIdIter(_, lastCollectibleId)
        return GetNextDirtyBlacklistCollectibleId(lastCollectibleId)
    end

    function ZO_CollectibleDataManager:OnCollectiblesUnlockStateChanged()
        local collectiblesByNewUnlockState = {}
        for collectibleId in GetNextDirtyUnlockStateCollectibleIdIter do
            local collectibleData = self:GetCollectibleDataById(collectibleId)
            if collectibleData then
                ProcessCollectibleDataForUnlockStateChange(collectibleData, collectiblesByNewUnlockState)
            else
                local errorString = string.format("EVENT_COLLECTIBLES_UPDATED fired with invalid dirty collectible id (%d)", collectibleId)
                internalassert(false, errorString)
            end
        end

        self:FinalizeCollectionUpdates(ZO_COLLECTION_UPDATE_TYPE.UNLOCK_STATE_CHANGES, collectiblesByNewUnlockState)
    end

    function ZO_CollectibleDataManager:OnCollectibleBlacklistUpdated()
        for collectibleId in GetNextDirtyBlacklistCollectibleIdIter do
            local collectibleData = self:GetCollectibleDataById(collectibleId)
            if collectibleData then
                collectibleData:Refresh()
            end
        end

        local collectiblesByNewUnlockState = {}
        self:FinalizeCollectionUpdates(ZO_COLLECTION_UPDATE_TYPE.BLACKLIST_CHANGED, collectiblesByNewUnlockState)
    end
end

-- TODO: Refactor this so that collectiblesByNewUnlockState can hold collectibles for any collectionUpdateType to support different kinds of state changes
function ZO_CollectibleDataManager:FinalizeCollectionUpdates(collectionUpdateType, collectiblesByNewUnlockState)
    local hasUnlockStateChanges = NonContiguousCount(collectiblesByNewUnlockState) > 0
    if hasUnlockStateChanges then
        if collectiblesByNewUnlockState[COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED] then
            TriggerTutorial(TUTORIAL_TRIGGER_ACQUIRED_COLLECTIBLE)
        end
    end

    if hasUnlockStateChanges or collectionUpdateType ~= ZO_COLLECTION_UPDATE_TYPE.UNLOCK_STATE_CHANGES then
        self:MapNotifications()

        self:FireCallbacks("OnCollectionUpdated", collectionUpdateType, collectiblesByNewUnlockState)
    end
end

-- End Collection Update Functions --

function ZO_CollectibleDataManager:OnCollectibleNewStatusCleared(collectibleId)
    local collectibleData = self:GetCollectibleDataById(collectibleId)
    if collectibleData then
        collectibleData:SetNew(false)
        self:FireCallbacks("OnCollectibleNewStatusCleared", collectibleId)
    else
        local errorString = string.format("EVENT_COLLECTIBLE_NEW_STATUS_CLEARED fired with invalid collectible id (%d)", collectibleId)
        internalassert(false, errorString)
    end
end

function ZO_CollectibleDataManager:OnCollectibleCategoryNewStatusCleared(categoryId)
    local categoryData = self:GetCategoryDataById(categoryId)
    if categoryData then
        for _, collectibleData in categoryData:CollectibleIterator({ ZO_CollectibleData.IsNew }) do
            collectibleData:SetNew(false)
        end
        self:FireCallbacks("OnCollectibleCategoryNewStatusCleared", categoryId)
    end
end


function ZO_CollectibleDataManager:OnCollectibleNotificationNew(collectibleId, notificationId)
    local collectibleData = self:GetCollectibleDataById(collectibleId)
    if collectibleData then
        collectibleData:SetNotificationId(notificationId)
        self:FireCallbacks("OnCollectibleNotificationNew", notificationId, collectibleId)
    else
        local errorString = string.format("EVENT_COLLECTIBLE_NOTIFICATION_NEW fired with invalid collectible id (%d)", collectibleId)
        internalassert(false, errorString)
    end
end

function ZO_CollectibleDataManager:OnCollectibleNotificationRemoved(notificationId, collectibleId)
    local collectibleData = self:GetCollectibleDataById(collectibleId)
    if collectibleData then
        collectibleData:SetNotificationId(nil)
        self:FireCallbacks("OnCollectibleNotificationRemoved", notificationId, collectibleId)
    else
        local errorString = string.format("EVENT_COLLECTIBLE_NOTIFICATION_REMOVED fired with invalid collectible id (%d)", collectibleId)
        internalassert(false, errorString)
    end
end

function ZO_CollectibleDataManager:OnPrimaryResidenceSet(houseId)
    local oldPrimaryResidenceResults = self:GetAllCollectibleDataObjects({ ZO_CollectibleCategoryData.IsHousingCategory }, { ZO_CollectibleData.IsPrimaryResidence })
    for _, collectibleData in ipairs(oldPrimaryResidenceResults) do
        collectibleData:RefreshHousingData()
    end

    if houseId ~= 0 then
        local newPrimaryResidenceCollectibleId = GetCollectibleIdForHouse(houseId)
        local newPrimaryResidenceCollectibleData = self:GetCollectibleDataById(newPrimaryResidenceCollectibleId)
        newPrimaryResidenceCollectibleData:RefreshHousingData()
    end

    self:FireCallbacks("PrimaryResidenceSet", houseId)
end

function ZO_CollectibleDataManager:MapNotifications()
    for index = 1, GetNumCollectibleNotifications() do
        local notificationId, collectibleId = GetCollectibleNotificationInfo(index)
        local collectibleData = self:GetCollectibleDataById(collectibleId)
        if collectibleData then
            collectibleData:SetNotificationId(notificationId)
        else
            local errorString = string.format("GetNumCollectibleNotifications returned a bad collectible id (%d)", collectibleId)
            internalassert(false, errorString)
        end
    end
end

function ZO_CollectibleDataManager:GetCollectibleDataById(collectibleId)
    self:CleanCollection()
    return self.collectibleIdToDataMap[collectibleId]
end

function ZO_CollectibleDataManager:GetCollectibleDataByIndicies(categoryIndex, subcategoryIndex, collectibleIndex)
    local categoryData = self:GetCategoryDataByIndicies(categoryIndex, subcategoryIndex)
    if categoryData then
        return categoryData:GetCollectibleDataByIndex(collectibleIndex)
    end
    return nil
end

function ZO_CollectibleDataManager:CollectibleIterator(collectibleFilterFunctions)
    self:CleanCollection()
    return ZO_FilteredNonContiguousTableIterator(self.collectibleIdToDataMap, collectibleFilterFunctions)
end

function ZO_CollectibleDataManager:MapCollectibleData(collectibleData)
    self.collectibleIdToDataMap[collectibleData:GetId()] = collectibleData
end

function ZO_CollectibleDataManager:GetCategoryDataById(categoryId)
    self:CleanCollection()
    return self.collectibleCategoryIdToDataMap[categoryId]
end

function ZO_CollectibleDataManager:MapCategoryData(categoryData)
    self.collectibleCategoryIdToDataMap[categoryData:GetId()] = categoryData
end

function ZO_CollectibleDataManager:GetCategoryDataByIndicies(categoryIndex, subcategoryIndex)
    self:CleanCollection()
    local categoryData = self.categoryObjectPool:GetActiveObject(categoryIndex)
    if categoryData and subcategoryIndex then
        return categoryData:GetSubcategoryData(subcategoryIndex)
    end
    return categoryData
end

function ZO_CollectibleDataManager:GetNumCategories()
    self:CleanCollection()
    return self.categoryObjectPool:GetActiveObjectCount()
end

function ZO_CollectibleDataManager:CategoryIterator(categoryFilterFunctions)
    self:CleanCollection()
    -- This only works because we use the categoryObjectPool like a numerically indexed table
    return ZO_FilteredNumericallyIndexedTableIterator(self.categoryObjectPool:GetActiveObjects(), categoryFilterFunctions)
end

function ZO_CollectibleDataManager:GetAllCollectibleDataObjects(categoryFilterFunctions, collectibleFilterFunctions, sorted)
    local foundCollectibleDataObjects = {}
    for _, categoryData in self:CategoryIterator(categoryFilterFunctions) do
        categoryData:AppendAllCollectibleDataObjects(foundCollectibleDataObjects, collectibleFilterFunctions, sorted)
    end
    return foundCollectibleDataObjects
end

function ZO_CollectibleDataManager:HasAnyNewCollectibles()
    for _, categoryData in self:CategoryIterator() do
        if categoryData:HasAnyNewCollectibles() then
            return true
        end
    end
    return false
end

function ZO_CollectibleDataManager:HasAnyNewCompanionCollectibles()
    for _, categoryData in self:CategoryIterator() do
        if categoryData:HasAnyNewCompanionCollectibles() then
            return true
        end
    end
    return false
end

function ZO_CollectibleDataManager:HasAnyUnlockedCollectibles()
    for _, categoryData in self:CategoryIterator() do
        if categoryData:HasAnyUnlockedCollectibles() then
            return true
        end
    end
    return false
end

function ZO_CollectibleDataManager:GetSetDefaultCollectibleData(categoryTypeToSetDefault, actorCategory)
    local setDefaultCollectibleData = self.collectibleCategoryTypeToSetDefaultCollectibleDataMap[categoryTypeToSetDefault]
    if not setDefaultCollectibleData and DoesCollectibleCategoryTypeHaveDefault(categoryTypeToSetDefault, actorCategory) then
        setDefaultCollectibleData = ZO_SetDefaultCollectibleData:New(categoryTypeToSetDefault)
        self.collectibleCategoryTypeToSetDefaultCollectibleDataMap[categoryTypeToSetDefault] = setDefaultCollectibleData
    end
    return setDefaultCollectibleData
end

ZO_CollectibleDataManager:New()