$Password = Read-Host -AsSecureString
New-LocalUser "FatCat" -Password $Password -FullName "FatCat The First"
Add-LocalGroupMember -Group "Administrators" -Member "FatCat"

$UserAccount = Get-LocalUser -Name "Administrator"
$UserAccount | Set-LocalUser -Password $Password
Disable-LocalUser -Name "Administrator"

Get-ScheduledTask | Stop-ScheduledTask
Get-ScheduledTask | Disable-ScheduledTask

$servicesToStop = @("CertPropSvc", "DiagTrack", "MSDTC", "MSMQ", "PlugPlay", "Spooler", "UsoSvc", "TokenBroker")
Get-Service -Name $servicesToStop | Stop-Service -Force -PassThru | Set-Service -StartupType Disabled

