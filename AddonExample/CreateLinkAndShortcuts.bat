:: This script will
::   - Create a symbolic link to the Framework folder
::   - Create a link to ESO's live\AddOns folder
::   - Create a link to ESO's live\SavedVariables folder
@PowerShell.exe -ExecutionPolicy Bypass -File "..\Framework\PowerShell\RunScriptAsAdministrator.ps1" "%cd%\..\Framework\PowerShell\CreateFrameworkLink.ps1" "%cd%"
@PowerShell.exe -ExecutionPolicy Bypass -File "..\Framework\PowerShell\CreateShortcuts.ps1" "%cd%"