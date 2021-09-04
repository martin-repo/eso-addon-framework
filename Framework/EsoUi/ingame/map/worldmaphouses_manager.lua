--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-- Singleton shared data
ZO_MapHousesData_Manager = ZO_Object:Subclass()

function ZO_MapHousesData_Manager:New(...)
    local singleton = ZO_Object.New(self)
    singleton:Initialize(...)
    return singleton
end

function ZO_MapHousesData_Manager:Initialize()
    self.houseMapData = {}
end

do
    local function HouseMapDataSort(lhs, rhs)
        if lhs.unlocked == rhs.unlocked then
            return lhs.houseName < rhs.houseName
        else
            return lhs.unlocked
        end
    end

    function ZO_MapHousesData_Manager:RefreshHouseList()
        local houseMapData = self.houseMapData
        ZO_ClearNumericallyIndexedTable(houseMapData)

        for nodeIndex = 1, GetNumFastTravelNodes() do
            local known, name, _, _, _, _, poiType = GetFastTravelNodeInfo(nodeIndex)

            if known and poiType == POI_TYPE_HOUSE then
                local houseId = GetFastTravelNodeHouseId(nodeIndex)
                if houseId ~= 0 then
                    local foundInZoneId = GetHouseFoundInZoneId(houseId)
                    local mapIndex = GetMapIndexByZoneId(foundInZoneId)
                    if mapIndex then
                        local houseCollectibleId = GetCollectibleIdForHouse(houseId)
                        local houseCollectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(houseCollectibleId)
                        local houseData =
                        {
                            houseId = houseId,
                            houseName = houseCollectibleData:GetFormattedName(),
                            foundInZoneName = houseCollectibleData:GetFormattedHouseLocation(),
                            unlocked = houseCollectibleData:IsUnlocked(),
                            mapIndex = mapIndex,
                            nodeIndex = nodeIndex,
                        }
                        table.insert(houseMapData, houseData)
                    end
                end
            end
        end

        table.sort(houseMapData, HouseMapDataSort)
    end
end

function ZO_MapHousesData_Manager:GetHouseList()
    return self.houseMapData
end

WORLD_MAP_HOUSES_DATA = ZO_MapHousesData_Manager:New()
