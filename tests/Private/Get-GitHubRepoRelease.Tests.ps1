<#
    .SYNOPSIS
        Private Pester function tests.
#>
[OutputType()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

BeforeDiscovery {
}

BeforeAll {
}

Describe -Name "Get-GitHubRepoRelease" {
    Context "It correctly returns an object" {
        It "Does not throw when passed a correct URL" {
            InModuleScope -ModuleName "Evergreen" {

                # Params for Get-GitHubRepoRelease
                $params = @{
                    Uri          = "https://api.github.com/repos/atom/atom/releases/latest"
                    MatchVersion = "(\d+(\.\d+){1,4}).*"
                }
                { Get-GitHubRepoRelease @params } | Should -Not -Throw
            }
        }

        It "Does throws when passed an incorrect URL" {
            InModuleScope -ModuleName "Evergreen" {

                # Params for Get-GitHubRepoRelease
                $params = @{
                    Uri          = "https://api.example.com/repos/atom/atom/releases/latest"
                    MatchVersion = "(\d+(\.\d+){1,4}).*"
                }
                { Get-GitHubRepoRelease @params } | Should -Throw
            }
        }

        Context "It returns an object with the right properties" {
            InModuleScope -ModuleName "Evergreen" {
                BeforeAll {
                    # Params for Get-GitHubRepoRelease
                    $params = @{
                        Uri          = "https://api.github.com/repos/atom/atom/releases/latest"
                        MatchVersion = "(\d+(\.\d+){1,4}).*"
                    }
                    $result = Get-GitHubRepoRelease @params
                }

                It "Returns a Version property" {
                    $result.Version.Length | Should -BeGreaterThan 0
                }

                It "Returns a Platform property" {
                    $result.Platform.Length | Should -BeGreaterThan 0
                }

                It "Returns a Architecture property" {
                    $result.Architecture.Length | Should -BeGreaterThan 0
                }

                It "Returns a Type property" {
                    $result.Type.Length | Should -BeGreaterThan 0
                }

                It "Returns a Date property" {
                    $result.Date.Length | Should -BeGreaterThan 0
                }

                It "Returns a Size property" {
                    $result.Size.Length | Should -BeGreaterThan 0
                }

                It "Returns a URI property" {
                    $result.URI.Length | Should -BeGreaterThan 0
                }
            }
        }
    }
}
