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
local AddonMessageType = GamepadHelper_Types_MessageType
---@type ItemAssessment
local ItemAssessment = GamepadHelper_Types_ItemAssessment
---@type ItemAssessmentManager
local ItemAssessmentManager = GamepadHelper_Globals_ItemAssessmentManager
---@type ItemAssessmentFilter
local ItemAssessmentFilter = GamepadHelper_Types_ItemAssessmentFilter
local Lang = GamepadHelper_Lang
---@type UnitManager
local Unit = GamepadHelper_Globals_UnitManager
--#endregion

--#endregion

-- Constants

---@class ItemAssessmentSettings
---@field UseAccountWideSettings boolean
---@field IsEnabled boolean
---@field CompanionGearQuality number
---@field GearSetsForSale number[]
---@field KeepMagickaPotions boolean
---@field KeepStaminaPotions boolean
---@field DestroyTreasureMaps boolean

---@type ItemAssessmentSettings
local DefaultSettings = {
    UseAccountWideSettings = true,
    IsEnabled = true,
    CompanionGearQuality = 1,
    GearSetsForSale = { },
    KeepMagickaPotions = true,
    KeepStaminaPotions = true,
    DestroyTreasureMaps = false
}

local Name = "GamepadHelper_Globals_ItemAssessmentManager"

-- Fields

---@type ItemAssessmentSettings
local _accountSettings
local _backpack = {
    Choices = { },
    ChoicesValues = { },
    ChoicesTooltips = { },
    Selected = nil
}
local _backpackLinks
---@type ItemAssessmentSettings
local _characterSettings
local _gear = {
    Choices = { },
    ChoicesValues = { },
    ChoicesTooltips = { },
    Selected = nil
}
local _log
local _settings = DefaultSettings

-- Local functions

local function AssignSettings()
    if (_characterSettings.UseAccountWideSettings == true) then
        _settings = _accountSettings
    else
        _settings = _characterSettings
    end
end

local function GetCompanionChoices()
    local choices = { }
    for _, value in Map.ByValue(Type.ItemDisplayQuality) do
        if (value >= 1 and value <= 4) then
            local displayQualityString = GetString("SI_ITEMDISPLAYQUALITY", value)
            displayQualityString = GetItemQualityColor(value):Colorize(displayQualityString)
            Array.Add(choices, "<= " .. displayQualityString)
        end
    end

    return choices
end

local function GetCompanionChoicesValues()
    local choicesValues = { }
    for _, value in Map.ByValue(Type.ItemDisplayQuality) do
        if (value >= 1 and value <= 4) then
            Array.Add(choicesValues, value)
        end
    end

    return choicesValues
end

local function GetSetBonus(setId)
    local pieceId = GetItemSetCollectionPieceInfo(setId, 1)
    local itemLink = GetItemSetCollectionPieceItemLink(pieceId, Type.LinkStyle.Default, Type.ItemTraitType.None)
    local setInfo = Pack.GetItemLinkSetInfo(itemLink)

    local setBonus = ""
    for setBonusIndex = 1, setInfo.NumBonuses do
        local setBonusInfo = Pack.GetItemLinkSetBonusInfo(itemLink, false, setBonusIndex)
        if (string.len(setBonus) ~= 0) then
            setBonus = setBonus .. "\n"
        end

        setBonus = setBonus .. setBonusInfo.BonusDescription
    end

    return setBonus
end

local function IsGear(itemLink)
    local itemFilterType = GetItemLinkFilterTypeInfo(itemLink)
    if (itemFilterType == Type.ItemFilterType.Armor or
        itemFilterType == Type.ItemFilterType.Jewelry or
        itemFilterType == Type.ItemFilterType.Weapons) then
        return true
    end

    return false
end

