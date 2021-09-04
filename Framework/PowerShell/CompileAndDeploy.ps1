$currentScriptArguments = $MyInvocation.UnboundArguments
$addonFolderPath = $currentScriptArguments[0]

$addonName = [System.IO.Path]::GetFileName($addonFolderPath)

# **************************************************************************
# Functions
# **************************************************************************

function AddTermsToManifestBuilder
{
	# Open this script in Notepad++ and change Encoding to UTF-8-BOM for ® to show correctly
	$manifestBuilder.AppendLine(@"

# The creation and use of Add-ons are subject to the Add-on Terms of Use,
# available at https://account.elderscrollsonline.com/add-on-terms. 

# This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates.
# The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc.
# in the United States and/or other countries. All rights reserved.

"@) | Out-Null
}

# **************************************************************************
# Framework library
# **************************************************************************

$frameworkFilePaths = [System.Collections.ArrayList]@()

# ESO files - no dependencies
$frameworkFilePaths.Add("Eso\Event.lua") | Out-Null
$frameworkFilePaths.Add("Eso\EventManager.lua") | Out-Null
$frameworkFilePaths.Add("Eso\Pack.lua") | Out-Null
$frameworkFilePaths.Add("Eso\Type.lua") | Out-Null
$frameworkFilePaths.Add("Eso\UnitTag.lua") | Out-Null

# Framework files - no dependencies
$frameworkFilePaths.Add("Array.lua") | Out-Null
$frameworkFilePaths.Add("Color.lua") | Out-Null
$frameworkFilePaths.Add("Console.lua") | Out-Null
$frameworkFilePaths.Add("LogLevel.lua") | Out-Null
$frameworkFilePaths.Add("Map.lua") | Out-Null
$frameworkFilePaths.Add("MessageType.lua") | Out-Null
$frameworkFilePaths.Add("StorageScope.lua") | Out-Null
$frameworkFilePaths.Add("StringBuilder.lua") | Out-Null

# Framework files - dependencies, order is important
$frameworkFilePaths.Add("String.lua") | Out-Null
$frameworkFilePaths.Add("Messenger.lua") | Out-Null
$frameworkFilePaths.Add("Bootstrapper.lua") | Out-Null
$frameworkFilePaths.Add("SettingsManager.lua") | Out-Null
$frameworkFilePaths.Add("Storage.lua") | Out-Null
$frameworkFilePaths.Add("Log.lua") | Out-Null

# *****************
# Generate manifest
# *****************

$frameworkFolderPath = Join-Path -Path $addonFolderPath -ChildPath "Framework"
$currentVersionFilePath = Join-Path -Path $frameworkFolderPath -ChildPath "version.txt"
$currentVersion = Get-Content -Path $currentVersionFilePath
$apiVersionFilePath = Join-Path -Path $frameworkFolderPath -ChildPath "apiversion.txt"
$apiVersion = Get-Content -Path $apiVersionFilePath

$manifestBuilder = [System.Text.StringBuilder]::new()

$manifestBuilder.AppendLine("## Title: ESO Addon |c00ff00Framework|r") | Out-Null
$manifestBuilder.AppendLine("## APIVersion: $($apiVersion)") | Out-Null
$manifestBuilder.AppendLine("## Author: Martin") | Out-Null
$manifestBuilder.AppendLine("## Description: Library supporting development in Visual Studio Code.") | Out-Null
$manifestBuilder.AppendLine("## AddOnVersion: 1") | Out-Null
$manifestBuilder.AppendLine("## Version: $($currentVersion)") | Out-Null
$manifestBuilder.AppendLine("## IsLibrary: true") | Out-Null

AddTermsToManifestBuilder

foreach ($frameworkFilePath in $frameworkFilePaths | Select-Object -Unique)
{
    $manifestBuilder.AppendLine($frameworkFilePath) | Out-Null
}

$manifestFilePath = Join-Path -Path $frameworkFolderPath -ChildPath "EsoAddonFramework.txt"
[System.IO.File]::WriteAllText($manifestFilePath, $manifestBuilder.ToString())

$frameworkFilePaths.Add("EsoAddonFramework.txt") | Out-Null

# *****************
# Generate zip-file
# *****************

$zipFilename = "EsoAddonFramework-{0}.zip" -f $currentVersion
$zipFilePath = Join-Path -Path $addonFolderPath -ChildPath $zipFilename

if (Test-Path -Path $zipFilePath)
{
	Remove-Item $zipFilePath
}

Add-Type -Assembly "System.IO.Compression.FileSystem"

$zipFile = [System.IO.Compression.ZipFile]::Open($zipFilePath, "Create")

foreach ($frameworkFilePath in $frameworkFilePaths | Select-Object -Unique)
{
	$sourceFilePath = Join-Path -Path $frameworkFolderPath -ChildPath $frameworkFilePath
	$entryName = Join-Path -Path "EsoAddonFramework" -ChildPath $frameworkFilePath
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipFile, $sourceFilePath, $entryName) | Out-Null
}

