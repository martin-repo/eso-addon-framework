--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

------------------
--Initialization--
------------------

local DLCBook_Keyboard = ZO_SpecializedCollectionsBook_Keyboard:Subclass()

function DLCBook_Keyboard:New(...)
    return ZO_SpecializedCollectionsBook_Keyboard.New(self, ...)
end

function DLCBook_Keyboard:InitializeControls()
    ZO_SpecializedCollectionsBook_Keyboard.InitializeControls(self)
    local contents = self.control:GetNamedChild("Contents")
    local scrollSection = contents:GetNamedChild("ScrollContainer"):GetNamedChild("ScrollChild")
    self.unlockStatusControl = scrollSection:GetNamedChild("UnlockStatusLabel")
    self.questStatusControl = scrollSection:GetNamedChild("QuestStatusLabel")
    self.questAvailableControl = scrollSection:GetNamedChild("QuestAvailable")
    self.questDescriptionControl = scrollSection:GetNamedChild("QuestDescription")

    local buttons = contents:GetNamedChild("DLCInteractButtons")
    self.questAcceptButton = buttons:GetNamedChild("QuestAccept")
    self.unlockPermanentlyButton = buttons:GetNamedChild("UnlockPermanently")
    self.chapterUpgrade = buttons:GetNamedChild("ChapterUpgrade")

    self.subscribeButton = contents:GetNamedChild("SubscribeButton")
end

function DLCBook_Keyboard:GetCategoryFilterFunctions()
    return { ZO_CollectibleCategoryData.IsDLCCategory }
end

function DLCBook_Keyboard:IsCollectibleRelevant(collectibleData)
    return collectibleData:IsStory()
end

---------------
--Interaction--
---------------

function DLCBook_Keyboard:RefreshDetails()
    ZO_SpecializedCollectionsBook_Keyboard.RefreshDetails(self)

    local collectibleData = self.navigationTree:GetSelectedData()

    if collectibleData then
        self.unlockStatusControl:SetText(GetString("SI_COLLECTIBLEUNLOCKSTATE", collectibleData:GetUnlockState()))
        local questState = collectibleData:GetCollectibleAssociatedQuestState()

        local isLocked = collectibleData:IsLocked()
        local isActive = questState == COLLECTIBLE_ASSOCIATED_QUEST_STATE_ACCEPTED or questState == COLLECTIBLE_ASSOCIATED_QUEST_STATE_COMPLETED
        local isNotOwned = not collectibleData:IsOwned()

        local questAcceptLabelStringId = isActive and SI_DLC_BOOK_QUEST_STATUS_ACCEPTED or SI_DLC_BOOK_QUEST_STATUS_NOT_ACCEPTED
        local questName = collectibleData:GetQuestName()
        self.questStatusControl:SetText(zo_strformat(SI_DLC_BOOK_QUEST_STATUS, questName, GetString(questAcceptLabelStringId)))

        local showsQuest = not (isActive or isLocked)
        local questAvailableControl = self.questAvailableControl
        local questDescriptionControl = self.questDescriptionControl
        local canUnlockOnStore = isNotOwned and collectibleData:IsPurchasable()
        local canUnlockWithSubscription = not IsESOPlusSubscriber() and collectibleData:IsUnlockedViaSubscription()
        local isChapter = collectibleData:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_CHAPTER)
        if showsQuest then
            questAvailableControl:SetText(GetString(SI_COLLECTIONS_QUEST_AVAILABLE))
            questAvailableControl:SetHidden(false)
            
            questDescriptionControl:SetText(collectibleData:GetQuestDescription())
            questDescriptionControl:SetHidden(false)
        elseif isLocked then
            if canUnlockOnStore or canUnlockWithSubscription or isChapter then
                local acquireText = isChapter and GetString(SI_COLLECTIONS_QUEST_AVAILABLE_WITH_UPGRADE) or GetString(SI_COLLECTIONS_QUEST_AVAILABLE_WITH_UNLOCK)
                questAvailableControl:SetText(acquireText)
                questAvailableControl:SetHidden(false)
            else
                questAvailableControl:SetHidden(true)
            end
            questDescriptionControl:SetHidden(true)
        else
            questAvailableControl:SetHidden(true)
            questDescriptionControl:SetHidden(true)
        end

        local questAcceptButtonStringId = isActive and SI_DLC_BOOK_ACTION_QUEST_ACCEPTED or SI_COLLECTIBLE_ACTION_ACCEPT_QUEST
        self.questAcceptButton:SetText(GetString(questAcceptButtonStringId))
        self.questAcceptButton:SetEnabled(not (isLocked or isActive))
        self.unlockPermanentlyButton:SetHidden(not canUnlockOnStore)
        self.subscribeButton:SetHidden(not canUnlockWithSubscription)
        self.chapterUpgrade:SetHidden(not (isChapter and isNotOwned))
    end
end

function DLCBook_Keyboard:UseSelectedDLC()
    local collectibleData = self.navigationTree:GetSelectedData()
    collectibleData:Use(GAMEPLAY_ACTOR_CATEGORY_PLAYER)
end

function DLCBook_Keyboard:SearchSelectedDLCInStore()
    local collectibleData = self.navigationTree:GetSelectedData()
    local searchTerm = zo_strformat(SI_CROWN_STORE_SEARCH_FORMAT_STRING, collectibleData:GetName())
    ShowMarketAndSearch(searchTerm, MARKET_OPEN_OPERATION_COLLECTIONS_DLC)
end

function DLCBook_Keyboard:OnSceneShown()
    ZO_SpecializedCollectionsBook_Keyboard.OnSceneShown(self)
    if IsESOPlusSubscriber() then
        TriggerTutorial(TUTORIAL_TRIGGER_COLLECTIONS_DLC_OPENED_AS_SUBSCRIBER)
    end
end

----------
--Events--
----------

function ZO_DLCBook_Keyboard_OnQuestAcceptClicked(control)
    DLC_BOOK_KEYBOARD:UseSelectedDLC()
end

function ZO_DLCBook_Keyboard_OnUnlockPermanentlyClicked(control)
    DLC_BOOK_KEYBOARD:SearchSelectedDLCInStore()
end

function ZO_DLCBook_Keyboard_OnSubscribeClicked(control)
    ZO_ShowBuySubscriptionPlatformDialog()
end

function ZO_DLCBook_Keyboard_OnChapterUpgradeClicked(control)
    ZO_ShowChapterUpgradePlatformScreen(MARKET_OPEN_OPERATION_COLLECTIONS_DLC)
end

function ZO_DLCBook_Keyboard_OnInitialize(control)
    DLC_BOOK_KEYBOARD = DLCBook_Keyboard:New(control, "dlcBook", ZO_SpecializedCollectionsBook_Keyboard_CategoryLayout_Subcategories)
end