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

Describe -Name "Resolve-InvokeWebRequest" {
    Context "Ensure Resolve-InvokeWebRequest works as expected" {
        It "Returns data from a URL" {
            InModuleScope -ModuleName "Evergreen" {
                $params = @{
                    Uri                = "https://aka.ms"
                    UserAgent          = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
                    MaximumRedirection = 0
                }
                Resolve-InvokeWebRequest @params | Should -BeOfType [System.String]
            }
        }

        It "Should throws with an invalid URL" {
            Resolve-InvokeWebRequest -Uri "https://nonsense.git" | Should -Throw
        }
    }
}
