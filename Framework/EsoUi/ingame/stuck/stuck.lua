--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local Stuck = ZO_Stuck_Base:Subclass()

function Stuck:New(...)
    return ZO_Stuck_Base.New(self, ...)
end

function Stuck:Initialize(...)
    ZO_Stuck_Base.Initialize(self, ...)
end

function Stuck:ShowFixingDialog()
    ZO_Dialogs_ShowDialog("FIXING_STUCK")
end

function Stuck:HideFixingDialog()
    ZO_Dialogs_ReleaseDialog("FIXING_STUCK")
end

--Events

function Stuck:OnPlayerActivated()
    if(IsStuckFixPending()) then
        self:ShowFixingDialog()
    end
end

function Stuck:OnStuckBegin()
    self:ShowFixingDialog()
end

function Stuck:OnStuckCanceled()
    self:HideFixingDialog()
end

function Stuck:OnStuckComplete()
    self:HideFixingDialog()
end

-- handling these to technically handle every stuck event if functionality is desired later, but PC informs the user via the chat window / C++ code
function Stuck:OnStuckErrorAlreadyInProgress()
end

function Stuck:OnStuckErrorInvalidLocation()
end

function Stuck:OnStuckErrorInCombat()
end

function Stuck:OnStuckErrorOnCooldown()
end

STUCK = Stuck:New()
SYSTEMS:RegisterKeyboardObject(ZO_STUCK_NAME, STUCK)