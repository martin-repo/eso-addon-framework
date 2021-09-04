$currentScriptArguments = $MyInvocation.UnboundArguments
$addonFolderPath = $currentScriptArguments[0]

# ***************
# AddOns shortcut
# ***************

$WScriptShell = New-Object -ComObject WScript.Shell

$documentsFolderPath = [Environment]::GetFolderPath("MyDocuments")
$addonsFolderPath = Join-Path -Path $documentsFolderPath -ChildPath "Elder Scrolls Online\live\AddOns"

$shortcutFilePath = Join-Path -Path $addonFolderPath -ChildPath "ESO AddOns.lnk"

$shortcut = $WScriptShell.CreateShortcut($shortcutFilePath)
$shortcut.TargetPath = $addonsFolderPath
$shortcut.Save()

# ***********************
# SavedVariables shortcut
# ***********************

$savedVariablesFolderPath = Join-Path -Path $documentsFolderPath -ChildPath "Elder Scrolls Online\live\SavedVariables"

$shortcutFilePath = Join-Path -Path $addonFolderPath -ChildPath "ESO SavedVariables.lnk"

$shortcut = $WScriptShell.CreateShortcut($shortcutFilePath)
$shortcut.TargetPath = $savedVariablesFolderPath
$shortcut.Save()