local function UpdateBackpack()
    _backpack.Choices = { }
    _backpack.ChoicesValues = { }
    _backpack.ChoicesTooltips = { }
    _backpack.Selected = nil

    local backpackMap = { }
    for _, setLink in Array.Enumerate(_backpackLinks) do
        local setInfo = Pack.GetItemLinkSetInfo(setLink)
        if (Array.All(_settings.GearSetsForSale, function(value) return value ~= setInfo.SetId end)) then
            local setBonus = GetSetBonus(setInfo.SetId)
            backpackMap[setInfo.SetId] =  { Name = setInfo.SetName, Tooltip = setBonus }
        end
    end

    for setId, setInfo in Map.ByValue(backpackMap, function(a, b) return a.Name < b.Name end) do
        Array.Add(_backpack.Choices, setInfo.Name)
        Array.Add(_backpack.ChoicesValues, setId)
        Array.Add(_backpack.ChoicesTooltips, setInfo.Tooltip)
    end
end

local function UpdateGear()
    _gear.Choices = { }
    _gear.ChoicesValues = { }
    _gear.ChoicesTooltips = { }
    _gear.Selected = nil

    local gearMap = { }
    for _, setId in Array.Enumerate(_settings.GearSetsForSale) do
        local setName = GetItemSetName(setId)
        local setBonus = GetSetBonus(setId)
        gearMap[setId] = { Name = setName, Tooltip = setBonus }
    end

    for setId, setInfo in Map.ByValue(gearMap, function(a, b) return a.Name < b.Name end) do
        Array.Add(_gear.Choices, setInfo.Name)
        Array.Add(_gear.ChoicesValues, setId)
        Array.Add(_gear.ChoicesTooltips, setInfo.Tooltip)
    end
end

local function UpdateTreasureMapLabel()
    if (_settings.DestroyTreasureMaps == true) then
        DestroyTreasureMapsCheckbox.label:SetText(String.Format("{Destroy:Red} treasure maps"))
    else
        DestroyTreasureMapsCheckbox.label:SetText("Destroy treasure maps")
    end
end

local function UpdateSettingsUi()
    if (MainDescription == nil) then
        zo_callLater(function() UpdateSettingsUi() end, 500)
        return
    end

    GearDropdown:UpdateChoices(_gear.Choices, _gear.ChoicesValues, _gear.ChoicesTooltips)
    GearDropdown:UpdateValue()

    BackpackDropdown:UpdateChoices(_backpack.Choices, _backpack.ChoicesValues, _backpack.ChoicesTooltips)
    BackpackDropdown:UpdateValue()

    UpdateTreasureMapLabel()
end

local function ReloadSettings()
    UpdateGear()
    UpdateBackpack()
    UpdateSettingsUi()
end

local function AddGearForSale()
    Array.Add(_settings.GearSetsForSale, _backpack.Selected)
    ReloadSettings()
end

local function RemoveGearFromSale()
    Array.Remove(_settings.GearSetsForSale, _gear.Selected)
    ReloadSettings()
end

