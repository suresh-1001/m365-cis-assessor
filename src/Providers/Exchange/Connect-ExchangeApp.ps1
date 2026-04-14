<#
.SYNOPSIS
    Connects to Exchange Online using certificate-based app-only authentication.
#>
function Connect-ExchangeApp {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$TenantConfig
    )

    $cfg = $TenantConfig.Exchange

    Write-Verbose "Exchange: Connecting to $($cfg.Organization)"

    Connect-ExchangeOnline `
        -AppId                  $cfg.AppId `
        -CertificateThumbprint  $cfg.CertificateThumbprint `
        -Organization           $cfg.Organization `
        -ShowBanner:$false `
        -ErrorAction Stop

    Write-Verbose "Exchange: Connected OK"

    return @{
        Workload     = 'Exchange'
        Organization = $cfg.Organization
        AppId        = $cfg.AppId
        ConnectedAt  = (Get-Date).ToUniversalTime()
    }
}
