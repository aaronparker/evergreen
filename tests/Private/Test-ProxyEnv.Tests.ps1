<#
    .SYNOPSIS
        Private Pester function tests.
#>
[OutputType()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

BeforeDiscovery {
}

BeforeAll {
}

Describe -Name "Test-ProxyEnv" {
    BeforeAll {
        InModuleScope -ModuleName "Evergreen" {
            Set-ProxyEnv -Proxy "proxyserver"
        }
    }

    Context "Tests that Test-ProxyEnv returns true when testing proxy environment" {
        It "Returns True if proxy server is set" {
            InModuleScope -ModuleName "Evergreen" {
                Test-ProxyEnv | Should -BeTrue
            }
        }

        It "Returns False if proxy credentials are not set" {
            InModuleScope -ModuleName "Evergreen" {
                Test-ProxyEnv -Creds | Should -BeFalse
            }
        }
    }

    AfterAll {
        Remove-Variable -Name "EvergreenProxy" -ErrorAction "SilentlyContinue"
    }
}
