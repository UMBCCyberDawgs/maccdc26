<#
.SYNOPSIS
  Sets Advanced Audit Policy to Microsoft's Windows Server 2025 baseline recommendations
  and increases the Security log maximum size to 128 MB.

.DESCRIPTION
  - Applies baseline audit subcategories (success/failure) for member servers.
  - Optional: adds DS Access (Directory Service) auditing when -TreatAsDomainController is used.
  - Bumps the Security log's max size to 128 MB and retains overwrite-as-needed behavior.
  - Backs up current audit policy before changes.

.PARAMETER TreatAsDomainController
  Include audit subcategories Microsoft recommends for domain controllers only.

.PARAMETER SecurityLogSizeMB
  Target size for the Security event log (default 128).

.PARAMETER AlsoResizeSystemAndApplication
  Also resize the Application and System logs to SecurityLogSizeMB.

.NOTES
  Run from an elevated PowerShell session. Local settings can be overridden by GPO.

#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$TreatAsDomainController,
    [int]$SecurityLogSizeMB = 128,
    [switch]$AlsoResizeSystemAndApplication
)

function Assert-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        throw "Please run this script in an elevated PowerShell session."
    }
}

function Set-AuditSubcategory {
    param(
        [Parameter(Mandatory)]
        [string]$Subcategory,

        [Parameter(Mandatory)]
        [bool]$Success,

        [Parameter(Mandatory)]
        [bool]$Failure
    )
    $succ = if ($Success) { 'enable' } else { 'disable' }
    $fail = if ($Failure) { 'enable' } else { 'disable' }

    Write-Verbose "Setting '$Subcategory'  Success:$Success  Failure:$Failure"
    & auditpol.exe /set /subcategory:"$Subcategory" /success:$succ /failure:$fail | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "auditpol failed for subcategory '$Subcategory' (exit $LASTEXITCODE)."
    }
}

function Backup-AuditPolicy {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $path  = Join-Path $env:TEMP "auditpol-backup-$stamp.txt"
    & auditpol.exe /backup /file:"$path" | Out-Null
    Write-Host "Backed up current audit policy to: $path"
}

function Resize-ClassicLog {
    param(
        [Parameter(Mandatory)][string]$LogName,
        [Parameter(Mandatory)][int]$SizeMB
    )
    # Windows classic logs: Application, Security, System.
    $bytes = [int64]$SizeMB * 1MB
    # Use wevtutil for max size (bytes)
    & wevtutil.exe sl "$LogName" /ms:$bytes | Out-Null
    # Ensure overwrite-as-needed behavior on classic logs
    try {
        Limit-EventLog -LogName $LogName -MaximumSize ("{0}MB" -f $SizeMB) -OverflowAction OverwriteAsNeeded -ErrorAction Stop
    } catch {
        Write-Warning "Limit-EventLog failed for $LogName: $($_.Exception.Message)"
    }
}

try {
    Assert-Admin

    Write-Host "Backing up current audit policy..."
    Backup-AuditPolicy

    Write-Host "Applying Windows Server 2025 baseline Advanced Audit Policy settings..."

    # ---- Baseline (Member Server) settings — per Microsoft recommendations ----
    $baseline = @(
        # Account Logon
        @{ Sub='Credential Validation';              S=$true;  F=$true }   # Success+Failure
        @{ Sub='Kerberos Authentication Service';    S=$true;  F=$true }
        @{ Sub='Kerberos Service Ticket Operations'; S=$true;  F=$true }
        @{ Sub='Other Account Logon Events';         S=$true;  F=$true }

        # Account Management
        @{ Sub='Computer Account Management';        S=$true;  F=$false }  # Failure only on DCs (handled below)
        @{ Sub='Other Account Management Events';    S=$true;  F=$true }
        @{ Sub='Security Group Management';          S=$true;  F=$true }
        @{ Sub='User Account Management';            S=$true;  F=$true }

        # Detailed Tracking
        @{ Sub='DPAPI Activity';                     S=$true;  F=$true }
        @{ Sub='Process Creation';                   S=$true;  F=$false }  # Stronger: enable Failure too if you prefer

        # Logon/Logoff
        @{ Sub='Account Lockout';                    S=$true;  F=$false }
        @{ Sub='Logoff';                             S=$true;  F=$false }
        @{ Sub='Logon';                              S=$true;  F=$true }
        @{ Sub='Other Logon/Logoff Events';          S=$true;  F=$true }
        @{ Sub='Special Logon';                      S=$true;  F=$false }  # Stronger: enable Failure too if desired

        # Policy Change
        @{ Sub='Audit Policy Change';                S=$true;  F=$true }
        @{ Sub='Authentication Policy Change';       S=$true;  F=$false }
        @{ Sub='MPSSVC Rule-Level Policy Change';    S=$true;  F=$false }  # Firewall rule-level change events

        # System
        @{ Sub='IPsec Driver';                       S=$true;  F=$true }
        @{ Sub='Security State Change';              S=$true;  F=$true }
        @{ Sub='Security System Extension';          S=$true;  F=$true }
        @{ Sub='System Integrity';                   S=$true;  F=$true }
    )

    foreach ($item in $baseline) {
        Set-AuditSubcategory -Subcategory $item.Sub -Success $item.S -Failure $item.F
    }

    # ---- Domain Controller–only additions (DS Access) ----
    if ($TreatAsDomainController) {
        Write-Host "Including Domain Controller–only recommendations (DS Access)..."
        $dcOnly = @(
            @{ Sub='Directory Service Access';        S=$true;  F=$true }
            @{ Sub='Directory Service Changes';       S=$true;  F=$true }
            # If you explicitly need replication auditing noise, uncomment:
            # @{ Sub='Directory Service Replication';   S=$true;  F=$true }
        )
        foreach ($item in $dcOnly) {
            Set-AuditSubcategory -Subcategory $item.Sub -Success $item.S -Failure $item.F
        }

        # On DCs, add Failure auditing for Computer Account Management (baseline shows Failure on DC)
        Set-AuditSubcategory -Subcategory 'Computer Account Management' -Success $true -Failure $true
    }

    # ---- Increase Security log size ----
    Write-Host "Setting Security log size to $SecurityLogSizeMB MB..."
    Resize-ClassicLog -LogName 'Security' -SizeMB $SecurityLogSizeMB

    if ($AlsoResizeSystemAndApplication) {
        Write-Host "Also resizing Application and System logs to $SecurityLogSizeMB MB..."
        Resize-ClassicLog -LogName 'Application' -SizeMB $SecurityLogSizeMB
        Resize-ClassicLog -LogName 'System'      -SizeMB $SecurityLogSizeMB
    }

    # ---- Optional: include command line in 4688 (process creation) events ----
    # Microsoft security baselines commonly enable this via GPO.
    # Uncomment if desired:
    New-Item -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit' -Force | Out-Null
    New-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit' `
         -Name 'ProcessCreationIncludeCmdLine_Enabled' -PropertyType DWord -Value 1 -Force | Out-Null

    Write-Host "Done. Current summary:"
    & auditpol.exe /get /category:* | Out-Host
    Get-WinEvent -ListLog Security | Select-Object LogName, MaximumSizeInBytes, LogMode | Format-List
}
catch {
    Write-Error $_
    exit 1
}