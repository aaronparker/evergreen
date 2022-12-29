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

Describe -Name "Get-FunctionResource" {
    Context "Ensure function resources are returned" {
        It "Given a valid app it returns valid data" {
            InModuleScope Evergreen {
                Get-FunctionResource -AppName "MicrosoftEdge" | Should -BeOfType [System.Object]
            }
        }

        It "Given an invalid application, it throws" {
            InModuleScope Evergreen {
                { Get-FunctionResource -AppName "DoesNotExist" } | Should -Throw
            }
        }
    }
}
