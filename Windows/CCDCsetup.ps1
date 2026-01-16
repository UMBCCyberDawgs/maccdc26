$UserAccount = Get-LocalUser -Name "Administrator"
$UserAccount | Set-LocalUser -Password $Password

Get-ScheduledTask | Stop-ScheduledTask
Get-ScheduledTask | Disable-ScheduledTask

$servicesToStop = @("CertPropSvc", "DiagTrack", "PlugPlay", "Spooler")
Get-Service -Name $servicesToStop | Stop-Service -Force -PassThru | Set-Service -StartupType Disabled

Read-Host -Prompt "Press Enter to exit"