$zipFile.Dispose()

# **************
# Copy to addons
# **************

$documentsFolderPath = [Environment]::GetFolderPath("MyDocuments")
$esoAddonsFolderPath = Join-Path -Path $documentsFolderPath -ChildPath "Elder Scrolls Online\live\AddOns"
$esoFrameworkFolderPath = Join-Path -Path $esoAddonsFolderPath -ChildPath "EsoAddonFramework"

if (Test-Path -Path $esoFrameworkFolderPath)
{
	Remove-Item -Recurse -Force $esoFrameworkFolderPath
}

Expand-Archive -Path $zipFilePath -DestinationPath $esoAddonsFolderPath

# *******
# Cleanup
# *******

Remove-Item -Path $manifestFilePath -Force

# **************************************************************************
# Addon
# **************************************************************************

$addonFilePaths = [System.Collections.ArrayList]@()

function AddFilePaths
{
    param ([string]$FolderPath)

	$paths = Get-ChildItem -Path $folderPath -Recurse -File | Where-Object { `
		$_.Name.EndsWith(".lua") `
		-and !$_.Name.EndsWith("Mock.lua") `
		-and !$_.Name.EndsWith("Tests.lua") `
		-and !$_.Name.EndsWith("Template.lua") `
	} | ForEach-Object { `
		$addonFilePaths.Add($_.FullName.Substring($addonFolderPath.Length + 1)) | Out-Null `
	}
}

$langFolderPath =  Join-Path -Path $addonFolderPath -ChildPath "\Lang"
$englishLangFilePath = Join-Path -Path $langFolderPath -ChildPath "\en.lua"
if (Test-Path -Path $englishLangFilePath)
{
	$addonFilePaths.Add("Lang\en.lua") | Out-Null
	$addonFilePaths.Add("Lang\`$(language).lua") | Out-Null
}

AddFilePaths -FolderPath ($addonFolderPath + "\Types")
AddFilePaths -FolderPath ($addonFolderPath + "\Globals")
Get-ChildItem -Path $addonFolderPath -Exclude "Framework", "Globals", "Types", "Lang" | Get-ChildItem -Recurse -File | Where-Object { `
	($_.Name.EndsWith(".lua") -or $_.Name.EndsWith(".xml")) `
	-and !$_.Name.Equals("$addonName.lua") `
	-and !$_.Name.EndsWith("Mock.lua") `
	-and !$_.Name.EndsWith("Tests.lua") `
} | ForEach-Object { `
	$addonFilePaths.Add($_.FullName.Substring($addonFolderPath.Length + 1)) | Out-Null `
}

$addonFilePaths.Add("$addonName.lua") | Out-Null

# *****************
# Generate manifest
# *****************

$contantsFilePath = Join-Path -Path $addonFolderPath -ChildPath "\Globals\GlobalConstants.lua"
$constantsContent = Get-Content -Path $contantsFilePath -Raw

$constantsContent -match "(?ms)$($addonName)_Globals_AddonInfo = {(?<Info>.+?)^}" | Out-Null
$addonInfoCode = $Matches["Info"]
$addonInfoJson = "{" + ($addonInfoCode -replace "(\w+) =", """`$1"":" -replace "{", "[" -replace "}", "]") + "}" | ConvertFrom-Json

$manifestBuilder = [System.Text.StringBuilder]::new()

$manifestBuilder.AppendLine("## Title: $($addonInfoJson.DisplayName)") | Out-Null
$manifestBuilder.AppendLine("## APIVersion: $($apiVersion)") | Out-Null
$manifestBuilder.AppendLine("## Author: $($addonInfoJson.Author)") | Out-Null
$manifestBuilder.AppendLine("## Description: $($addonInfoJson.Description)") | Out-Null
$manifestBuilder.AppendLine("## AddOnVersion: 1") | Out-Null
$manifestBuilder.AppendLine("## Version: $($addonInfoJson.Version)") | Out-Null
$manifestBuilder.AppendLine("## SavedVariables: $($addonInfoJson.SavedVariables)") | Out-Null
$manifestBuilder.AppendLine("## DependsOn: $($addonInfoJson.Libraries -join ' ')") | Out-Null

AddTermsToManifestBuilder

foreach ($addonFilePath in $addonFilePaths | Select-Object -Unique)
{
    $manifestBuilder.AppendLine($addonFilePath) | Out-Null
}

$manifestFilePath = Join-Path -Path $addonFolderPath -ChildPath "$addonName.txt"
[System.IO.File]::WriteAllText($manifestFilePath, $manifestBuilder.ToString())

$addonFilePaths.Add("$addonName.txt") | Out-Null

# *****************
# Generate zip-file
# *****************

$zipFilename = "{0}-{1}.zip" -f $addonName, $addonInfoJson.Version
$zipFilePath = Join-Path -Path $addonFolderPath -ChildPath $zipFilename

if (Test-Path -Path $zipFilePath)
{
	Remove-Item $zipFilePath
}

Add-Type -Assembly "System.IO.Compression.FileSystem"

$zipFile = [System.IO.Compression.ZipFile]::Open($zipFilePath, "Create")

foreach ($addonFilePath in $addonFilePaths | Select-Object -Unique)
{
	if ($addonFilePath.StartsWith("Lang\"))
	{
		continue
	}

	$sourceFilePath = Join-Path -Path $addonFolderPath -ChildPath $addonFilePath
	$entryName = Join-Path -Path $addonName -ChildPath $addonFilePath
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipFile, $sourceFilePath, $entryName) | Out-Null
}

if (Test-Path -Path $langFolderPath)
{
	Get-ChildItem -Path $langFolderPath -File | Where-Object { $_.Name.EndsWith(".lua") } | ForEach-Object { `
		$entryName = [IO.Path]::Combine($addonName, "Lang", $_.Name)
		[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipFile, $_.FullName, $entryName) | Out-Null
	}
}

$zipFile.Dispose()

# **************
# Copy to addons
# **************

$documentsFolderPath = [Environment]::GetFolderPath("MyDocuments")
$esoAddonsFolderPath = Join-Path -Path $documentsFolderPath -ChildPath "Elder Scrolls Online\live\AddOns"
$esoAddonFolderPath = Join-Path -Path $esoAddonsFolderPath -ChildPath $addonName

if (Test-Path -Path $esoAddonFolderPath)
{
	Remove-Item -Recurse -Force $esoAddonFolderPath
}

Expand-Archive -Path $zipFilePath -DestinationPath $esoAddonsFolderPath

# *******
# Cleanup
# *******

Remove-Item -Path $manifestFilePath -Force