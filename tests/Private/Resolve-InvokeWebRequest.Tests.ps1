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
            InModuleScope Evergreen {
                $params = @{
                    Uri                = "https://aka.ms"
                    UserAgent          = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
                    MaximumRedirection = 0
                }
                Resolve-InvokeWebRequest @params | Should -BeOfType [System.String]
            }
        }
    }
}

Describe -Name "Save-File" {
    Context "Ensure Save-File works as expected" {
        It "Returns a string if the file is downloaded" {
            InModuleScope Evergreen {
                $Uri = "https://raw.githubusercontent.com/aaronparker/evergreen/main/Evergreen/Evergreen.json"
                (Save-File -Uri $Uri) | Should -BeOfType [System.IO.FileInfo]
            }
        }
    }
}
