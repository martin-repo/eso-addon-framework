--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_EntryData = ZO_DataSourceObject:Subclass()

function ZO_EntryData:New(...)
    local entryData = ZO_DataSourceObject.New(self)
    entryData:Initialize(...)
    return entryData
end

function ZO_EntryData:Initialize(dataSource)
    self:SetDataSource(dataSource)
end