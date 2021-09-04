--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local ZO_LootInventory_Gamepad = ZO_Object.MultiSubclass(ZO_Loot_Gamepad_Base, ZO_Gamepad_ParametricList_Screen)

function ZO_LootInventory_Gamepad:New(...)
    local screen = ZO_Object.New(self)
    screen:Initialize(...)
    return screen
end

function ZO_LootInventory_Gamepad:Initialize(control)
    local DONT_CREATE_TABBAR = false
    ZO_Loot_Gamepad_Base.Initialize(self, GAMEPAD_LEFT_TOOLTIP)
    ZO_Gamepad_ParametricList_Screen.Initialize(self, control, DONT_CREATE_TABBAR)

    self.initialLootUpdate = true
    self.keybindDirty = false
    self.isInitialized = false
    self.isResizable = false

    self.headerData = {
        titleText = ""
    }

    local function OnStateChanged(...)
        self:OnStateChanged(...)
    end

    LOOT_INVENTORY_SCENE_GAMEPAD = ZO_Scene:New("lootInventoryGamepad", SCENE_MANAGER)
    LOOT_INVENTORY_SCENE_GAMEPAD:RegisterCallback("StateChange", OnStateChanged)
end

function ZO_LootInventory_Gamepad:SetupList(list)
    list:AddDataTemplate("ZO_GamepadItemSubEntryTemplate", ZO_SharedGamepadEntry_OnSetup)
    self.itemList = list
end

function ZO_LootInventory_Gamepad:DeferredInitialize()
    self:SetTitle(self.headerData.titleText)
    self.isInitialized = true
end

function ZO_LootInventory_Gamepad:OnHide()
    KEYBIND_STRIP:RestoreDefaultExit()
end

function ZO_LootInventory_Gamepad:OnShow()
    local OPEN_LOOT_WINDOW = false
    ZO_PlayMonsterLootSound(OPEN_LOOT_WINDOW)
end

function ZO_LootInventory_Gamepad:Hide()
    SCENE_MANAGER:Hide("lootInventoryGamepad")
end

function ZO_LootInventory_Gamepad:Show()
    KEYBIND_STRIP:RemoveDefaultExit()
    SCENE_MANAGER:Push("lootInventoryGamepad")
end

function ZO_LootInventory_Gamepad:InitializeKeybindStripDescriptors()
    local NOT_ETHEREAL = false
    self:InitializeKeybindStripDescriptorsMixin(NOT_ETHEREAL)
end

function ZO_LootInventory_Gamepad:SetTitle(title)
    self.headerData.titleText = title
    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)
end

local TAKE_BUTTON_INDEX = 2
local TAKE_ALL_BUTTON_INDEX = 3
function ZO_LootInventory_Gamepad:UpdateKeybindDescriptor()
    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
    self.keybindDirty = false
end

function ZO_LootInventory_Gamepad:PerformUpdate()
    self:UpdateList()

    if self.keybindDirty then
        self:UpdateKeybindDescriptor()
    end
end

--[[ Global Handlers ]]--
function ZO_Gamepad_LootInventory_OnInitialize(control)
    LOOT_INVENTORY_WINDOW_GAMEPAD = ZO_LootInventory_Gamepad:New(control)
end