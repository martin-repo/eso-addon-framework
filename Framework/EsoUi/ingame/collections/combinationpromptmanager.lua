--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

function ZO_CombinationPromptManager_ShowEvolutionPrompt(baseCollectibleId, unlockedCollectibleId, acceptCallback, declineCallback)
    local baseCollectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(baseCollectibleId)
    local baseCollectibleName = ZO_WHITE:Colorize(baseCollectibleData:GetName())

    local unlockedCollectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(unlockedCollectibleId)
    local unlockedCollectibleName = ZO_WHITE:Colorize(unlockedCollectibleData:GetName())

    local dialogData =
    {
        baseCollectibleId = baseCollectibleId,
        evolvedCollectibleId = unlockedCollectibleId,
        acceptCallback = acceptCallback,
        declineCallback = declineCallback,
    }

    local textParams =
    {
        mainTextParams =
        {
            baseCollectibleName,
            unlockedCollectibleName
        },
    }

    if IsInGamepadPreferredMode() then
        ZO_Dialogs_ShowGamepadDialog("CONFIRM_COLLECTIBLE_EVOLUTION_PROMPT_GAMEPAD", dialogData, textParams)
    else
        ZO_Dialogs_ShowDialog("CONFIRM_COLLECTIBLE_EVOLUTION_PROMPT_KEYBOARD", dialogData, textParams)
    end
end

function ZO_CombinationPromptManager_ClearEvolutionPrompt()
    ZO_Dialogs_ReleaseDialog("CONFIRM_COLLECTIBLE_EVOLUTION_PROMPT_KEYBOARD")
    ZO_Dialogs_ReleaseDialog("CONFIRM_COLLECTIBLE_EVOLUTION_PROMPT_GAMEPAD")
end
