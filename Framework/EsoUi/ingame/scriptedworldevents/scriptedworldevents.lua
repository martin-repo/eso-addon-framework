--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local function OnEventQuestAdded(eventCode, journalIndex, questName, objectiveName)
    RemoveScriptedEventInviteForQuest(questName)
end

function ZO_ScriptedWorldEvents_Initialize()

    -- Handling this event in order to clear a pending invite notification for a scripted event which was initiated by a fellow group member accepting the event quest first while
    -- this player was also in dialog with the quest provider, and to which this player later accepts the event quest personally via dialog.  If the player were to
    -- accept the event quest in the quest dialog, there is then no reason for them to still be prompted to accept/decline the same event.
    EVENT_MANAGER:RegisterForEvent("ZO_ScriptedWorldEvent", EVENT_QUEST_ADDED, OnEventQuestAdded)
end

ZO_ScriptedWorldEvents_Initialize()