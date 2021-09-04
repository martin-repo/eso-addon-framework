--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local panelBuilder = ZO_KeyboardOptionsPanelBuilder:New(SETTING_PANEL_GAMEPLAY)

-------------------------
-- Gameplay -> General --
-------------------------
panelBuilder:AddSetting({
    controlName = "Options_Gameplay_FootInverseKinematics",
    settingType = SETTING_TYPE_IN_WORLD,
    settingId = IN_WORLD_UI_SETTING_FOOT_INVERSE_KINEMATICS,
    header = SI_GAMEPLAY_OPTIONS_GENERAL,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_HidePolymorphHelm",
    settingType = SETTING_TYPE_IN_WORLD,
    settingId = IN_WORLD_UI_SETTING_HIDE_POLYMORPH_HELM,
    header = SI_GAMEPLAY_OPTIONS_GENERAL,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_HideMountStaminaUpgrade",
    settingType = SETTING_TYPE_IN_WORLD,
    settingId = IN_WORLD_UI_SETTING_HIDE_MOUNT_STAMINA_UPGRADE,
    header = SI_GAMEPLAY_OPTIONS_GENERAL,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_HideMountSpeedUpgrade",
    settingType = SETTING_TYPE_IN_WORLD,
    settingId = IN_WORLD_UI_SETTING_HIDE_MOUNT_SPEED_UPGRADE,
    header = SI_GAMEPLAY_OPTIONS_GENERAL,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_HideMountInventoryUpgrade",
    settingType = SETTING_TYPE_IN_WORLD,
    settingId = IN_WORLD_UI_SETTING_HIDE_MOUNT_INVENTORY_UPGRADE,
    header = SI_GAMEPLAY_OPTIONS_GENERAL,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_CompanionReactions",
    settingType = SETTING_TYPE_IN_WORLD,
    settingId = IN_WORLD_UI_SETTING_COMPANION_REACTION_FREQUENCY,
    header = SI_GAMEPLAY_OPTIONS_GENERAL,
})

-------------------------
-- Gameplay -> Combat  --
-------------------------
panelBuilder:AddSetting({
    controlName = "Options_Gameplay_MonsterTells",
    settingType = SETTING_TYPE_COMBAT,
    settingId = COMBAT_SETTING_MONSTER_TELLS_ENABLED,
    header = SI_AUDIO_OPTIONS_COMBAT,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_MonsterTellsColorSwapEnabled",
    settingType = SETTING_TYPE_COMBAT,
    settingId = COMBAT_SETTING_MONSTER_TELLS_COLOR_SWAP_ENABLED,
    header = SI_AUDIO_OPTIONS_COMBAT,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_MonsterTellsFriendlyColor",
    settingType = SETTING_TYPE_COMBAT,
    settingId = COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_COLOR,
    header = SI_AUDIO_OPTIONS_COMBAT,
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_MonsterTellsFriendlyBrightness",
    settingType = SETTING_TYPE_COMBAT,
    settingId = COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_BRIGHTNESS,
    header = SI_AUDIO_OPTIONS_COMBAT,
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_MonsterTellsFriendlyTest",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_MONSTER_TELLS_FRIENDLY_TEST,
    header = SI_AUDIO_OPTIONS_COMBAT,
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_MonsterTellsEnemyColor",
    settingType = SETTING_TYPE_COMBAT,
    settingId = COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR,
    header = SI_AUDIO_OPTIONS_COMBAT,
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_MonsterTellsEnemyBrightness",
    settingType = SETTING_TYPE_COMBAT,
    settingId = COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS,
    header = SI_AUDIO_OPTIONS_COMBAT,
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_MonsterTellsEnemyTest",
    settingType = SETTING_TYPE_CUSTOM,
    settingId = OPTIONS_CUSTOM_SETTING_MONSTER_TELLS_ENEMY_TEST,
    header = SI_AUDIO_OPTIONS_COMBAT,
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_DodgeDoubleTap",
    settingType = SETTING_TYPE_COMBAT,
    settingId = COMBAT_SETTING_ROLL_DODGE_DOUBLE_TAP,
    header = SI_AUDIO_OPTIONS_COMBAT,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_RollDodgeTime",
    settingType = SETTING_TYPE_COMBAT,
    settingId = COMBAT_SETTING_ROLL_DODGE_WINDOW,
    header = SI_AUDIO_OPTIONS_COMBAT,
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_ClampGroundTarget",
    settingType = SETTING_TYPE_COMBAT,
    settingId = COMBAT_SETTING_CLAMP_GROUND_TARGET_ENABLED,
    header = SI_AUDIO_OPTIONS_COMBAT,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_PreventAttackingInnocents",
    settingType = SETTING_TYPE_COMBAT,
    settingId = COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS,
    header = SI_AUDIO_OPTIONS_COMBAT,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_QuickCastGroundAbilities",
    settingType = SETTING_TYPE_COMBAT,
    settingId = COMBAT_SETTING_QUICK_CAST_GROUND_ABILITIES,
    header = SI_AUDIO_OPTIONS_COMBAT,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_AllowCompanionAutoUltimate",
    settingType = SETTING_TYPE_COMBAT,
    settingId = COMBAT_SETTING_ALLOW_COMPANION_AUTO_ULTIMATE,
    header = SI_AUDIO_OPTIONS_COMBAT,
})

