#Requires -Modules Pester

BeforeAll {
    $repoRoot = (Get-Item $PSScriptRoot).Parent.Parent.FullName
    . (Join-Path $repoRoot 'src\Assessor\Private\Resolve-BenchmarkPack.ps1')

    $script:CatalogPath = Join-Path $repoRoot 'catalog\benchmarks'
    $script:Benchmark   = 'cis-m365-foundations-6.0.1'
}

Describe 'Resolve-BenchmarkPack — catalog loading' {
    It 'Loads controls from the Entra workload' {
        $c = Resolve-BenchmarkPack -CatalogPath $script:CatalogPath -Benchmark $script:Benchmark -Workloads @('Graph')
        $c | Should -Not -BeNullOrEmpty
        $c[0].workload | Should -Be 'Graph'
    }
    It 'Loads controls from the Exchange workload' {
        $c = Resolve-BenchmarkPack -CatalogPath $script:CatalogPath -Benchmark $script:Benchmark -Workloads @('Exchange')
        $c | Should -Not -BeNullOrEmpty
        $c[0].workload | Should -Be 'Exchange'
    }
    It 'Loads controls from the Teams workload' {
        $c = Resolve-BenchmarkPack -CatalogPath $script:CatalogPath -Benchmark $script:Benchmark -Workloads @('Teams')
        $c | Should -Not -BeNullOrEmpty
        $c[0].workload | Should -Be 'Teams'
    }
    It 'Loads controls from the SharePoint workload' {
        $c = Resolve-BenchmarkPack -CatalogPath $script:CatalogPath -Benchmark $script:Benchmark -Workloads @('SharePoint')
        $c | Should -Not -BeNullOrEmpty
        $c[0].workload | Should -Be 'SharePoint'
    }
    It 'All controls have required fields' {
        $controls = Resolve-BenchmarkPack -CatalogPath $script:CatalogPath -Benchmark $script:Benchmark
        foreach ($ctrl in $controls) {
            $ctrl.id               | Should -Not -BeNullOrEmpty
            $ctrl.title            | Should -Not -BeNullOrEmpty
            $ctrl.assessmentStatus | Should -BeIn @('Automated','Manual')
            $ctrl.level            | Should -BeIn @(1, 2)
        }
    }
    It 'Throws when benchmark pack does not exist' {
        { Resolve-BenchmarkPack -CatalogPath $script:CatalogPath -Benchmark 'non-existent-benchmark' } | Should -Throw
    }
}
