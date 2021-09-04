-- AddonInfo section; keep formatting intact as it will be parsed
GamepadHelper_Globals_AddonInfo = {
    Name = "GamepadHelper",
    DisplayName = "Gamepad |c00ff00Helper|r",
    Description = "Collection of various automations for gamepad users.",
    Author = "Martin",
    Version = "1.0",
    SavedVariables = "GamepadHelperStorage",
    Libraries = { "EsoAddonFramework", "LibAddonMenu-2.0" }
}

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_GAMEPAD_HELPER_ADDON_NAME", GamepadHelper_Globals_AddonInfo.DisplayName)
ZO_CreateStringId("SI_BINDING_NAME_GAMEPAD_HELPER_RELOADUI", "Reload UI")
ZO_CreateStringId("SI_BINDING_NAME_GAMEPAD_HELPER_SHOW_SETTINGS", "Show settings")