:: This script will
::   - Read contents of Framework\FrameworkUsingsTemplate.lua and Globals\AddonUsingsTemplate.lua
::   - Iterate over every .lua file in the addon
::   - For each file, replace the usings regions with the contents of the previously read files
@PowerShell.exe -ExecutionPolicy Bypass -File "..\Framework\PowerShell\UpdateUsings.ps1" "%cd%"