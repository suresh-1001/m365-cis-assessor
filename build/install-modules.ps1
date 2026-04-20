<#
.SYNOPSIS
    Installs all PowerShell modules required by the M365 CIS Assessor.
.PARAMETER Force
    Reinstall modules even if already present.
.EXAMPLE
    .\build\install-modules.ps1
    .\build\install-modules.ps1 -Force
#>
[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$modules = @(
    @{ Name = 'Microsoft.Graph.Authentication';           MinVersion = '2.0.0' },
    @{ Name = 'Microsoft.Graph.Identity.SignIns';         MinVersion = '2.0.0' },
    @{ Name = 'Microsoft.Graph.Identity.DirectoryManagement'; MinVersion = '2.0.0' },
    @{ Name = 'Microsoft.Graph.DeviceManagement';         MinVersion = '2.0.0' },
    @{ Name = 'Microsoft.Graph.Security';                 MinVersion = '2.0.0' },
    @{ Name = 'Microsoft.Graph.Teams';                    MinVersion = '2.0.0' },
    @{ Name = 'ExchangeOnlineManagement';                 MinVersion = '3.0.0' },
    @{ Name = 'MicrosoftTeams';  MinVersion = '5.0.0'; MaximumVersion = '5.3.0' },
    @{ Name = 'PnP.PowerShell';  MinVersion = '2.4.0'; MaximumVersion = '2.99.0' },
    @{ Name = 'Maester';                                  MinVersion = '0.0.1' },
    @{ Name = 'PSScriptAnalyzer';                         MinVersion = '1.21.0' }
)

Write-Host "`nM365 CIS Assessor — Module Installer" -ForegroundColor Cyan
Write-Host "PowerShell version: $($PSVersionTable.PSVersion)`n"

if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Warning "PowerShell 7.2+ is required. Current version: $($PSVersionTable.PSVersion)"
    exit 1
}

# Ensure PSGallery is trusted
$gallery = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
if ($gallery -and $gallery.InstallationPolicy -ne 'Trusted') {
    Write-Host "Setting PSGallery as Trusted..." -ForegroundColor Yellow
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

$installed = @()
$failed    = @()

foreach ($m in $modules) {
    $existing = Get-Module -ListAvailable -Name $m.Name |
        Sort-Object Version -Descending | Select-Object -First 1

    if ($existing -and -not $Force) {
        Write-Host "  [OK]     $($m.Name) $($existing.Version)" -ForegroundColor Green
        $installed += $m.Name
        continue
    }

    Write-Host "  [INSTALL] $($m.Name)..." -ForegroundColor Yellow -NoNewline
    try {
        $installParams = @{
            Name           = $m.Name
            Scope          = 'CurrentUser'
            Force          = $true
            AllowClobber   = $true
            MinimumVersion = $m.MinVersion
        }
        if ($m.MaximumVersion) { $installParams.MaximumVersion = $m.MaximumVersion }
        Install-Module @installParams
    }
    catch {
        Write-Host " FAILED" -ForegroundColor Red
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
        $failed += $m.Name
    }
}

Write-Host "`nInstalled : $($installed.Count) modules" -ForegroundColor Green
if ($failed.Count -gt 0) {
    Write-Host "Failed    : $($failed -join ', ')" -ForegroundColor Red
    exit 1
}

Write-Host "`nAll modules ready. Run Test-M365Connections to validate auth.`n" -ForegroundColor Cyan
