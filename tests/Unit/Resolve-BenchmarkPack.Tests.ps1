#Requires -Modules Pester
<#
.SYNOPSIS
    Pester unit tests for Resolve-BenchmarkPack — catalog loader.
#>

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '..\..\src\Assessor\Assessor.psm1'
    Import-Module $modulePath -Force

    # Point at the real catalog for integration-style unit tests
    $script:CatalogPath = Join-Path $PSScriptRoot '..\..\catalog\benchmarks'
    $script:Benchmark   = 'cis-m365-foundations-6.0.1'
}

Describe 'Resolve-BenchmarkPack — catalog loading' {
    It 'Loads controls from the Entra workload' {
        $controls = Resolve-BenchmarkPack `
            -CatalogPath $script:CatalogPath `
            -Benchmark   $script:Benchmark `
            -Workloads   @('Graph')

        $controls | Should -Not -BeNullOrEmpty
        $controls[0].id | Should -Match '^CIS\.M365\.'
        $controls[0].workload | Should -Be 'Graph'
    }

    It 'Loads controls from the Exchange workload' {
        $controls = Resolve-BenchmarkPack `
            -CatalogPath $script:CatalogPath `
            -Benchmark   $script:Benchmark `
            -Workloads   @('Exchange')

        $controls | Should -Not -BeNullOrEmpty
        $controls[0].workload | Should -Be 'Exchange'
    }

    It 'Loads controls from the Teams workload' {
        $controls = Resolve-BenchmarkPack `
            -CatalogPath $script:CatalogPath `
            -Benchmark   $script:Benchmark `
            -Workloads   @('Teams')

        $controls | Should -Not -BeNullOrEmpty
        $controls[0].workload | Should -Be 'Teams'
    }

    It 'Loads controls from the SharePoint workload' {
        $controls = Resolve-BenchmarkPack `
            -CatalogPath $script:CatalogPath `
            -Benchmark   $script:Benchmark `
            -Workloads   @('SharePoint')

        $controls | Should -Not -BeNullOrEmpty
        $controls[0].workload | Should -Be 'SharePoint'
    }

    It 'Loads controls from all four workloads when no filter specified' {
        $controls = Resolve-BenchmarkPack `
            -CatalogPath $script:CatalogPath `
            -Benchmark   $script:Benchmark

        $workloads = $controls | Select-Object -ExpandProperty workload -Unique | Sort-Object
        $workloads | Should -Contain 'Graph'
        $workloads | Should -Contain 'Exchange'
        $workloads | Should -Contain 'Teams'
        $workloads | Should -Contain 'SharePoint'
    }

    It 'All controls have required fields' {
        $controls = Resolve-BenchmarkPack `
            -CatalogPath $script:CatalogPath `
            -Benchmark   $script:Benchmark

        foreach ($ctrl in $controls) {
            $ctrl.id               | Should -Not -BeNullOrEmpty
            $ctrl.title            | Should -Not -BeNullOrEmpty
            $ctrl.assessmentStatus | Should -BeIn @('Automated','Manual')
            $ctrl.level            | Should -BeIn @(1, 2)
        }
    }

    It 'Throws when benchmark pack does not exist' {
        { Resolve-BenchmarkPack `
            -CatalogPath $script:CatalogPath `
            -Benchmark   'non-existent-benchmark' } | Should -Throw
    }
}
