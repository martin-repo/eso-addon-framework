--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_ChapterUpgrade_Manager = ZO_CallbackObject:Subclass()

function ZO_ChapterUpgrade_Manager:New(...)
    local manager = ZO_CallbackObject.New(self)
    manager:Initialize(...)
    return manager
end

function ZO_ChapterUpgrade_Manager:Initialize()
    local defaults = { chapterUpgradeSeenVersion = 0, }
    local VERSION = 1
    ZO_RegisterForSavedVars("ChapterUpgrade", VERSION, defaults, function(...) self:OnSavedVarsReady(...) end)
end

function ZO_ChapterUpgrade_Manager:OnSavedVarsReady(savedVars)
    self.savedVars = savedVars
end

function ZO_ChapterUpgrade_Manager:ShouldShow()
    local currentChapterId = GetCurrentChapterUpgradeId()
    if currentChapterId == 0 or IsChapterOwned(currentChapterId) then
        return false
    end

    local currentVersion = GetCurrentChapterVersion()
    return currentVersion ~= self.savedVars.chapterUpgradeSeenVersion
end

function ZO_ChapterUpgrade_Manager:MarkCurrentVersionSeen()
    local currentVersion = GetCurrentChapterVersion()
    self.savedVars.chapterUpgradeSeenVersion = currentVersion
    ZO_SavePlayerConsoleProfile()
end

CHAPTER_UPGRADE_MANAGER = ZO_ChapterUpgrade_Manager:New()