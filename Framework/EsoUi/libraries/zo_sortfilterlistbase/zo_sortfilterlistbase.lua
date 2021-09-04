--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_SortFilterListBase = ZO_Object:Subclass()

function ZO_SortFilterListBase:New(...)
    local manager = ZO_Object.New(self)
    manager:Initialize(...)
    return manager
end

function ZO_SortFilterListBase:Initialize()
end

function ZO_SortFilterListBase:RefreshVisible()
end

function ZO_SortFilterListBase:RefreshSort()
end

function ZO_SortFilterListBase:RefreshFilters() 
end

function ZO_SortFilterListBase:RefreshData()
end

