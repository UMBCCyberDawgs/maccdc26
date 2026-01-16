# Windows AD CCDC Checklist

## 1. Min Zero Speedrun

### Change Admin PW

### Disable Script Execution Bypass
`Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell" -Name "ExecutionPolicy" -Value "RemoteSigned"`

### Get\Remove Users:

`Get-ADUser` , `Remove-ADUser -Identity "Guest"`

### Unshare C Drive / Check Shares
`Computer Management in Search bar or Win+X`

###  Backup FW
`mkdir C:\Windows\System32\ja-jq\`
`cd C:\Windows\System32\ja-jq\`
`attrib +h +r`
`netsh advfirewall export “C:\Windows\System32\ja-jq\default.wfw”`
`attrib +h +r *`

### Harden FW
`Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True`

`netsh advfirewall import "C:\Windows\System32\ja-jq\default.wfw" set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -DefaultInboundAction Block -DefaultOutboundAction Block -NotifyOnListen True -LogAllowed True -LogBlocked True -LogFileName %SystemRoot%\System32\LogFiles\Firewall\pfirewall.log`

`New-NetFirewallRule -DisplayName "Block Inbound NetBIOS" -Direction Inbound -Protocol UDP -LocalPort 137-138 -Action Block`

`New-NetFirewallRule -DisplayName "Block Inbound SMB" -Direction Inbound -Protocol TCP -LocalPort 445 -Action Block`

`New-NetFirewallRule -DisplayName "Block Inbound RDP" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Block`

`netsh advfirewall export “C:\Windows\System32\ja-jq\good.wfw”`

### Disable Bad Features
`Disable-WindowsOptionalFeature -Online -FeatureName "TelnetClient"`

`Set-SmbServerConfiguration -EnableSMB1Protocol $false`

### Early Reg Keys
`Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LMCompatibilityLevel" -Value 4`

`Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" -Name "UseLogonCredential" -Value 0`

### ZeroLogon Mitigations

`HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters (DWORD) FullSecureChannelProtection Set to 1`

`Relevant GPO: Domain controller: Allow vulnerable Netlogon secure channel connections (remove any users in here)`

`Disable Print Spooler Service`

`Patches: KB4566424 or Later, Ideally just press the update button, if not go here: https://www.catalog.update.microsoft.com/Search.aspx?q=KB4566424`

### Kerberoasting Mitigations

`Look for 4768/4769 event spam, encryption type 0x11/0x12 are real, 0x17 is RC4 which is bad`

`Nuke the SPNs, 25 Char passwords for Users/Service Accounts, etc`

### Mimikatz Mitigations

`Add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa and Set the value of the registry key to: “RunAsPPL”=dword:00000001`

1. Open the Group Policy Management.
2. Create a new Group Policy Object (GPO) linked at the domain level.
3. Right-click the GPO, and then select Edit to open the Group Policy Management Editor.
4. Expand Computer Configuration, expand Preferences, and then expand Windows Settings.
5. Right-click Registry, point to New, and then select Registry Item.
6. Set the following values:
    Action: Update
    Hive: HKEY_LOCAL_MACHINE
    Key Path: SYSTEM\CurrentControlSet\Control\Lsa
    Value name: RunAsPPL
    Value type: REG_DWORD
    Value data: 00000001 (Hexadecimal)
7. Select OK.

### Backup DNS Reg Key and also Folder/Exe In Case of Trolling
`HKLM\SYSTEM\CurrentControlSet\Services\DNS`

### The Entire Audit Policy:

| Name | S/F/SF/NA / (V) |
|-----------------|-----------------|
| **Account Logon** | ************** |
| Credential Validation | SF |
| Kerberos Auth Service | SF |
| Kerberos Service Ticket Ops | SF |
| Other Account Logon Events | SF |
|-----------------|-----------------|
| **Account Management** | ************** |
| App Group | SF |
| Comp Account | SF |
| Distr Group | SF |
| Other Acct | SF |
| Sec Group | SF |
| User Account | SF |
|-----------------|-----------------|
| **Detailed Tracking** | ************** |
| DPAPI | NA |
| PnP | S |
| Process Creation | SF |
| Process Termination | NA |
| RPC | SF |
| Audit Token Right | S (V) |
|-----------------|-----------------|
| **DS Access**    | ************** |
| Detailed Dir Service Repl | NA |
| Dir Service Access | NA |
| Dir Service Changes | SF |
| Dir Service Repl | NA |
|-----------------|-----------------|
| **Logon/Logoff**    | ************** |
| Row 2, Col 1    | Row 2, Col 2    |
| Row 3, Col 1    | Row 3, Col 2    |
|-----------------|-----------------|
| Row 1, Col 1    | ************** |
| Row 2, Col 1    | Row 2, Col 2    |
| Row 3, Col 1    | Row 3, Col 2    |
|-----------------|-----------------|
| Row 1, Col 1    | ************** |
| Row 2, Col 1    | Row 2, Col 2    |
| Row 3, Col 1    | Row 3, Col 2    |
|-----------------|-----------------|
| Row 1, Col 1    | ************** |
| Row 2, Col 1    | Row 2, Col 2    |
| Row 3, Col 1    | Row 3, Col 2    |
|-----------------|-----------------|
| Row 1, Col 1    | ************** |
| Row 2, Col 1    | Row 2, Col 2    |
| Row 3, Col 1    | Row 3, Col 2    |
|-----------------|-----------------|
### Cipher Suite Reg Keys
- Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 256/256" -Name "Enabled" -Value 1
- Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 128/128" -Name "Enabled" -Value 1
- Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128" -Name "Enabled" -Value 0
- Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server" -Name "Enabled" -Value 0
- Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" -Name "Enabled" -Value 0
- Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "Enabled" -Value 0
- Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "Enabled" -Value 0
- Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name "Enabled" -Value 1 Restart services

### Late GPOS

`run > gpedit.msc > User config > admin templates > system > prevent access to the command prompt/access to registry editing tools`
