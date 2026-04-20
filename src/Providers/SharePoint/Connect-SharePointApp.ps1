<#
.SYNOPSIS
    Connects to SharePoint Online using certificate-based app-only authentication via PnP.
#>
function Connect-SharePointApp {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$TenantConfig
    )

    $cfg = $TenantConfig.SharePoint

    Write-Verbose "SharePoint: Connecting to $($cfg.AdminUrl)"

    Connect-PnPOnline `
        -Url                   $cfg.AdminUrl `
        -ClientId              $cfg.ClientId `
        -Tenant                $TenantConfig.TenantId `
        -Thumbprint $cfg.CertificateThumbprint `
        -ErrorAction Stop

    Write-Verbose "SharePoint: Connected OK"

    return @{
        Workload    = 'SharePoint'
        AdminUrl    = $cfg.AdminUrl
        AppId       = $cfg.ClientId
        ConnectedAt = (Get-Date).ToUniversalTime()
    }
}
