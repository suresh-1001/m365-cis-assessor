name: Scheduled Assessment

on:
  schedule:
    - cron: '0 6 * * 1'   # Every Monday at 6 AM UTC
  workflow_dispatch:        # Manual trigger from GitHub UI
    inputs:
      workloads:
        description: 'Workloads to scan (comma-separated: Graph,Exchange,Teams,SharePoint)'
        required: false
        default: 'Graph,Exchange,Teams,SharePoint'
      benchmark:
        description: 'Benchmark identifier'
        required: false
        default: 'cis-m365-foundations-6.0.1'

jobs:
  assess:
    name: Run M365 CIS Assessment
    runs-on: windows-latest

    steps:
      - uses: actions/checkout@v4

      - name: Install required modules
        shell: pwsh
        run: .\build\install-modules.ps1

      - name: Write tenant config from secrets
        shell: pwsh
        run: |
          $config = @{
            TenantName     = "${{ secrets.TENANT_NAME }}"
            TenantId       = "${{ secrets.TENANT_ID }}"
            DefaultDomain  = "${{ secrets.DEFAULT_DOMAIN }}"
            Graph = @{
              ClientId              = "${{ secrets.GRAPH_CLIENT_ID }}"
              CertificateThumbprint = "${{ secrets.CERT_THUMBPRINT }}"
            }
            Exchange = @{
              AppId                 = "${{ secrets.GRAPH_CLIENT_ID }}"
              CertificateThumbprint = "${{ secrets.CERT_THUMBPRINT }}"
              Organization          = "${{ secrets.DEFAULT_DOMAIN }}"
            }
            Teams = @{
              ApplicationId         = "${{ secrets.GRAPH_CLIENT_ID }}"
              CertificateThumbprint = "${{ secrets.CERT_THUMBPRINT }}"
              TenantId              = "${{ secrets.TENANT_ID }}"
            }
            SharePoint = @{
              AdminUrl              = "https://${{ secrets.SHAREPOINT_PREFIX }}-admin.sharepoint.com"
              ClientId              = "${{ secrets.GRAPH_CLIENT_ID }}"
              TenantId              = "${{ secrets.TENANT_ID }}"
              CertificateThumbprint = "${{ secrets.CERT_THUMBPRINT }}"
            }
          }
          $config | ConvertTo-Json -Depth 5 |
            Out-File -FilePath config/tenants/ci-tenant.json -Encoding UTF8

      - name: Install certificate from secret
        shell: pwsh
        run: |
          $certBytes = [Convert]::FromBase64String("${{ secrets.CERT_PFX_BASE64 }}")
          $certPath  = Join-Path $env:TEMP 'ci-cert.pfx'
          [IO.File]::WriteAllBytes($certPath, $certBytes)
          Import-PfxCertificate `
            -FilePath $certPath `
            -CertStoreLocation Cert:\CurrentUser\My `
            -Password (ConvertTo-SecureString -String "${{ secrets.CERT_PASSWORD }}" -AsPlainText -Force) |
            Out-Null
          Remove-Item $certPath -Force

      - name: Validate connections
        shell: pwsh
        run: |
          Import-Module .\src\Assessor\Assessor.psm1
          $ok = Test-M365Connections -TenantConfigPath config/tenants/ci-tenant.json -Verbose
          if (-not $ok) { exit 1 }

      - name: Run assessment
        shell: pwsh
        run: |
          Import-Module .\src\Assessor\Assessor.psm1
          $workloads = "${{ github.event.inputs.workloads || 'Graph,Exchange,Teams,SharePoint' }}" -split ','
          $benchmark = "${{ github.event.inputs.benchmark || 'cis-m365-foundations-6.0.1' }}"
          Invoke-M365Assessment `
            -TenantConfigPath config/tenants/ci-tenant.json `
            -Benchmark $benchmark `
            -OutputPath output `
            -Workloads $workloads

      - name: Upload assessment artifacts
        uses: actions/upload-artifact@v4
        with:
          name: cis-assessment-${{ github.run_number }}
          path: output/runs/
          retention-days: 90

      - name: Clean up tenant config
        if: always()
        shell: pwsh
        run: Remove-Item config/tenants/ci-tenant.json -Force -ErrorAction SilentlyContinue
