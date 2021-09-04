$currentScriptArguments = $MyInvocation.UnboundArguments
$workingFolder = $currentScriptArguments[0]
& cmd.exe /C "cd /d $workingFolder & MKLINK /D Framework ..\Framework"