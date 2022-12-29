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

Describe -Name "Get-ModuleResource" {
    Context "Ensure module resources are returned" {
        It "Returns the module resource" {
            InModuleScope Evergreen {
                Get-ModuleResource | Should -BeOfType [System.Object]
            }
        }

        It "Given an invalid path, it throws" {
            InModuleScope Evergreen {
                { Get-ModuleResource -Path "C:\Temp\test.txt" } | Should -Throw
            }
        }

        It "Returns an object with the expected properties" {
            InModuleScope Evergreen {
                (Get-ModuleResource).Uri.Project | Should -Not -BeNullOrEmpty
                (Get-ModuleResource).Uri.Docs | Should -Not -BeNullOrEmpty
                (Get-ModuleResource).Uri.Issues | Should -Not -BeNullOrEmpty
                (Get-ModuleResource).Uri.Info | Should -Not -BeNullOrEmpty
            }
        }
    }
}
