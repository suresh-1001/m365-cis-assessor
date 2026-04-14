# Assessor.psm1 — Module loader for M365 CIS Assessor

$providerRoot = Join-Path $PSScriptRoot '..\Providers'
$privateRoot  = Join-Path $PSScriptRoot 'Private'
$publicRoot   = Join-Path $PSScriptRoot 'Public'

# Load providers (auth functions)
$providerFiles = Get-ChildItem -Path $providerRoot -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue
foreach ($f in $providerFiles) { . $f.FullName }

# Load private helpers
$privateFiles = Get-ChildItem -Path $privateRoot -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue
foreach ($f in $privateFiles) { . $f.FullName }

# Load and export public functions
$publicFiles = Get-ChildItem -Path $publicRoot -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue
foreach ($f in $publicFiles) { . $f.FullName }

Export-ModuleMember -Function @(
    'Invoke-M365Assessment',
    'Test-M365Connections'
)
