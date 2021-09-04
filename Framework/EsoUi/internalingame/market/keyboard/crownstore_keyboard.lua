--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

--
--[[ ZO_CrownStore_Keyboard ]]--
--

ZO_CrownStore_Keyboard = ZO_Market_Keyboard:Subclass()

function ZO_CrownStore_Keyboard:New(...)
    return ZO_Market_Keyboard.New(self, ...)
end

function ZO_CrownStore_Keyboard:Initialize(control, sceneName)
    ZO_Market_Keyboard.Initialize(self, control, sceneName)

    self:SetDisplayGroup(MARKET_DISPLAY_GROUP_CROWN_STORE)
    self:SetFeaturedMarketProductFiltersMask(MARKET_PRODUCT_FILTER_TYPE_COST_CROWNS + MARKET_PRODUCT_FILTER_TYPE_COST_CROWN_GEMS)
    local filterTypes =
    {
        MARKET_PRODUCT_FILTER_TYPE_COST_CROWNS,
        MARKET_PRODUCT_FILTER_TYPE_COST_CROWN_GEMS,
    }
    self:SetMarketProductFilterTypes(filterTypes)
    local newFilterTypes =
    {
        MARKET_PRODUCT_FILTER_TYPE_NEW + MARKET_PRODUCT_FILTER_TYPE_COST_CROWNS,
        MARKET_PRODUCT_FILTER_TYPE_NEW + MARKET_PRODUCT_FILTER_TYPE_COST_CROWN_GEMS,
    }
    self:SetNewMarketProductFilterTypes(newFilterTypes)
    self:SetShownCurrencyTypeBalances(MKCT_CROWNS, MKCT_CROWN_GEMS)

    self:InitializeChapterUpgrade()
    ZO_CHAPTER_UPGRADE_MANAGER:RegisterCallback("ChapterUpgradeDataUpdated", function(...) self:OnChapterUpgradeDataUpdated(...) end)
end

-- Begin ZO_Market_Shared overrides

function ZO_CrownStore_Keyboard:OnInitialInteraction()
    ZO_Market_Shared.OnInitialInteraction(self)
    ZO_CHAPTER_UPGRADE_MANAGER:RequestPrepurchaseData()
end

function ZO_CrownStore_Keyboard:OnMarketOpen()
    -- Instead of opening the market as soon as the Crown Store data is ready
    -- we need to wait to make sure the chapter upgrade data is also ready
    -- (This avoids an issue were we would build the Crown Store and then
    -- immediately rebuild once the chapter data was ready)
    local chapterUpgradeState = ZO_CHAPTER_UPGRADE_MANAGER:GetMarketState()
    local chapterUpgradeDataReady = chapterUpgradeState == MARKET_STATE_OPEN or chapterUpgradeState == MARKET_STATE_LOCKED
    if self.marketState == MARKET_STATE_OPEN and chapterUpgradeDataReady then
        ZO_Market_Shared.OnMarketOpen(self)
    end
end

-- End ZO_Market_Shared overrides

function ZO_CrownStore_Keyboard:InitializeChapterUpgrade()
    local chapterUpgradePage = self.contentsControl:GetNamedChild("ChapterUpgrade")
    self.chapterUpgradePaneObject = ZO_ChapterUpgradePane_Keyboard:New(chapterUpgradePage:GetNamedChild("ScrollScrollChildPane"), self)
    self.chapterUpgradeButtonContainer = chapterUpgradePage:GetNamedChild("UpgradeButtons")
    self.chapterUpgradePurchasedButton = chapterUpgradePage:GetNamedChild("PurchasedButton")
    local standardButton = self.chapterUpgradeButtonContainer:GetNamedChild("Standard")
    local collectorsButton = self.chapterUpgradeButtonContainer:GetNamedChild("Collectors")

    local function OnUpgradeButtonClicked(isCollectorsEdition)
        local chapterUpgradeData = self.chapterUpgradePaneObject:GetChapterUpgradeData()
        if chapterUpgradeData then
            if chapterUpgradeData:IsPreRelease() then
                ZO_ShowChapterPrepurchasePlatformDialog(chapterUpgradeData:GetChapterUpgradeId(), isCollectorsEdition, CHAPTER_UPGRADE_SOURCE_IN_GAME)
            else
                ZO_ShowChapterUpgradePlatformDialog(isCollectorsEdition, CHAPTER_UPGRADE_SOURCE_IN_GAME)
            end
        end
    end

    standardButton:SetHandler("OnClicked", function()
        local IS_STANDARD_EDITION = false
        OnUpgradeButtonClicked(IS_STANDARD_EDITION)
    end)

    collectorsButton:SetHandler("OnClicked", function()
        local IS_COLLECTORS_EDITION = true
        OnUpgradeButtonClicked(IS_COLLECTORS_EDITION)
    end)

    self.chapterUpgradePage = chapterUpgradePage
end

function ZO_CrownStore_Keyboard:OnChapterUpgradeDataUpdated()
    if self:IsShowing() then
        self:OnMarketOpen()
    else
        self:FlagMarketCategoriesForRefresh()
    end
end

-- Begin ZO_Market_Keyboard overrides

