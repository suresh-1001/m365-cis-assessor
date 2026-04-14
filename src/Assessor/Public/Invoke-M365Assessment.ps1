<#
.SYNOPSIS
    Main orchestrator for the M365 CIS Assessment.
.DESCRIPTION
    Loads tenant config, connects to workloads, runs all controls from the
    specified benchmark, collects evidence, and writes the output package.
.PARAMETER TenantConfigPath
    Path to a tenant JSON config file.
.PARAMETER Benchmark
    Benchmark identifier (must match a folder under catalog/benchmarks/).
    Example: cis-m365-foundations-6.0.1
.PARAMETER OutputPath
    Root folder for run output. A timestamped subfolder is created automatically.
.PARAMETER Workloads
    Which workloads to include. Defaults to all four.
.PARAMETER CatalogPath
    Optional override for the benchmark catalog root.
.EXAMPLE
    Invoke-M365Assessment `
        -TenantConfigPath .\config\tenants\contoso-prod.json `
        -Benchmark cis-m365-foundations-6.0.1 `
        -OutputPath .\output `
        -Workloads Graph,Exchange
.EXAMPLE
    # Full scan, all workloads
    Invoke-M365Assessment `
        -TenantConfigPath .\config\tenants\contoso-prod.json `
        -Benchmark cis-m365-foundations-6.0.1 `
        -OutputPath .\output
#>
function Invoke-M365Assessment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string]$TenantConfigPath,

        [Parameter(Mandatory)]
        [string]$Benchmark,

        [Parameter(Mandatory)]
        [string]$OutputPath,

        [Parameter()]
        [ValidateSet('Graph', 'Exchange', 'Teams', 'SharePoint')]
        [string[]]$Workloads = @('Graph', 'Exchange', 'Teams', 'SharePoint'),

        [Parameter()]
        [string]$CatalogPath
    )

    begin {
        $ErrorActionPreference = 'Stop'
        $startTime = (Get-Date).ToUniversalTime()

        Write-Host "`nM365 CIS Assessor — Starting run" -ForegroundColor Cyan
        Write-Host "  Benchmark : $Benchmark"
        Write-Host "  Workloads : $($Workloads -join ', ')"
        Write-Host "  Started   : $($startTime.ToString('o'))`n"
    }

    process {
        # ── Load tenant config ───────────────────────────────────────────────
        $tenantConfig = Get-Content $TenantConfigPath -Raw | ConvertFrom-Json
        Write-Host "Tenant: $($tenantConfig.TenantName)" -ForegroundColor White

        # ── Initialise run context ───────────────────────────────────────────
        $runPath = Initialize-RunContext `
            -TenantConfig $tenantConfig `
            -Benchmark    $Benchmark `
            -StartTime    $startTime `
            -OutputPath   $OutputPath

        Write-Host "Run output : $runPath`n"

        # ── Resolve benchmark catalog ────────────────────────────────────────
        if (-not $CatalogPath) {
            $moduleRoot  = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
            $CatalogPath = Join-Path $moduleRoot 'catalog\benchmarks'
        }

        $controlCatalog = Resolve-BenchmarkPack `
            -CatalogPath $CatalogPath `
            -Benchmark   $Benchmark `
            -Workloads   $Workloads

        Write-Host "Loaded $($controlCatalog.Count) controls from benchmark catalog.`n"

        # ── Connect to workloads ─────────────────────────────────────────────
        $connections = @{}
        foreach ($workload in $Workloads) {
            Write-Host "Connecting: $workload..." -ForegroundColor Yellow -NoNewline
            try {
                $conn = switch ($workload) {
                    'Graph'      { Connect-GraphApp      -TenantConfig $tenantConfig }
                    'Exchange'   { Connect-ExchangeApp   -TenantConfig $tenantConfig }
                    'Teams'      { Connect-TeamsApp      -TenantConfig $tenantConfig }
                    'SharePoint' { Connect-SharePointApp -TenantConfig $tenantConfig }
                }
                $connections[$workload] = $conn
                Write-Host " OK" -ForegroundColor Green
            }
            catch {
                Write-Host " FAILED — $_" -ForegroundColor Red
                Write-Warning "Skipping $workload — controls will be marked Error."
            }
        }

        Write-Host ""

        # ── Run controls ─────────────────────────────────────────────────────
        $results  = [System.Collections.Generic.List[PSCustomObject]]::new()
        $evidPath = Join-Path $runPath 'evidence'
        $total    = $controlCatalog.Count
        $i        = 0

        foreach ($control in $controlCatalog) {
            $i++
            $pct = [math]::Round(($i / $total) * 100)
            Write-Progress -Activity 'Running CIS Controls' `
                -Status "$($control.id) — $($control.title)" `
                -PercentComplete $pct

            $result = Invoke-ControlTest `
                -Control      $control `
                -Connections  $connections `
                -EvidencePath $evidPath

            $results.Add($result)

            $color = switch ($result.Status) {
                'Pass'  { 'Green'  }
                'Fail'  { 'Red'    }
                'Error' { 'Yellow' }
                default { 'Gray'   }
            }
            Write-Host "  [$($result.Status.PadRight(6))] $($control.id) — $($control.title)" -ForegroundColor $color
        }

        Write-Progress -Activity 'Running CIS Controls' -Completed

        # ── Write outputs ─────────────────────────────────────────────────────
        Write-Host "`nWriting output package..." -ForegroundColor Cyan

        # summary.json
        $summary = [ordered]@{
            RunId        = Split-Path $runPath -Leaf
            TenantName   = $tenantConfig.TenantName
            Benchmark    = $Benchmark
            TotalControls = $results.Count
            Pass          = ($results | Where-Object Status -eq 'Pass').Count
            Fail          = ($results | Where-Object Status -eq 'Fail').Count
            Error         = ($results | Where-Object Status -eq 'Error').Count
            Manual        = ($results | Where-Object Status -eq 'Manual').Count
            CompletedAt   = (Get-Date).ToUniversalTime().ToString('o')
        }

        $summary | ConvertTo-Json -Depth 5 |
            Out-File (Join-Path $runPath 'summary.json') -Encoding UTF8

        # control-results.csv
        $results | Export-Csv (Join-Path $runPath 'control-results.csv') -NoTypeInformation -Encoding UTF8

        # HTML dashboard
        New-AssessmentDashboard -Results $results -Summary $summary -OutputPath $runPath

        # ── Print summary ─────────────────────────────────────────────────────
        Write-Host "`n── Run Complete ────────────────────────────────────────────────" -ForegroundColor Cyan
        Write-Host "  Pass   : $($summary.Pass)"   -ForegroundColor Green
        Write-Host "  Fail   : $($summary.Fail)"   -ForegroundColor Red
        Write-Host "  Error  : $($summary.Error)"  -ForegroundColor Yellow
        Write-Host "  Manual : $($summary.Manual)" -ForegroundColor Gray
        Write-Host "  Output : $runPath`n"         -ForegroundColor White

        return $runPath
    }
}
