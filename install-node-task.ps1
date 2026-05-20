$taskName = "OpenClaw Node"
$nodePath = "C:\Users\48856\.openclaw\node.cmd"
$user = $env:USERNAME

$action = New-ScheduledTaskAction -Execute $nodePath
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $user
$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType S4U -RunLevel Limited

if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Description "OpenClaw Node service" -Force
Write-Output "SUCCESS: Scheduled task '$taskName' created for user $user"
