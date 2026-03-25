#Script Author - catwithapples/takumi

$ErrorActionPreference = "Continue"

#Create fw directory

$newFolder = New-Item -Path "C:\Windows\System32\ja-jq\"
$newFolder.Attributes = "Hidden, ReadOnly"

#Create backup folder for other stuff
$newFolder2 = New-Item -Path "C:\Windows\System\ja-jq\backup"

#Backup registry hives
reg export HKLM "C:\Windows\System\ja-jq\backup"
reg export HKCU "C:\Windows\System\ja-jq\backup"

#Backup old fw
netsh advfirewall export "C:\Windows\System32\ja-jq\default.wfw"
Get-NetFirewallRule | Export-Csv -Path "C:\Windows\System32\ja-jq\DefaultRules.csv" -NoTypeInformation

#Hardening stage
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
netsh advfirewall import "C:\Windows\System32\ja-jq\default.wfw" Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -DefaultInboundAction Block -DefaultOutboundAction Block -NotifyOnListen True -LogAllowed True -LogBlocked True -LogFileName %SystemRoot%\System32\LogFiles\Firewall\pfirewall.log

New-NetFirewallRule -DisplayName "Block Inbound RDP" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Block
New-NetFirewallRule -DisplayName "Block Inbound SMB" -Direction Inbound -Protocol TCP -LocalPort 445 -Action Block
New-NetFirewallRule -DisplayName "Block Inbound NetBIOS" -Direction Inbound -Protocol UDP -LocalPort 137-138 -Action Block

Write-Host "Firewall configured"

#Disable features
Disable-WindowsOptionalFeature -Online -FeatureName "TelnetClient"
Set-SmbServerConfiguration -EnableSMB1Protocol false

#Set registry keys
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LMCompatibilityLevel" -Value 4
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" -Name "UseLogonCredential" -Value 0
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces\tcpip* -Name NetbiosOptions -Value 2
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -Name FullSecureChannelProtection -Value 1
