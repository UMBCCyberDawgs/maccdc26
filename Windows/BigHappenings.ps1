Set-NetFirewallProfile -DefaultInboundAction Block -DefaultOutboundAction block
Set-NetFirewallProfile -NotifyOnListen True
Set-NetFirewallProfile -AllowUnicastResponseToMulticast True
Write-Host "Basic Settings Configured"

#Backup
$BFolder = New-Item -Path "C:\" -Name "Backups" -ItemType "Directory"
$BFolder.Attributes = "Hidden, ReadOnly"
$FWFolder = New-Item -Path "C:\" -Name "Logs" -ItemType "Directory"
$FWFolder.Attributes = "Hidden, ReadOnly"
#-Firewalls
netsh advfirewall export "C:\Backups\default.wfw"
Get-NetFirewallRule | Export-Csv -Path "C:\Backups\FWdefault.csv" -NoTypeInformation
Write-Host "Firewall Backups Made"
#-Registrys
reg export HKLM "C:\Backups\HKLM_Backup.reg"
reg export HKCU "C:\Backups\HKCU_Backup.reg"
reg export HKCR "C:\Backups\HKCR_Backup.reg"
Write-Host "Registry Backups Made"

#Logging
Set-NetFirewallProfile -Profile Domain -LogFileName %SystemRoot%\System32\LogFiles\Firewall\pfirewall_Domain.log
Set-NetFirewallProfile -Profile Private -LogFileName %SystemRoot%\System32\LogFiles\Firewall\pfirewall_Private.log
Set-NetFirewallProfile -Profile Public -LogFileName %SystemRoot%\System32\LogFiles\Firewall\pfirewall_Public.log
Set-NetFirewallProfile -LogAllowed True
Set-NetFirewallProfile -LogBlocked True
Set-NetFirewallProfile -LogIgnored True
Write-Host "Expansive Logging enabled"

#Reduce Load
$TelemetryReg = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
New-Item -Path $TelemetryReg -Force
New-ItemProperty -Path $TelemetryReg -Name "AllowTelemetry" -Value 0 -PropertyType "DWord"
#Reducing Profile
#-TelNet
Disable-WindowsOptionalFeature -Online "TelnetClient"
#-RDP
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 1
Disable-NetFirewallRule -DisplayGroup "Remote Desktop"
Stop-Service -Name TermService
Set-Service -Name TermService -StartupType Disabled
#-Win RM
Stop-Service WinRM
Set-Service WinRM -StartupType Disabled
Disable-PSRemoting -Force
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse
Disable-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)"
Disable-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)"
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system -Name LocalAccountTokenFilterPolicy -Value 0
#-SMBv1
Set-SmbServerConfiguration -EnableSMB1Protocol False
#-Print Spooler
Stop-Service Spooler
Set-Service Spooler -StartupType Disabled
#-WMI
Stop-Service winmgmt
Set-Service winmgmt -StartupType Disabled

#Keep two ports open :3
New-NetFirewallRule -DisplayName "Allow HTTPtcp" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow HTTPudp" -Direction Inbound -LocalPort 80 -Protocol UDP -Action Allow
New-NetFirewallRule -DisplayName "Allow HTTPtcp" -Direction Outbound -LocalPort 80 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow HTTPudp" -Direction Outbound -LocalPort 80 -Protocol UDP -Action Allow
New-NetFirewallRule -DisplayName "Allow HTTPStcp" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow HTTPSucp" -Direction Inbound -LocalPort 443 -Protocol UDP -Action Allow
New-NetFirewallRule -DisplayName "Allow HTTPStcp" -Direction Outbound -LocalPort 443 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow HTTPSucp" -Direction Outbound -LocalPort 443 -Protocol UDP -Action Allow

Set-MpPreference -DisableRealtimeMonitoring $false
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True