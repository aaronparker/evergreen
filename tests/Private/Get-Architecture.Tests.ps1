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

Describe -Name "Get-Architecture" {
    Context "It returns expected output" {
        It "Returns x64 given an x64 URL" {
            InModuleScope Evergreen {
                $64bitUrl = "https://statics.teams.cdn.office.net/production-windows-x64/1.3.00.34662/Teams_windows_x64.msi"
                Get-Architecture -String $64bitUrl | Should -Be "x64"
            }
        }

        It "Returns x86 given an x86 URL" {
            InModuleScope Evergreen {
                $32bitUrl = "http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/2001320074/AcroRdrDCUpd2001320074.msp"
                Get-Architecture -String $32bitUrl | Should -Be "x86"
            }
        }

        It "Returns x86 given a string that won't match anything" {
            InModuleScope Evergreen {
                Get-Architecture -String "the quick brown fox" | Should -Be "x86"
            }
        }
    }
}
