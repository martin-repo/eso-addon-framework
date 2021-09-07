--#region Usings

--#region Framework usings
---@type Array
local Array = EsoAddonFramework_Framework_Array
---@type Color
local Color = EsoAddonFramework_Framework_Color
---@type Console
local Console = EsoAddonFramework_Framework_Console
---@type Event
local Event = EsoAddonFramework_Framework_Eso_Event
---@type EventManager
local EventManager = EsoAddonFramework_Framework_Eso_EventManager
---@type FrameworkMessageType
local FrameworkMessageType = EsoAddonFramework_Framework_MessageType
---@type Log
local Log = EsoAddonFramework_Framework_Log
---@type LogLevel
local LogLevel = EsoAddonFramework_Framework_LogLevel
---@type Map
local Map = EsoAddonFramework_Framework_Map
---@type Messenger
local Messenger = EsoAddonFramework_Framework_Messenger
---@type Pack
local Pack = EsoAddonFramework_Framework_Eso_Pack
---@type Storage
local Storage = EsoAddonFramework_Framework_Storage
---@type StorageScope
local StorageScope = EsoAddonFramework_Framework_StorageScope
---@type String
local String = EsoAddonFramework_Framework_String
---@type StringBuilder
local StringBuilder = EsoAddonFramework_Framework_StringBuilder
---@type Type
local Type = EsoAddonFramework_Framework_Eso_Type
---@type UnitTag
local UnitTag = EsoAddonFramework_Framework_Eso_UnitTag
--#endregion

--#region Addon usings
---@type AddonMessageType
local AddonMessageType = GameplayHelper_Types_MessageType
---@type ItemAssessment
local ItemAssessment = GameplayHelper_Types_ItemAssessment
---@type ItemAssessmentManager
local ItemAssessmentManager = GameplayHelper_Globals_ItemAssessmentManager
---@type ItemAssessmentFilter
local ItemAssessmentFilter = GameplayHelper_Types_ItemAssessmentFilter
local Lang = GameplayHelper_Lang
---@type UnitManager
local Unit = GameplayHelper_Globals_UnitManager
--#endregion

--#endregion

-- Constants

-- Fields

-- Local functions

-- Constructor

---@class UnitManager
GameplayHelper_Globals_UnitManager = { }

-- Class functions

---@class UnitNameInfo
---@field Name string
---@field HisHerIts string
---@field HisHersIts string
---@field HeSheIt string
---@field HimHerIt string
---@field HimselfHerselfItself string


---@param unitTag? UnitTag # Leave nil for current player
---@return string
function GameplayHelper_Globals_UnitManager.GetAccountName(unitTag)
    if (unitTag == nil) then
        return GetDisplayName()
    end

    return GetUnitDisplayName(unitTag)
end

---@param unitTag? UnitTag # Leave nil for current player
---@return string
function GameplayHelper_Globals_UnitManager.GetCharacterName(unitTag)
    if (unitTag == nil) then
        return GetUnitName(UnitTag.Player)
    end

    return GetUnitName(unitTag)
end

---@param unitTag UnitTag
---@return UnitNameInfo
function GameplayHelper_Globals_UnitManager.GetNameInfo(unitTag)
    local rawUnitName = GetRawUnitName(unitTag)
    local unitName = GetUnitName(unitTag)
    local pronounString = zo_strformat("<<o:1>> <<O:1>> <<p:1>> <<P:1>> <<r:1>>", rawUnitName)
    local pronouns = String.Split(pronounString, " ")
    local nameInfo = {
        Name = unitName,
        HisHerIts = pronouns[1],
        HisHersIts = pronouns[2],
        HeSheIt = pronouns[3],
        HimHerIt = pronouns[4],
        HimselfHerselfItself = pronouns[5]
    }

    return nameInfo
end