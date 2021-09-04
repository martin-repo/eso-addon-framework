--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

--[[
---- Lifecycle
--]]

ZO_Fence_Base = ZO_InitializingObject:Subclass()

function ZO_Fence_Base:Initialize(control)
    -- Initialize control
    self.control = control

    -- Register for callbacks
    FENCE_MANAGER:RegisterCallback("FenceOpened",  function(enableSell, enableLaunder) self:OnOpened(enableSell, enableLaunder) end)
    FENCE_MANAGER:RegisterCallback("FenceClosed",  function() self:OnClosed() end)
    FENCE_MANAGER:RegisterCallback("FenceSellSuccess",  function() self:OnSellSuccess() end)
    FENCE_MANAGER:RegisterCallback("FenceLaunderSuccess",  function() self:OnLaunderSuccess() end)
    FENCE_MANAGER:RegisterCallback("FenceInventoryUpdated", function() self:OnInventoryUpdate() end)
    FENCE_MANAGER:RegisterCallback("FenceUpdated", function(totalSells, sellsUsed, totalLaunders, laundersUsed) self:OnFenceStateUpdated(totalSells, sellsUsed, totalLaunders, laundersUsed) end)
    FENCE_MANAGER:RegisterCallback("FenceEnterSell",    function(totalSells, sellsUsed) self:OnEnterSell(totalSells, sellsUsed) end)
    FENCE_MANAGER:RegisterCallback("FenceEnterLaunder", function(totalLaunders, laundersUsed) self:OnEnterLaunder(totalLaunders, laundersUsed) end)
end

--[[
---- Callbacks
--]]

function ZO_Fence_Base:OnOpened(enableSell, enableLaunder)
    --Stub, to be overriden
end

function ZO_Fence_Base:OnClosed()
    --Stub, to be overriden
end

function ZO_Fence_Base:OnSellSuccess()
    --Stub, to be overriden
end

function ZO_Fence_Base:OnLaunderSuccess()
    --Stub, to be overriden
end

function ZO_Fence_Base:OnInventoryUpdate()
    --Stub, to be overriden
end

function ZO_Fence_Base:OnFenceStateUpdated(totalSells, sellsUsed, totalLaunders, laundersUsed)
    --Stub, to be overriden
end

function ZO_Fence_Base:OnEnterSell(totalSells, sellsUsed)
    --Stub, to be overriden
end

function ZO_Fence_Base:OnEnterLaunder(totalLaunders, laundersUsed)
    --Stub, to be overriden
end

--[[
---- Helper functions
--]]

function ZO_Fence_Base:IsLaundering()
    --Stub, to be overriden
end

function ZO_Fence_Base:IsSellingStolenItems()
    --Stub, to be overriden
end