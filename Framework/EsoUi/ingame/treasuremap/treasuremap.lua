--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local gamepadKeybindStripDescriptor = nil
local TREASURE_MAP_INTERACTION =
{
    type = "treasure map interact",
    interactTypes = { INTERACTION_TREASURE_MAP },
}

local function OnGamepadSceneStateChange(oldState, newState)
    if newState == SCENE_SHOWING then
        if gamepadKeybindStripDescriptor == nil then
            gamepadKeybindStripDescriptor = {
                    alignment = KEYBIND_STRIP_ALIGN_LEFT,

                    KEYBIND_STRIP:GenerateGamepadBackButtonDescriptor(function()
                        INTERACT_WINDOW:EndInteraction(TREASURE_MAP_INTERACTION)
                        SCENE_MANAGER:HideCurrentScene()
                    end)
                }
        end

        KEYBIND_STRIP:AddKeybindButtonGroup(gamepadKeybindStripDescriptor)

    elseif newState == SCENE_HIDDEN then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(gamepadKeybindStripDescriptor)
    end
end

local TreasureMap = ZO_Object:Subclass()

function TreasureMap:New(...)
    local treasureMap = ZO_Object.New(self)
    treasureMap:Initialize(...)

    return treasureMap
end

function TreasureMap:Initialize(control)
    self.image = control:GetNamedChild("Image")

    control:RegisterForEvent(EVENT_SHOW_TREASURE_MAP, function(...) self:OnShowTreasureMap(...) end)

    TREASURE_MAP_INVENTORY_SCENE = ZO_Scene:New("treasureMapInventory", SCENE_MANAGER)
    TREASURE_MAP_INVENTORY_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_HIDDEN then
            INTERACT_WINDOW:EndInteraction(TREASURE_MAP_INTERACTION)
        end
    end)
    SYSTEMS:RegisterKeyboardRootScene("treasureMapInventory", TREASURE_MAP_INVENTORY_SCENE)

    TREASURE_MAP_QUICK_SLOT_SCENE = ZO_Scene:New("treasureMapQuickSlot", SCENE_MANAGER)
    TREASURE_MAP_QUICK_SLOT_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_HIDDEN then
            INTERACT_WINDOW:EndInteraction(TREASURE_MAP_INTERACTION)
        end
    end)
    SYSTEMS:RegisterKeyboardRootScene("treasureMapQuickSlot", TREASURE_MAP_QUICK_SLOT_SCENE)

    GAMEPAD_TREASURE_MAP_INVENTORY_SCENE = ZO_Scene:New("treasureMapInventoryGamepad", SCENE_MANAGER)
    GAMEPAD_TREASURE_MAP_INVENTORY_SCENE:RegisterCallback("StateChange", OnGamepadSceneStateChange)
    SYSTEMS:RegisterGamepadRootScene("treasureMapInventory", GAMEPAD_TREASURE_MAP_INVENTORY_SCENE)

    GAMEPAD_TREASURE_MAP_QUICK_SLOT_SCENE = ZO_Scene:New("treasureMapQuickSlotGamepad", SCENE_MANAGER)
    GAMEPAD_TREASURE_MAP_QUICK_SLOT_SCENE:RegisterCallback("StateChange", OnGamepadSceneStateChange)
    SYSTEMS:RegisterGamepadRootScene("treasureMapQuickSlot", GAMEPAD_TREASURE_MAP_QUICK_SLOT_SCENE)
end

function TreasureMap:OnShowTreasureMap(eventCode, treasureMapIndex)
    local name, imagePath = GetTreasureMapInfo(treasureMapIndex)
    self.image:SetTexture(imagePath)

    INTERACT_WINDOW:OnBeginInteraction(TREASURE_MAP_INTERACTION)

    if SCENE_MANAGER:IsShowingBaseScene() then
        SYSTEMS:ShowScene("treasureMapQuickSlot")
    else
        SYSTEMS:PushScene("treasureMapInventory")
    end
end

function ZO_TreasureMap_OnInitialize(control)
    TREASURE_MAP = TreasureMap:New(control)
end
