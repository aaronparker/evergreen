<#
    .SYNOPSIS
        Public Pester function tests.
#>
[OutputType()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification="This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification="Outputs to log host.")]
param ()

BeforeDiscovery {
}

BeforeAll {
}

Describe -Tag "Test" -Name "Test-EvergreenApp" {
    BeforeAll {
        $App = Get-EvergreenApp -Name "MicrosoftOneDrive"
        $Result = Test-EvergreenApp -InputObject $App
    }

    It "Should not throw with valid input" {
        { Test-EvergreenApp -InputObject $App } | Should -Not -Throw
    }

    It "Should return an object with valid properties" {
        $Result[0].Result | Should -BeOfType [System.Boolean]
        $Result[0].URI | Should -BeOfType [System.String]
    }
}
