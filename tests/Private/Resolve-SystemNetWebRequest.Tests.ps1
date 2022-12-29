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

Describe -Name "Resolve-SystemNetWebRequest" {
    Context "Ensure Resolve-SystemNetWebRequest works as expected" {
        It "Returns data from a URL" {
            InModuleScope Evergreen {
                $params = @{
                    Uri                = "https://github.com"
                    MaximumRedirection = 1
                }
                (Resolve-SystemNetWebRequest @params).ResponseUri | Should -BeOfType [System.Uri]
            }
        }
    }
}
