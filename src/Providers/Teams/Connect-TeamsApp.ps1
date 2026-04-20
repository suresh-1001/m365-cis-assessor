<#
.SYNOPSIS
    Connects to Microsoft Teams using certificate-based app-only authentication.
#>
function Connect-TeamsApp {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$TenantConfig
    )

    $cfg = $TenantConfig.Teams

    Write-Verbose "Teams: Connecting to tenant $($cfg.TenantId)"

    Import-Module MicrosoftTeams -ErrorAction Stop
    Connect-MicrosoftTeams `
        -TenantId              $cfg.TenantId `
        -ApplicationId         $cfg.ApplicationId `
        -CertificateThumbprint $cfg.CertificateThumbprint `
        -ErrorAction Stop

    Write-Verbose "Teams: Connected OK"

    return @{
        Workload    = 'Teams'
        TenantId    = $cfg.TenantId
        AppId       = $cfg.ApplicationId
        ConnectedAt = (Get-Date).ToUniversalTime()
    }
}
