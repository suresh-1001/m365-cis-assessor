<#
.SYNOPSIS
    Connects to Microsoft Graph using certificate-based app-only authentication.
.DESCRIPTION
    Reads connection parameters from the tenant config object and establishes
    a non-interactive Graph session. Returns a connection context object.
.PARAMETER TenantConfig
    Deserialized tenant config (PSCustomObject from sample-tenant.json).
#>
function Connect-GraphApp {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$TenantConfig
    )

    $cfg = $TenantConfig.Graph

    Write-Verbose "Graph: Connecting to tenant $($TenantConfig.TenantId) as app $($cfg.ClientId)"

    Connect-MgGraph `
        -TenantId   $TenantConfig.TenantId `
        -ClientId   $cfg.ClientId `
        -CertificateThumbprint $cfg.CertificateThumbprint `
        -NoWelcome `
        -ErrorAction Stop

    $ctx = Get-MgContext
    if (-not $ctx -or $ctx.AuthType -ne 'AppOnly') {
        throw "Graph: App-only connection failed — AuthType is '$($ctx.AuthType)'. Expected 'AppOnly'."
    }

    Write-Verbose "Graph: Connected OK (AppId=$($ctx.AppName), TenantId=$($ctx.TenantId))"

    return @{
        Workload = 'Graph'
        TenantId = $ctx.TenantId
        AppId    = $cfg.ClientId
        AuthType = $ctx.AuthType
        ConnectedAt = (Get-Date).ToUniversalTime()
    }
}