-------------------------
-- Gameplay -> Gamepad --
-------------------------

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_InputPreferredMode",
    settingType = SETTING_TYPE_GAMEPAD,
    settingId = GAMEPAD_SETTING_INPUT_PREFERRED_MODE,
    header = SI_GAMEPAD_SECTION_HEADER,
})

-------------------------
-- Gameplay -> Items --
-------------------------
panelBuilder:AddSetting({
    controlName = "Options_Gameplay_UseAoeLoot",
    settingType = SETTING_TYPE_LOOT,
    settingId = LOOT_SETTING_AOE_LOOT,
    header = SI_GAMEPLAY_OPTIONS_ITEMS,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_UseAutoLoot",
    settingType = SETTING_TYPE_LOOT,
    settingId = LOOT_SETTING_AUTO_LOOT,
    header = SI_GAMEPLAY_OPTIONS_ITEMS,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_UseAutoLoot_Stolen",
    settingType = SETTING_TYPE_LOOT,
    settingId = LOOT_SETTING_AUTO_LOOT_STOLEN,
    header = SI_GAMEPLAY_OPTIONS_ITEMS,
    indentLevel = 1,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_PreventStealingPlaced",
    settingType = SETTING_TYPE_LOOT,
    settingId = LOOT_SETTING_PREVENT_STEALING_PLACED,
    header = SI_GAMEPLAY_OPTIONS_ITEMS,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_AutoAddToCraftBag",
    settingType = SETTING_TYPE_LOOT,
    settingId = LOOT_SETTING_AUTO_ADD_TO_CRAFT_BAG,
    header = SI_GAMEPLAY_OPTIONS_ITEMS,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_LootHistory",
    settingType = SETTING_TYPE_LOOT,
    settingId = LOOT_SETTING_LOOT_HISTORY,
    header = SI_GAMEPLAY_OPTIONS_ITEMS,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_DefaultSoulGem",
    settingType = SETTING_TYPE_IN_WORLD,
    settingId = IN_WORLD_UI_SETTING_DEFAULT_SOUL_GEM,
    header = SI_GAMEPLAY_OPTIONS_ITEMS,
})

---------------------------
-- Gameplay -> Tutorials --
---------------------------
panelBuilder:AddSetting({
    controlName = "Options_Gameplay_TutorialEnabled",
    settingType = SETTING_TYPE_TUTORIAL,
    settingId = TUTORIAL_ENABLED_SETTING_ID,
    header = SI_GAMEPLAY_OPTIONS_TUTORIALS,
})

panelBuilder:AddSetting({
    controlName = "Options_Gameplay_ResetTutorials",
    settingType = SETTING_TYPE_TUTORIAL,
    settingId = OPTIONS_CUSTOM_SETTING_RESET_TUTORIALS,
    header = SI_GAMEPLAY_OPTIONS_TUTORIALS,
    indentLevel = 1,
})
