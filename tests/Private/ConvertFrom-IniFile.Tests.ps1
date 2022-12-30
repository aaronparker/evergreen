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

Describe -Name "ConvertFrom-IniFile" {
    BeforeAll {
        $Ini = Get-Content -Path "$env:GITHUB_WORKSPACE\tests\Test.ini"
    }

    Context "Ensure ConvertFrom-IniFile works as expected" {
        It "Should not throw" {
            InModuleScope Evergreen {
                { ConvertFrom-IniFile -InputObject $Ini } | Should -Not -Throw
            }
        }

        It "Returns a hashtable from an INI file" {
            InModuleScope Evergreen {
                (ConvertFrom-IniFile -InputObject $Ini) | Should -BeOfType [Hashtable]
            }
        }
    }
}
