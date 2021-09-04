--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local function SetupLogoutDialog(dialog)
    local isLocked = ZO_DAILYLOGINREWARDS_MANAGER:IsDailyRewardsLocked()
	local dailyRewardTile = dialog:GetNamedChild("DailyRewardTile")
	if dailyRewardTile then
        dailyRewardTile.object:SetHidden(isLocked)
        dailyRewardTile.object:SetActionAvailable(not isLocked)
		dailyRewardTile.object:RefreshLayout()
	end
	local dividerControl = dialog:GetNamedChild("TileDivider")
    dividerControl:SetHidden(isLocked)
end

function ZO_LogoutDialog_Keyboard_OnInitialized(self)
	ZO_Dialogs_RegisterCustomDialog("LOG_OUT",
        {
            customControl = self,
            setup = SetupLogoutDialog,
            canQueue = true,
            title =
            {
                text = SI_PROMPT_TITLE_LOG_OUT,
            },
            updateFn = function(dialog) -- if lock status changes, make sure to update the tile visibility
                local isLocked = ZO_DAILYLOGINREWARDS_MANAGER:IsDailyRewardsLocked()
                local dailyRewardTile = dialog:GetNamedChild("DailyRewardTile")
                if dailyRewardTile.object:IsActionAvailable() == isLocked then
                    SetupLogoutDialog(dialog)
                end
            end,
            buttons =
            {
                {
                    keybind = "DIALOG_PRIMARY",
                    control = self:GetNamedChild("Confirm"),
                    text = SI_LOG_OUT_GAME_CONFIRM_KEYBIND,
                    callback = function(dialog)
                        Logout()
                    end
                },
                {
                    control = self:GetNamedChild("Cancel"),
                    text = SI_DIALOG_CANCEL,
                },
            },
        })
end