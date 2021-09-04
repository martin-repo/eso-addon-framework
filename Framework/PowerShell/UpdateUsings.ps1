$currentScriptArguments = $MyInvocation.UnboundArguments
$addonFolderPath = $currentScriptArguments[0]

$frameworkUsingsFilePath = Join-Path -Path $addonFolderPath -ChildPath "Framework\FrameworkUsingsTemplate.lua"
$frameworkUsings = $null
if (Test-Path -Path $frameworkUsingsFilePath)
{
	$frameworkUsings = Get-Content -Path $frameworkUsingsFilePath -Raw
}

$addonUsingsFilePath = Join-Path -Path $addonFolderPath -ChildPath "Globals\AddonUsingsTemplate.lua"
$addonUsings = $null
if (Test-Path -Path $addonUsingsFilePath)
{
	$addonUsings = Get-Content -Path $addonUsingsFilePath -Raw
}

function UpdateUsings
{
    param ([string]$FilePath)

	$fileContent = Get-Content -Path $FilePath -Raw
	
	if ($frameworkUsings -ne $null)
	{
		$fileContent = $fileContent -replace "(?s)--#region Framework usings.*?--#endregion", $frameworkUsings
	}
	
	if ($addonUsings -ne $null)
	{
		$fileContent = $fileContent -replace "(?s)--#region Addon usings.*?--#endregion", $addonUsings
	}
	
	Set-Content -Path $FilePath -Value $fileContent -NoNewline
}

Get-ChildItem -Path $addonFolderPath -Exclude "Framework" | `
	Get-ChildItem -Recurse -File | Where-Object { $_.Name.EndsWith(".lua") -and !$_.Name.EndsWith("Template.lua") } | `
	ForEach-Object { UpdateUsings -FilePath $_.FullName }