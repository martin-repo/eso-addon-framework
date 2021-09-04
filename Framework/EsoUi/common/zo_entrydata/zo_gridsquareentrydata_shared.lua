--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_GridSquareEntryData_Shared = ZO_DataSourceObject:Subclass()

function ZO_GridSquareEntryData_Shared:New(...)
    local entryData = ZO_DataSourceObject.New(self)
    entryData:Initialize(...)
    return entryData
end

function ZO_GridSquareEntryData_Shared:Initialize(dataSource)
    self:SetDataSource(dataSource)
end

-- If these are set for one data entry in a list for a given data type, they must be set for all entries in that list for that data type
-- Otherwise they will not be reset when the control gets recycled
function ZO_GridSquareEntryData_Shared:SetIconDesaturation(desaturation)
    self.iconDesaturation = desaturation
end

function ZO_GridSquareEntryData_Shared:SetIconSampleProcessingWeight(type, weight)
    if not self.textureSampleProcessingWeights then
        self.textureSampleProcessingWeights = {}
    end
    self.textureSampleProcessingWeights[type] = weight
end

function ZO_GridSquareEntryData_Shared:SetIconSampleProcessingWeightTable(typeToWeightTable)
    self.textureSampleProcessingWeights = typeToWeightTable
end

function ZO_GridSquareEntryData_Shared:SetIconColor(color)
    self.iconColor = color
end