local function CreateSettingsControls()
    local descriptionBuilder = StringBuilder.CreateInstance()
    descriptionBuilder:AppendLine("Assesses if an item should be {kept} or disposed ({sold:Orange}, {researched:Orange}, {deconstructed:Orange} or {destroyed:Red}).")
    descriptionBuilder:AppendLine("    - " .. "Always keep {Nirnhoned:Blue} trait items")
    descriptionBuilder:AppendLine("    - " .. "Dispose")
    descriptionBuilder:AppendLine("        - " .. "{non-set} gear (armor, jewelry, weapons)")
    descriptionBuilder:AppendLine("        - " .. "set gear matching rules below")
    descriptionBuilder:AppendLine("        - " .. "normal quality {potions}")
    descriptionBuilder:AppendLine("        - " .. "normal quality {food} and {drinks}")
    descriptionBuilder:AppendLine("        - " .. "normal quality {poisons}")
    descriptionBuilder:AppendLine("        - " .. "normal quality {glyphs}")
    descriptionBuilder:AppendLine("        - " .. "{known recipies}")
    descriptionBuilder:AppendLine("        - " .. "{treasure}")
    descriptionBuilder:AppendLine("        - " .. "{trash}")
    descriptionBuilder:AppendLine("        - " .. "{companion} gear matching rules below")
    descriptionBuilder:Append("        - " .. "{siege} items")
    local description = String.Format(descriptionBuilder:ToString())

    local settingsControls = {
        {
            type = "description",
            text = description,
            reference = "MainDescription"
        },
        {
            type = "checkbox",
            name = "Use account wide settings",
            getFunc = function() return _characterSettings.UseAccountWideSettings end,
            setFunc = function(value)
                _characterSettings.UseAccountWideSettings = value
                AssignSettings()
                ReloadSettings()
            end
        },
        {
            type = "checkbox",
            name = "Enabled",
            getFunc = function() return _settings.IsEnabled end,
            setFunc = function(value) _settings.IsEnabled = value end
        },
        {
            type = "header",
            name = "Gear sets",
        },
        {
            type = "dropdown",
            name = "Sell companion gear if quality",
            choices = GetCompanionChoices(),
            choicesValues = GetCompanionChoicesValues(),
            getFunc = function() return _settings.CompanionGearQuality end,
            setFunc = function(value) _settings.CompanionGearQuality = value end,
            disabled = function() return not _settings.IsEnabled end
        },
        {
            type = "dropdown",
            name = "Sell/research/deconstruct gear sets",
            scrollable = true,
            choices = _gear.Choices,
            choicesValues = _gear.ChoicesValues,
            choicesTooltips = _gear.ChoicesTooltips,
            getFunc = function() return _gear.Selected end,
            setFunc = function(value) _gear.Selected = value end,
            disabled = function() return not _settings.IsEnabled or not Array.Any(_gear.Choices) end,
            reference = "GearDropdown"
        },
        {
            type = "button",
            name = "Remove gear set",
            func = function() RemoveGearFromSale() end,
            disabled = function() return not _settings.IsEnabled or _gear.Selected == nil end
        },
        {
            type = "dropdown",
            name = "Backpack gear sets",
            scrollable = true,
            choices = _backpack.Choices,
            choicesValues = _backpack.ChoicesValues,
            choicesTooltips = _backpack.ChoicesTooltips,
            getFunc = function() return _backpack.Selected end,
            setFunc = function(value) _backpack.Selected = value end,
            disabled = function() return not _settings.IsEnabled or not Array.Any(_backpack.Choices) end,
            reference = "BackpackDropdown"
        },
        {
            type = "button",
            name = "Add gear set",
            func = function() AddGearForSale() end,
            disabled = function() return not _settings.IsEnabled or _backpack.Selected == nil end
        },
        {
            type = "header",
            name = "Items",
        },
        {
            type = "checkbox",
            name = "Keep normal quality magicka potions",
            getFunc = function() return _settings.KeepMagickaPotions end,
            setFunc = function(value) _settings.KeepMagickaPotions = value end
        },
        {
            type = "checkbox",
            name = "Keep normal quality stamina potions",
            getFunc = function() return _settings.KeepStaminaPotions end,
            setFunc = function(value) _settings.KeepStaminaPotions = value end
        },
        {
            type = "checkbox",
            name = "Destroy treasure maps",
            warning = "Enabling this feature will automatically and irrevocably destroy items!",
            getFunc = function() return _settings.DestroyTreasureMaps end,
            setFunc = function(value)
                _settings.DestroyTreasureMaps = value
                UpdateTreasureMapLabel()
            end,
            reference = "DestroyTreasureMapsCheckbox"
        }
    }

    return {
        DisplayName = "Item assessment",
        Controls = settingsControls
    }
end

local function ReloadBackpackLinks()
    local bagId = Type.Bag.Backpack
    local totalSlotCount = GetBagSize(bagId)

    local setLinks = { }

    for slotIndex = 0, totalSlotCount do
        local itemLink = GetItemLink(bagId, slotIndex, Type.LinkStyle.Default)
        if (itemLink ~= "" and
            IsGear(itemLink) and
            IsItemLinkSetCollectionPiece(itemLink)) then
            local setInfo = Pack.GetItemLinkSetInfo(itemLink, false)
            setLinks[setInfo.SetName] = itemLink
        end
    end

    _backpackLinks = Map.Values(setLinks)
end

local function OnSettingsShown()
    ReloadBackpackLinks()
    ReloadSettings()
end

