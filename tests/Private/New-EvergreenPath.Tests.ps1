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

Describe -Name "New-EvergreenPath" {
    BeforeAll {
        if ($env:Temp) {
            $Path = $env:Temp
        }
        elseif ($env:TMPDIR) {
            $Path = $env:TMPDIR
        }
        elseif ($env:RUNNER_TEMP) {
            $Path = $env:RUNNER_TEMP
        }
    }

    Context "Ensure New-EvergreenPath works as expected" {
        It "Does not throw when creating a directory" {
            InModuleScope -ModuleName "Evergreen" {
                $Object = [PSCustomObject] @{
                    "Product"      = "App"
                    "Track"        = "Current"
                    "Channel"      = "Stable"
                    "Release"      = "Prod"
                    "Ring"         = "Prod"
                    "Version"      = "1.0.0"
                    "Language"     = "English"
                    "Architecture" = "x64"
                }
                { New-EvergreenPath -InputObject $Object -Path "$Path" } | Should -Not -Throw
            }
        }

        It "Returns a string when creating a directory" {
            InModuleScope -ModuleName "Evergreen" {
                $Object = [PSCustomObject] @{
                    "Product"      = "App"
                    "Track"        = "Current"
                    "Channel"      = "Stable"
                    "Release"      = "Prod"
                    "Ring"         = "Prod"
                    "Version"      = "1.0.0"
                    "Language"     = "English"
                    "Architecture" = "x64"
                }
                (New-EvergreenPath -InputObject $Object -Path "$Path") | Should -BeOfType [System.String]
            }
        }
    }
}
