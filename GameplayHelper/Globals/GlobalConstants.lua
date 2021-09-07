-- AddonInfo section; keep formatting intact as it will be parsed
GameplayHelper_Globals_AddonInfo = {
    Name = "GameplayHelper",
    DisplayName = "Gameplay |c00ff00Helper|r",
    Description = "Collection of various automations for awesome people.",
    Author = "Martin",
    Version = "1.0",
    SavedVariables = "GameplayHelperStorage",
    Libraries = { "EsoAddonFramework", "LibAddonMenu-2.0" }
}

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_GAMEPLAY_HELPER_ADDON_NAME", GameplayHelper_Globals_AddonInfo.DisplayName)
ZO_CreateStringId("SI_BINDING_NAME_GAMEPLAY_HELPER_RELOADUI", "Reload UI")
ZO_CreateStringId("SI_BINDING_NAME_GAMEPLAY_HELPER_SHOW_SETTINGS", "Show settings")