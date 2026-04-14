#Requires -Modules Pester
<#
.SYNOPSIS
    Pester unit tests for the Invoke-ControlTest engine.
    Tests pass/fail/error/manual result handling without requiring
    live M365 connections — all assertions use mock data.
#>

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '..\..\src\Assessor\Assessor.psm1'
    Import-Module $modulePath -Force

    # Minimal mock connections hashtable
    $script:MockConnections = @{
        Graph      = @{ Workload = 'Graph';      AppId = 'mock-graph-app' }
        Exchange   = @{ Workload = 'Exchange';   AppId = 'mock-exo-app'   }
        Teams      = @{ Workload = 'Teams';      AppId = 'mock-teams-app' }
        SharePoint = @{ Workload = 'SharePoint'; AppId = 'mock-spo-app'   }
    }
}

Describe 'Invoke-ControlTest — Pass result' {
    It 'Returns Status=Pass when assertion returns Pass=$true' {
        $control = [PSCustomObject]@{
            id               = 'TEST.PASS.001'
            title            = 'Mock passing control'
            section          = 'Test Section'
            workload         = 'Graph'
            level            = 1
            assessmentStatus = 'Automated'
            remediationUrl   = 'https://example.com'
            assertion        = "param(`$Connections) return @{ Pass = `$true; Detail = 'All good'; Evidence = @{} }"
        }

        $result = Invoke-ControlTest -Control $control -Connections $script:MockConnections

        $result.Status      | Should -Be 'Pass'
        $result.ControlId   | Should -Be 'TEST.PASS.001'
        $result.StatusReason | Should -Be 'All good'
        $result.DurationMs  | Should -BeGreaterThan 0
    }
}

Describe 'Invoke-ControlTest — Fail result' {
    It 'Returns Status=Fail when assertion returns Pass=$false' {
        $control = [PSCustomObject]@{
            id               = 'TEST.FAIL.001'
            title            = 'Mock failing control'
            section          = 'Test Section'
            workload         = 'Exchange'
            level            = 1
            assessmentStatus = 'Automated'
            remediationUrl   = 'https://example.com'
            assertion        = "param(`$Connections) return @{ Pass = `$false; Detail = 'Setting misconfigured'; Evidence = @{ Value = 'bad' } }"
        }

        $result = Invoke-ControlTest -Control $control -Connections $script:MockConnections

        $result.Status       | Should -Be 'Fail'
        $result.StatusReason | Should -Be 'Setting misconfigured'
        $result.Evidence     | Should -Not -BeNullOrEmpty
    }
}

Describe 'Invoke-ControlTest — Error handling' {
    It 'Returns Status=Error when assertion throws' {
        $control = [PSCustomObject]@{
            id               = 'TEST.ERR.001'
            title            = 'Mock error control'
            section          = 'Test Section'
            workload         = 'Teams'
            level            = 1
            assessmentStatus = 'Automated'
            remediationUrl   = 'https://example.com'
            assertion        = "param(`$Connections) throw 'Simulated API failure'"
        }

        $result = Invoke-ControlTest -Control $control -Connections $script:MockConnections

        $result.Status      | Should -Be 'Error'
        $result.StatusReason | Should -Match 'Simulated API failure'
    }

    It 'Returns Status=Error when assertion returns wrong type' {
        $control = [PSCustomObject]@{
            id               = 'TEST.ERR.002'
            title            = 'Mock bad return type'
            section          = 'Test Section'
            workload         = 'Graph'
            level            = 1
            assessmentStatus = 'Automated'
            remediationUrl   = 'https://example.com'
            assertion        = "param(`$Connections) return 'not a hashtable'"
        }

        $result = Invoke-ControlTest -Control $control -Connections $script:MockConnections

        $result.Status | Should -Be 'Error'
    }
}

Describe 'Invoke-ControlTest — Manual controls' {
    It 'Returns Status=Manual without running assertion' {
        $control = [PSCustomObject]@{
            id               = 'TEST.MAN.001'
            title            = 'Mock manual control'
            section          = 'Test Section'
            workload         = 'SharePoint'
            level            = 2
            assessmentStatus = 'Manual'
            remediationUrl   = 'https://example.com'
            assertion        = $null
        }

        $result = Invoke-ControlTest -Control $control -Connections $script:MockConnections

        $result.Status | Should -Be 'Manual'
        $result.StatusReason | Should -Match 'manual review'
    }
}

Describe 'Invoke-ControlTest — Result object schema' {
    It 'Result object contains all required fields' {
        $control = [PSCustomObject]@{
            id               = 'TEST.SCHEMA.001'
            title            = 'Schema validation control'
            section          = 'Test Section'
            workload         = 'Graph'
            level            = 1
            assessmentStatus = 'Automated'
            remediationUrl   = 'https://example.com'
            assertion        = "param(`$Connections) return @{ Pass = `$true; Detail = 'OK'; Evidence = `$null }"
        }

        $result = Invoke-ControlTest -Control $control -Connections $script:MockConnections

        $result.PSObject.Properties.Name | Should -Contain 'ControlId'
        $result.PSObject.Properties.Name | Should -Contain 'Title'
        $result.PSObject.Properties.Name | Should -Contain 'Status'
        $result.PSObject.Properties.Name | Should -Contain 'StatusReason'
        $result.PSObject.Properties.Name | Should -Contain 'Workload'
        $result.PSObject.Properties.Name | Should -Contain 'Level'
        $result.PSObject.Properties.Name | Should -Contain 'StartTime'
        $result.PSObject.Properties.Name | Should -Contain 'EndTime'
        $result.PSObject.Properties.Name | Should -Contain 'DurationMs'
        $result.PSObject.Properties.Name | Should -Contain 'RemediationUrl'
    }
}