function ZO_CrownStore_Keyboard:AddTopLevelCategories()
    local displayGroup = self:GetDisplayGroup()
    local isEmpty = true
    if not self:HasValidSearchString() then
        -- featured items category
        if self:DoesFeaturedMarketProductExist() then
            local normalIcon = "esoui/art/treeicons/achievements_indexicon_summary_up.dds"
            local pressedIcon = "esoui/art/treeicons/achievements_indexicon_summary_down.dds"
            local mouseoverIcon = "esoui/art/treeicons/achievements_indexicon_summary_over.dds"
            local NO_SUBCATEGORIES = 0
            self:AddCustomTopLevelCategory(ZO_MARKET_FEATURED_CATEGORY_INDEX, GetString(SI_MARKET_FEATURED_CATEGORY), NO_SUBCATEGORIES, normalIcon, pressedIcon, mouseoverIcon, ZO_MARKET_CATEGORY_TYPE_FEATURED, function()
                return self:HasNewFeaturedMarketProducts()
            end)

            isEmpty = false
        end

        -- chapter upgrade category + subcategories
        local numChapters = ZO_CHAPTER_UPGRADE_MANAGER:GetNumChapterUpgrades()
        if numChapters > 0 then
            local normalIcon = "esoui/art/treeicons/store_indexIcon_Chapters_up.dds"
            local pressedIcon = "esoui/art/treeicons/store_indexIcon_Chapters_down.dds"
            local mouseoverIcon = "esoui/art/treeicons/store_indexIcon_Chapters_over.dds"

            local areAnyNew = false
            local function AreAnyNew()
                return areAnyNew
            end

            local chaptersNode = self:AddCustomTopLevelCategory(ZO_MARKET_CHAPTER_UPGRADE_CATEGORY_INDEX, GetString(SI_MAIN_MENU_CHAPTERS), numChapters, normalIcon, pressedIcon, mouseoverIcon, ZO_MARKET_CATEGORY_TYPE_CHAPTER_UPGRADE, AreAnyNew)
            for index = 1, numChapters do
                local chapterUpgradeData = ZO_CHAPTER_UPGRADE_MANAGER:GetChapterUpgradeDataByIndex(index)
                local isNew = chapterUpgradeData:IsNew() and not chapterUpgradeData:IsOwned()
                areAnyNew = areAnyNew or isNew
                self:AddCustomSubcategory(chaptersNode, chapterUpgradeData:GetChapterUpgradeId(), chapterUpgradeData:GetName(), ZO_MARKET_CATEGORY_TYPE_CHAPTER_UPGRADE, isNew)
            end

            isEmpty = false
        end

        for i = 1, GetNumMarketProductCategories(displayGroup) do
            local name, numSubCategories, numMarketProducts, normalIcon, pressedIcon, mouseoverIcon = GetMarketProductCategoryInfo(displayGroup, i)
            if self:AddMarketProductTopLevelCategory(i, name, numSubCategories, normalIcon, pressedIcon, mouseoverIcon, ZO_MARKET_CATEGORY_TYPE_NONE, function()
                return self:DoesCategoryOrSubcategoriesContainFilteredProducts(displayGroup, i, ZO_NO_MARKET_SUBCATEGORY, self.newMarketProductFilterTypes)
            end) then
                isEmpty = false
            end
        end
    else
        for categoryIndex, data in pairs(self.searchResults) do
            local name, numSubCategories, numMarketProducts, normalIcon, pressedIcon, mouseoverIcon = GetMarketProductCategoryInfo(displayGroup, categoryIndex)
            self:AddMarketProductTopLevelCategory(categoryIndex, name, numSubCategories, normalIcon, pressedIcon, mouseoverIcon, ZO_MARKET_CATEGORY_TYPE_NONE, function()
                return self:DoesCategoryOrSubcategoriesContainFilteredProducts(displayGroup, categoryIndex, ZO_NO_MARKET_SUBCATEGORY, self.newMarketProductFilterTypes)
            end)
        end

        isEmpty = false
    end

    self:SetIsMarketEmpty(isEmpty)
end

function ZO_CrownStore_Keyboard:DisplayCategory(data)
    if data.type == ZO_MARKET_CATEGORY_TYPE_CHAPTER_UPGRADE then
        self:DisplayChapterUpgrade(data)
    else
        ZO_Market_Keyboard.DisplayCategory(self, data)
    end
end

function ZO_CrownStore_Keyboard:DisplayChapterUpgrade(data)
    self:ClearMarketProducts()

    self.chapterUpgradePage:SetHidden(false)
    self.categoryFilter:SetHidden(true)
    self.categoryFilterLabel:SetHidden(true)

    local chapterUpgradeData = ZO_CHAPTER_UPGRADE_MANAGER:GetChapterUpgradeDataById(data.categoryIndex)
    self.chapterUpgradePaneObject:SetChapterUpgradeData(chapterUpgradeData)

    local isOwned = chapterUpgradeData:IsOwned()
    self.chapterUpgradeButtonContainer:SetHidden(isOwned)
    self.chapterUpgradePurchasedButton:SetHidden(not isOwned)
end

function ZO_CrownStore_Keyboard:HideCustomTopLevelCategories()
    self.chapterUpgradePage:SetHidden(true)
end

function ZO_CrownStore_Keyboard:HasActiveCustomPreview()
    return not self.chapterUpgradePage:IsHidden()
end

function ZO_CrownStore_Keyboard:IsCustomPreviewReady()
    return self.chapterUpgradePaneObject:IsReadyToPreview()
end

function ZO_CrownStore_Keyboard:PerformCustomPreview()
    self.chapterUpgradePaneObject:PreviewSelection()
end

function ZO_CrownStore_Keyboard:CreateMarketScene()
    ZO_Market_Keyboard.CreateMarketScene(self)
    SYSTEMS:RegisterKeyboardRootScene(ZO_MARKET_NAME, self.marketScene)
end

-- End ZO_Market_Keyboard overrides

--
--[[ XML Handlers ]]--
--

function ZO_CrownStore_Keyboard_OnInitialize(control)
    MARKET = ZO_CrownStore_Keyboard:New(control, "market")
    SYSTEMS:RegisterKeyboardObject(ZO_MARKET_NAME, MARKET)
end