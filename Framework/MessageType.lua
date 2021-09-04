---@class FrameworkMessageType
EsoAddonFramework_Framework_MessageType = {
    ---Sent from framework the first time a player is activated after login or ui reload.
    InitialActivation       = 1,
    ---Sent from framework to request controls that should be shown on the settings page.
    SettingsControlsRequest = 2,
    ---Send to framework to show settings page.
    ShowSettings            = 3,
    ---Sent from framework when settings page is shown.
    SettingsShown           = 4
}