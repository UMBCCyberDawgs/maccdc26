#Script Author - catwithapples/takumi

$ErrorActionPreference = "Continue"

#Create fw directory

$backuppath1 = "C:\Windows\System32\ja-jq"
$backuppath2 = "$backuppath1\backup"
$backuppath3 = "C:\ProgramData\Microsoft\Temp"

$newFolder = New-Item -Path $backuppath1 -ItemType Directory
$newFolder.Attributes = "Hidden, ReadOnly"

#Create backup folder for other stuff
$backup = New-Item -Path $backuppath2 -ItemType Directory
$backup.Attributes = "Hidden, ReadOnly"

$extrabackup = New-Item -Path $backuppath3 -ItemType Directory
$extrabackup.Attributes = "Hidden, ReadOnly"

#Backup registry hives
reg export HKLM "$backuppath2\hklmbackup.reg"
reg export HKCU "$backuppath2\hkcubackup.reg"
reg export HKCR "$backuppath2\hkcrbackup.reg"

#Backup old fw
netsh advfirewall export "$backuppath1\default.wfw"
Get-NetFirewallRule | Export-Csv -Path "$backuppath1\DefaultRules.csv" -NoTypeInformation

#Hardening stage
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
netsh advfirewall import "$backuppath1\default.wfw" Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -DefaultInboundAction Block -DefaultOutboundAction Block -NotifyOnListen True -LogAllowed True -LogBlocked True -LogFileName %SystemRoot%\System32\LogFiles\Firewall\pfirewall.log

New-NetFirewallRule -DisplayName "Block Inbound " -Direction Inbound -Protocol TCP -LocalPort  -Action Block
New-NetFirewallRule -DisplayName "Block Inbound WinRM" -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Block
New-NetFirewallRule -DisplayName "Block Inbound WinRM" -Direction Inbound -Protocol TCP -LocalPort 5986 -Action Block
New-NetFirewallRule -DisplayName "Block Inbound SSH" -Direction Inbound -Protocol TCP -LocalPort 22 -Action Block
New-NetFirewallRule -DisplayName "Block Inbound RDP" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Block
New-NetFirewallRule -DisplayName "Block Inbound NetBIOS" -Direction Inbound -Protocol UDP -LocalPort 137-138 -Action Block

netsh advfirewall export "$backuppath1\good.wfw"

#Disable features
Disable-WindowsOptionalFeature -Online -FeatureName "TelnetClient"
Set-SmbServerConfiguration -EnableSMB1Protocol $false

#Set registry keys
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LMCompatibilityLevel" -Value 4
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" -Name "UseLogonCredential" -Value 0
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces\tcpip* -Name NetbiosOptions -Value 2
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -Name FullSecureChannelProtection -Value 1

#Add new registry keys
reg add HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest /v Negotiate /t REG_DWORD /d 0

#Stop bad services

$servicesToStop = @("CertPropSvc", "DiagTrack", "PlugPlay", "Spooler", "WinRM")
Get-Service -Name $servicesToStop | Stop-Service -Force -PassThru | Set-Service -StartupType Disabled
Disable-PSRemoting -Force
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 1
Disable-NetFirewallRule -DisplayGroup "Remote Desktop" 