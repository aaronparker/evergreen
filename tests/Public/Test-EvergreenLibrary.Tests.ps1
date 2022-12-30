<#
    .SYNOPSIS
        Public Pester function tests.
#>
[OutputType()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
}

BeforeAll {
}

Describe -Tag "Library" -Name "Test Evergreen Library" {
    Context "Test 'New-EvergreenLibrary'" {
        It "Does not throw when creating a new new Evergreen Library" {
            { New-EvergreenLibrary -Path "$Env:Temp\EvergreenLibrary" -Name "TestLibrary" } | Should -Not -Throw
        }

        It "Creates a new Evergreen Library OK" {
            Test-Path -Path "$Env:Temp\EvergreenLibrary\EvergreenLibrary.json" | Should -BeTrue
        }

        It "Sets the library name OK" {
            (Get-Content -Path "$Env:Temp\EvergreenLibrary\EvergreenLibrary.json" | ConvertFrom-Json).Name | Should -BeExactly "TestLibrary"
        }
    }

    Context "Test 'Invoke-EvergreenLibraryUpdate'" {
        BeforeAll {
            $params = @{
                Path        = "$env:GITHUB_WORKSPACE\tests\EvergreenLibrary.json"
                Destination = "$Env:Temp\EvergreenLibrary\EvergreenLibrary.json"
                Force       = $True
                Confirm     = $False
            }
            Copy-Item @params
        }

        It "Update an Evergreen library" {
            { Invoke-EvergreenLibraryUpdate -Path "$Env:Temp\EvergreenLibrary" } | Should -Not -Throw
        }
    }

    Context "Test 'Get-EvergreenLibrary' works" {
        BeforeAll {
            $params = @{
                Path        = "$env:GITHUB_WORKSPACE\tests\EvergreenLibrary.json"
                Destination = "$Env:Temp\EvergreenLibrary\EvergreenLibrary.json"
                Force       = $True
                Confirm     = $False
            }
            Copy-Item @params
        }

        It "Returns details of the library" {
            Get-EvergreenLibrary -Path "$Env:Temp\EvergreenLibrary" | Should -BeOfType [System.Object]
        }

        It "Does not throw" {
            { Get-EvergreenLibrary -Path "$Env:Temp\EvergreenLibrary" } | Should -Not -Throw
        }
    }

    Context "Test 'Get-EvergreenLibrary' fails" {
        BeforeAll {
            $params = @{
                FilePath = "$Env:Temp\EvergreenLibrary\EvergreenLibrary.json"
                Force    = $True
                Confirm  = $False
            }
            "nonsense" | Out-File @params
        }

        It "Does throw" {
            { Get-EvergreenLibrary -Path "$Env:Temp\EvergreenLibrary" } | Should -Throw
        }
    }
}
