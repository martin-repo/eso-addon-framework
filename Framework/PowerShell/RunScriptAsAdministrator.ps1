$currentScriptArguments = $MyInvocation.UnboundArguments

$currentPrincipal = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdministrator = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (!$isAdministrator)
{
	$currentScriptArgumentString = "`"{0}`"" -f ($currentScriptArguments -Join "`" `"")
	Start-Process -FilePath "PowerShell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$($PSCommandPath)`" $($currentScriptArgumentString)" -Verb Runas 
	Exit
}

$scriptFilePath = $currentScriptArguments[0]

$lastArgumentIndex = $currentScriptArguments.Count - 1
$scriptArguments = "`"{0}`"" -f ($currentScriptArguments[1..$lastArgumentIndex] -Join "`" `"")

& $scriptFilePath $scriptArguments