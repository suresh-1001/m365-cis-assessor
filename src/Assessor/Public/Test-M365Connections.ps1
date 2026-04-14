<#
.SYNOPSIS
    Validates certificate-based app-only connections for all configured workloads.
.DESCRIPTION
    Run this before Invoke-M365Assessment to confirm auth is working.
    Exits with a non-zero code if any workload fails to connect.
.EXAMPLE
    Test-M365Connections -TenantConfigPath .\config\tenants\contoso-prod.json -Verbose
#>
function Test-M365Connections {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string]$TenantConfigPath,

        [Parameter()]
        [ValidateSet('Graph', 'Exchange', 'Teams', 'SharePoint')]
        [string[]]$Workloads = @('Graph', 'Exchange', 'Teams', 'SharePoint')
    )

    $tenantConfig = Get-Content $TenantConfigPath -Raw | ConvertFrom-Json

    Write-Host "`nM365 CIS Assessor — Connection Test" -ForegroundColor Cyan
    Write-Host "Tenant  : $($tenantConfig.TenantName)"
    Write-Host "Testing : $($Workloads -join ', ')`n"

    $results = @{}

    foreach ($workload in $Workloads) {
        Write-Host "  $($workload.PadRight(12))" -NoNewline
        try {
            $conn = switch ($workload) {
                'Graph'      { Connect-GraphApp      -TenantConfig $tenantConfig }
                'Exchange'   { Connect-ExchangeApp   -TenantConfig $tenantConfig }
                'Teams'      { Connect-TeamsApp      -TenantConfig $tenantConfig }
                'SharePoint' { Connect-SharePointApp -TenantConfig $tenantConfig }
            }
            Write-Host "OK  — AppId: $($conn.AppId)" -ForegroundColor Green
            $results[$workload] = $true
        }
        catch {
            Write-Host "FAIL — $($_.Exception.Message)" -ForegroundColor Red
            $results[$workload] = $false
        }
    }

    $failed = $results.GetEnumerator() | Where-Object { -not $_.Value }
    Write-Host ""

    if ($failed) {
        Write-Host "Connection failures: $($failed.Key -join ', ')" -ForegroundColor Red
        Write-Host "Fix the above before running Invoke-M365Assessment.`n"
        return $false
    }

    Write-Host "All connections successful.`n" -ForegroundColor Green
    return $true
}
