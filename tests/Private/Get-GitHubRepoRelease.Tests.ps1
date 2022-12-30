<#
    .SYNOPSIS
        Private Pester function tests.
#>
[OutputType()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification="This OK for the tests files.")]
param ()

BeforeDiscovery {
}

BeforeAll {
}

Describe -Name "Get-GitHubRepoRelease" {
    Context "It correctly returns an object" {
        It "Does not Throw" {
            InModuleScope -ModuleName "Evergreen" {

                # Params for Get-GitHubRepoRelease
                $gitHubParams = @{
                    Uri          = "https://api.github.com/repos/atom/atom/releases/latest"
                    MatchVersion = "(\d+(\.\d+){1,4}).*"
                }

                { Get-GitHubRepoRelease @gitHubParams } | Should -Not -Throw
            }
        }

        It "Returns the expected properties" {
            InModuleScope -ModuleName "Evergreen" {

                # Params for Get-GitHubRepoRelease
                $gitHubParams = @{
                    Uri          = "https://api.github.com/repos/atom/atom/releases/latest"
                    MatchVersion = "(\d+(\.\d+){1,4}).*"
                }
                $result = Get-GitHubRepoRelease @gitHubParams

                $result.Version.Length | Should -BeGreaterThan 0
                $result.Platform.Length | Should -BeGreaterThan 0
                $result.Architecture.Length | Should -BeGreaterThan 0
                $result.Type.Length | Should -BeGreaterThan 0
                $result.Date.Length | Should -BeGreaterThan 0
                $result.Size.Length | Should -BeGreaterThan 0
                $result.URI.Length | Should -BeGreaterThan 0
            }
        }
    }
}