local function AssessGear(itemLink)
    local itemTrait = GetItemLinkTraitType(itemLink)
    if (itemTrait == Type.ItemTraitType.ArmorNirnhoned or
        itemTrait == Type.ItemTraitType.WeaponNirnhoned) then
        return ItemAssessment.Keep
    end

    if (GetItemLinkActorCategory(itemLink) == Type.GameplayActorCategory.Companion) then
        local quality = GetItemLinkDisplayQuality(itemLink)
        if (quality <= _settings.CompanionGearQuality) then
            return ItemAssessment.Dispose
        end
    elseif (not IsItemLinkSetCollectionPiece(itemLink) and
            not IsItemLinkCrafted(itemLink)) then
        return ItemAssessment.Dispose
    else
        local setInfo = Pack.GetItemLinkSetInfo(itemLink, false)
        if (Array.Any(_settings.GearSetsForSale, function(value) return value == setInfo.SetId end)) then
            return ItemAssessment.Dispose
        end
    end

    return ItemAssessment.Keep
end

local function AssessItem(itemLink)
    local itemType, specializedItemType = GetItemLinkItemType(itemLink)

    if (itemType == Type.ItemType.Trash or
        itemType == Type.ItemType.Treasure) then
        return ItemAssessment.Dispose
    end

    if (itemType == Type.ItemType.AvaRepair or
        itemType == Type.ItemType.Siege) then
        return ItemAssessment.Dispose
    end

    if (itemType == Type.ItemType.Trophy) then
        if (specializedItemType == Type.SpecializedItemType.TrophyTreasureMap and
            _settings.DestroyTreasureMaps == true) then
            return ItemAssessment.Dispose
        end

        return ItemAssessment.Keep
    end

    if (itemType == Type.ItemType.Recipe) then
        if (IsItemLinkRecipeKnown(itemLink)) then
            return ItemAssessment.Dispose
        end

        return ItemAssessment.Keep
    end

    local itemQuality = GetItemLinkDisplayQuality(itemLink)

    if (itemType == Type.ItemType.Potion and itemQuality <= Type.ItemDisplayQuality.Normal) then
        local itemName = GetItemLinkName(itemLink):lower()
        if ((not _settings.KeepMagickaPotions or string.find(itemName, "magicka", 1, true) == nil) and
            (not _settings.KeepStaminaPotions or string.find(itemName, "stamina", 1, true) == nil)) then
            return ItemAssessment.Dispose
        end

        return ItemAssessment.Keep
    end

    if ((itemType == Type.ItemType.Food and itemQuality <= Type.ItemDisplayQuality.Normal) or
        (itemType == Type.ItemType.Drink and itemQuality <= Type.ItemDisplayQuality.Normal) or
        (itemType == Type.ItemType.Poison and itemQuality <= Type.ItemDisplayQuality.Normal) or
        (itemType == Type.ItemType.GlyphArmor and itemQuality <= Type.ItemDisplayQuality.Normal) or
        (itemType == Type.ItemType.GlyphJewelry and itemQuality <= Type.ItemDisplayQuality.Normal) or
        (itemType == Type.ItemType.GlyphWeapon and itemQuality <= Type.ItemDisplayQuality.Normal)) then
        return ItemAssessment.Dispose
    end

    return ItemAssessment.Keep
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _log = Log.CreateInstance(Name)

    _accountSettings = Storage.GetEntry(Name, DefaultSettings, StorageScope.Account)
    _characterSettings = Storage.GetEntry(Name, DefaultSettings, StorageScope.Character)
    AssignSettings()

    Messenger.Subscribe(FrameworkMessageType.SettingsControlsRequest, CreateSettingsControls)
    Messenger.Subscribe(FrameworkMessageType.SettingsShown, OnSettingsShown)
end

---@class ItemAssessmentManager
GamepadHelper_Globals_ItemAssessmentManager = { }
EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)

-- Class functions

---Assesses whether an item fulfils dispose criteria or not.
---@param itemLink string # Link to item that should be assessed
---@param filter? ItemAssessmentFilter
---@return ItemAssessment
function GamepadHelper_Globals_ItemAssessmentManager.AssessItem(itemLink, filter)
    if (IsGear(itemLink)) then
        return AssessGear(itemLink)
    end

    if (filter == nil or filter ~= ItemAssessmentFilter.GearOnly) then
        return AssessItem(itemLink)
    end

    return ItemAssessment.Keep
end