#Requires -Modules Pester

BeforeAll {
    $repoRoot = (Get-Item $PSScriptRoot).Parent.Parent.FullName
    . (Join-Path $repoRoot 'src\Assessor\Private\Invoke-ControlTest.ps1')
    . (Join-Path $repoRoot 'src\Assessor\Private\Resolve-BenchmarkPack.ps1')

    $script:MockConnections = @{
        Graph      = @{ Workload = 'Graph';      AppId = 'mock' }
        Exchange   = @{ Workload = 'Exchange';   AppId = 'mock' }
        Teams      = @{ Workload = 'Teams';      AppId = 'mock' }
        SharePoint = @{ Workload = 'SharePoint'; AppId = 'mock' }
    }
}

Describe 'Invoke-ControlTest — Pass result' {
    It 'Returns Status=Pass when assertion returns Pass=$true' {
        $control = [PSCustomObject]@{ id='T.1'; title='Pass'; section='S'; workload='Graph'; level=1; assessmentStatus='Automated'; remediationUrl='https://x.com'; assertion="param(`$c) return @{ Pass=`$true; Detail='OK'; Evidence=@{} }" }
        $r = Invoke-ControlTest -Control $control -Connections $script:MockConnections
        $r.Status | Should -Be 'Pass'
    }
}
Describe 'Invoke-ControlTest — Fail result' {
    It 'Returns Status=Fail when assertion returns Pass=$false' {
        $control = [PSCustomObject]@{ id='T.2'; title='Fail'; section='S'; workload='Exchange'; level=1; assessmentStatus='Automated'; remediationUrl='https://x.com'; assertion="param(`$c) return @{ Pass=`$false; Detail='Bad'; Evidence=@{} }" }
        $r = Invoke-ControlTest -Control $control -Connections $script:MockConnections
        $r.Status | Should -Be 'Fail'
    }
}
Describe 'Invoke-ControlTest — Error handling' {
    It 'Returns Status=Error when assertion throws' {
        $control = [PSCustomObject]@{ id='T.3'; title='Error'; section='S'; workload='Teams'; level=1; assessmentStatus='Automated'; remediationUrl='https://x.com'; assertion="param(`$c) throw 'fail'" }
        $r = Invoke-ControlTest -Control $control -Connections $script:MockConnections
        $r.Status | Should -Be 'Error'
    }
    It 'Returns Status=Error when assertion returns wrong type' {
        $control = [PSCustomObject]@{ id='T.4'; title='BadType'; section='S'; workload='Graph'; level=1; assessmentStatus='Automated'; remediationUrl='https://x.com'; assertion="param(`$c) return 'string'" }
        $r = Invoke-ControlTest -Control $control -Connections $script:MockConnections
        $r.Status | Should -Be 'Error'
    }
}
Describe 'Invoke-ControlTest — Manual controls' {
    It 'Returns Status=Manual without running assertion' {
        $control = [PSCustomObject]@{ id='T.5'; title='Manual'; section='S'; workload='SharePoint'; level=2; assessmentStatus='Manual'; remediationUrl='https://x.com'; assertion=$null }
        $r = Invoke-ControlTest -Control $control -Connections $script:MockConnections
        $r.Status | Should -Be 'Manual'
    }
}
Describe 'Invoke-ControlTest — Result schema' {
    It 'Result object contains all required fields' {
        $control = [PSCustomObject]@{ id='T.6'; title='Schema'; section='S'; workload='Graph'; level=1; assessmentStatus='Automated'; remediationUrl='https://x.com'; assertion="param(`$c) return @{ Pass=`$true; Detail='OK'; Evidence=`$null }" }
        $r = Invoke-ControlTest -Control $control -Connections $script:MockConnections
        $r.PSObject.Properties.Name | Should -Contain 'ControlId'
        $r.PSObject.Properties.Name | Should -Contain 'Status'
        $r.PSObject.Properties.Name | Should -Contain 'DurationMs'
    }
}
