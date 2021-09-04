Add-Type -AssemblyName PresentationFramework

$currentScriptArguments = $MyInvocation.UnboundArguments
$rootFolderPath = $currentScriptArguments[0]

# *******************
# Get current version
# *******************

$frameworkFolderPath = Join-Path -Path $rootFolderPath -ChildPath "Framework"
$currentVersionFilePath = Join-Path -Path $frameworkFolderPath -ChildPath "version.txt"
$currentVersion = Get-Content -Path $currentVersionFilePath

# ******************
# Get latest version
# ******************

$releaseText = Invoke-webrequest -UseBasicParsing -Uri "https://api.github.com/repos/martin-repo/eso-addon-framework/releases/latest"
$releaseJson = $releaseText | ConvertFrom-Json
$releaseVersion = $releaseJson.tag_name

# *********************
# Download if different
# *********************

if ($currentVersion -eq $releaseVersion)
{
    [System.Windows.MessageBox]::Show("Framework is up-to-date at " + $currentVersion, "Update Framework") | Out-Null
    Exit
}

$frameworkZipFilename = "eso-addon-framework-$releaseVersion.zip"
$frameworkZipFilePath = Join-Path -Path $rootFolderPath -ChildPath $frameworkZipFilename

if (!(Test-Path -Path $frameworkZipFilePath))
{
    $frameworkZipUrl = "https://github.com/martin-repo/eso-addon-framework/releases/latest/download/eso-addon-framework.zip"
    Invoke-WebRequest -Uri $frameworkZipUrl -OutFile $frameworkZipFilePath
}

[System.Windows.MessageBox]::Show("Framework zip downloaded at " + $frameworkZipFilename, "Update Framework") | Out-Null