$UserAccount = Get-LocalUser -Name "Administrator"
$UserAccount | Set-LocalUser -Password $Password

Get-ScheduledTask | Stop-ScheduledTask
Get-ScheduledTask | Disable-ScheduledTask

$servicesToStop = @("CertPropSvc", "DiagTrack", "PlugPlay", "Spooler", "WinRM")
Get-Service -Name $servicesToStop | Stop-Service -Force -PassThru | Set-Service -StartupType Disabled
Disable-PSRemoting -Force
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 1
Disable-NetFirewallRule -DisplayGroup "Remote Desktop" 


Get-NetFirewallProfile | Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

Read-Host -Prompt "Press Enter to exit"