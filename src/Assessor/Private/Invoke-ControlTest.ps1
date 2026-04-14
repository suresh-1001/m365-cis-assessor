<#
.SYNOPSIS
    Core test engine. Evaluates a single CIS control definition and returns
    a standardised result object.
.DESCRIPTION
    Each control in the catalog defines an Assertion block — a scriptblock
    that returns $true (pass), $false (fail), or throws (error).
    Invoke-ControlTest executes that block, catches errors, and wraps
    everything in a consistent [PSCustomObject] result.
#>
function Invoke-ControlTest {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$Control,

        [Parameter(Mandatory)]
        [hashtable]$Connections,

        [Parameter()]
        [string]$EvidencePath
    )

    $startTime = Get-Date

    $result = [PSCustomObject]@{
        ControlId        = $Control.id
        Title            = $Control.title
        Section          = $Control.section
        Workload         = $Control.workload
        Level            = $Control.level
        AssessmentStatus = $Control.assessmentStatus   # Automated / Manual
        Status           = 'Unknown'                   # Pass / Fail / Error / Manual / NotApplicable
        StatusReason     = ''
        Evidence         = $null
        RemediationUrl   = $Control.remediationUrl
        StartTime        = $startTime.ToUniversalTime()
        EndTime          = $null
        DurationMs       = 0
    }

    # Manual controls are flagged immediately — no assertion to run
    if ($Control.assessmentStatus -eq 'Manual') {
        $result.Status      = 'Manual'
        $result.StatusReason = 'This control requires manual review. See remediation guidance.'
        $result.EndTime     = (Get-Date).ToUniversalTime()
        $result.DurationMs  = ([datetime]$result.EndTime - [datetime]$result.StartTime).TotalMilliseconds
        return $result
    }

    try {
        # Execute the assertion scriptblock defined in the control catalog
        $assertionBlock = [scriptblock]::Create($Control.assertion)
        $evidence = & $assertionBlock -Connections $Connections

        # Assertion must return a hashtable: @{ Pass = $true/$false; Detail = '...' }
        if ($evidence -isnot [hashtable]) {
            throw "Assertion for $($Control.id) must return a hashtable with 'Pass' and 'Detail' keys."
        }

        $result.Status      = if ($evidence.Pass) { 'Pass' } else { 'Fail' }
        $result.StatusReason = $evidence.Detail
        $result.Evidence    = $evidence.Evidence

        # Write evidence to disk if path provided
        if ($EvidencePath -and $evidence.Evidence) {
            $evidenceFile = Join-Path $EvidencePath "$($Control.id).json"
            $evidence.Evidence | ConvertTo-Json -Depth 10 |
                Out-File -FilePath $evidenceFile -Encoding UTF8 -Force
        }
    }
    catch {
        $result.Status      = 'Error'
        $result.StatusReason = $_.Exception.Message
    }
    finally {
        $result.EndTime    = (Get-Date).ToUniversalTime()
        $result.DurationMs = ([datetime]$result.EndTime - [datetime]$result.StartTime).TotalMilliseconds
    }

    return $result
}
