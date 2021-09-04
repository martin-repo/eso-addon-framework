--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-------------------
--Crown Store Scene
-------------------

local marketScene = SCENE_MANAGER:GetScene("market")
-- the preview options fragment needs to be added before the ITEM_PREVIEW_KEYBOARD fragment
-- which is part of ZO_ITEM_PREVIEW_LIST_HELPER_KEYBOARD_FRAGMENT_GROUP
marketScene:AddFragment(MARKET_ITEM_PREVIEW_OPTIONS_FRAGMENT)
marketScene:AddFragmentGroup(ZO_ITEM_PREVIEW_LIST_HELPER_KEYBOARD_FRAGMENT_GROUP)

marketScene:AddFragment(TREE_UNDERLAY_FRAGMENT)
marketScene:AddFragment(KEYBIND_STRIP_FADE_FRAGMENT)
marketScene:AddFragment(UI_SHORTCUTS_ACTION_LAYER_FRAGMENT)
marketScene:AddFragment(GENERAL_ACTION_LAYER_FRAGMENT)

----------------------------
--Endeavor Seals Store Scene
----------------------------

local endeavorSealStoreScene = SCENE_MANAGER:GetScene("endeavorSealStoreSceneKeyboard")
-- the preview options fragment needs to be added before the ITEM_PREVIEW_KEYBOARD fragment
-- which is part of ZO_ITEM_PREVIEW_LIST_HELPER_KEYBOARD_FRAGMENT_GROUP
endeavorSealStoreScene:AddFragment(MARKET_ITEM_PREVIEW_OPTIONS_FRAGMENT)
endeavorSealStoreScene:AddFragmentGroup(ZO_ITEM_PREVIEW_LIST_HELPER_KEYBOARD_FRAGMENT_GROUP)

endeavorSealStoreScene:AddFragment(TREE_UNDERLAY_FRAGMENT)
endeavorSealStoreScene:AddFragment(KEYBIND_STRIP_FADE_FRAGMENT)
endeavorSealStoreScene:AddFragment(UI_SHORTCUTS_ACTION_LAYER_FRAGMENT)
endeavorSealStoreScene:AddFragment(GENERAL_ACTION_LAYER_FRAGMENT)

-------------------
--Eso Plus Offers Scene
-------------------

local esoPlusOffersScene = SCENE_MANAGER:GetScene("esoPlusOffersSceneKeyboard")
-- the preview options fragment needs to be added before the ITEM_PREVIEW_KEYBOARD fragment
-- which is part of ZO_ITEM_PREVIEW_LIST_HELPER_KEYBOARD_FRAGMENT_GROUP
esoPlusOffersScene:AddFragment(MARKET_ITEM_PREVIEW_OPTIONS_FRAGMENT)
esoPlusOffersScene:AddFragmentGroup(ZO_ITEM_PREVIEW_LIST_HELPER_KEYBOARD_FRAGMENT_GROUP)

esoPlusOffersScene:AddFragment(TREE_UNDERLAY_FRAGMENT)
esoPlusOffersScene:AddFragment(KEYBIND_STRIP_FADE_FRAGMENT)
esoPlusOffersScene:AddFragment(UI_SHORTCUTS_ACTION_LAYER_FRAGMENT)
esoPlusOffersScene:AddFragment(GENERAL_ACTION_LAYER_FRAGMENT)

-------------------
--Crown Crates Scene
-------------------
local remoteCrownCratesSceneKeyboard = ZO_RemoteScene:New("crownCrateKeyboard", SCENE_MANAGER)

