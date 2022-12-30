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

Describe -Name "Get-Platform" {
    Context "Ensure platform is returned" {
        It "Given a platform string it returns the right platform" {
            InModuleScope -ModuleName "Evergreen" {
                Get-Platform -String "osx" | Should -Be "macOS"
            }
        }

        It "Given a string that won't match, returns Windows" {
            InModuleScope -ModuleName "Evergreen" {
                Get-Platform -String "Neque porro quisquam est qui dolorem" | Should -Be "Windows"
            }
        }
    }
}
