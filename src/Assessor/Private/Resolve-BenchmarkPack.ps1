<#
.SYNOPSIS
    Loads control definitions from the benchmark catalog JSON files.
    Filters by workload if specified.
#>
function Resolve-BenchmarkPack {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory)]
        [string]$CatalogPath,

        [Parameter(Mandatory)]
        [string]$Benchmark,

        [Parameter()]
        [string[]]$Workloads = @('Graph', 'Exchange', 'Teams', 'SharePoint')
    )

    $benchmarkPath = Join-Path $CatalogPath $Benchmark

    if (-not (Test-Path $benchmarkPath)) {
        throw "Benchmark pack not found: $benchmarkPath"
    }

    # Workload -> subfolder mapping
    $workloadMap = @{
        'Graph'      = 'entra'
        'Exchange'   = 'exchange'
        'Teams'      = 'teams'
        'SharePoint' = 'sharepoint'
    }

    $allControls = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($workload in $Workloads) {
        $folder = $workloadMap[$workload]
        if (-not $folder) { continue }

        $controlsPath = Join-Path $benchmarkPath "controls\$folder"
        if (-not (Test-Path $controlsPath)) {
            Write-Warning "No controls folder found for workload '$workload' at: $controlsPath"
            continue
        }

        $files = Get-ChildItem -Path $controlsPath -Filter '*.json' -Recurse
        foreach ($file in $files) {
            try {
                $controls = Get-Content $file.FullName -Raw | ConvertFrom-Json
                foreach ($ctrl in $controls) {
                    $ctrl | Add-Member -NotePropertyName 'workload' -NotePropertyValue $workload -Force
                    $allControls.Add($ctrl)
                }
            }
            catch {
                Write-Warning "Failed to load control file $($file.Name): $($_.Exception.Message)"
            }
        }
    }

    if ($allControls.Count -eq 0) {
        throw "No controls loaded from benchmark '$Benchmark'. Check catalog path and workload filters."
    }

    return $allControls.ToArray()
}
