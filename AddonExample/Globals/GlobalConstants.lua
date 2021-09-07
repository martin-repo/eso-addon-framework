-- AddonInfo section; keep formatting intact as it will be parsed
AddonExample_Globals_AddonInfo = {
    Name = "AddonExample",
    DisplayName = "AddonExample Display Name",
    Description = "",
    Author = "",
    Version = "1.0",
    SavedVariables = "AddonExampleStorage",
    Libraries = { "EsoAddonFramework", "LibAddonMenu-2.0" }
}

-- These strings are used in Bindings.xml
ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_ADDONEXAMPLE_ADDON_NAME", AddonExample_Globals_AddonInfo.DisplayName)
ZO_CreateStringId("SI_BINDING_NAME_ADDONEXAMPLE_SHOW_SETTINGS", "Show settings")