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

Describe -Name "Invoke-SystemNetRequest" {
    Context "Ensure Invoke-SystemNetRequest works as expected" {
        It "Returns data from a URL" {
            InModuleScope Evergreen {
                $params = @{
                    Uri                = "https://github.com"
                    MaximumRedirection = 1
                }
                Invoke-SystemNetRequest @params | Should -BeOfType [System.String]
            }
        }
    }
}
