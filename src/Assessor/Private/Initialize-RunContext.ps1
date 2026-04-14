<#
.SYNOPSIS
    Creates the output folder structure for a scan run and returns a run ID.
#>
function Initialize-RunContext {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$TenantConfig,

        [Parameter(Mandatory)]
        [string]$Benchmark,

        [Parameter(Mandatory)]
        [datetime]$StartTime,

        [Parameter(Mandatory)]
        [string]$OutputPath
    )

    $slug    = $TenantConfig.TenantName -replace '[^a-zA-Z0-9]', '-' | ForEach-Object { $_.ToLower() }
    $runId   = "$($StartTime.ToUniversalTime().ToString('yyyy-MM-ddTHH-mm-ssZ'))_$slug"
    $runPath = Join-Path $OutputPath "runs\$runId"

    $subFolders = @('evidence', 'raw', 'logs')
    foreach ($folder in $subFolders) {
        New-Item -ItemType Directory -Path (Join-Path $runPath $folder) -Force | Out-Null
    }

    # Write manifest
    $manifest = [ordered]@{
        RunId       = $runId
        TenantName  = $TenantConfig.TenantName
        TenantId    = $TenantConfig.TenantId
        Benchmark   = $Benchmark
        StartTime   = $StartTime.ToUniversalTime().ToString('o')
        GeneratedBy = 'M365 CIS Assessor'
        Version     = '1.0.0'
    }

    $manifest | ConvertTo-Json -Depth 5 |
        Out-File -FilePath (Join-Path $runPath 'manifest.json') -Encoding UTF8

    # Return run path so orchestrator can pass it downstream
    return $runPath
}
