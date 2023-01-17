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

InModuleScope -ModuleName "Evergreen" {
    Describe -Name "Invoke-RestMethodWrapper" {
        Context "Ensure Invoke-RestMethodWrapper works as expected" {
            It "Returns data from a proper URL" {
                $params = @{
                    ContentType          = "application/vnd.github.v3+json"
                    ErrorAction          = "SilentlyContinue"
                    Method               = "Default"
                    SkipCertificateCheck = $True
                    SslProtocol          = "Tls12"
                    UserAgent            = [Microsoft.PowerShell.Commands.PSUserAgent]::Safari
                    Uri                  = "https://api.github.com/rate_limit"
                }
                Invoke-RestMethodWrapper @params | Should -BeOfType [System.Object]
            }

            It "Should throw with an invalid URL" {
                { Invoke-RestMethodWrapper -Uri "https://nonsense.git" -WarningAction "SilentlyIgnore" } | Should -Throw
            }

            It "Should throw with an invalid proxy server " {
                Set-ProxyEnv -Proxy "test.local"
                { Invoke-RestMethodWrapper -Uri "https://example.com" -WarningAction "SilentlyIgnore" } | Should -Throw
                Remove-ProxyEnv
            }
        }
    }
}
