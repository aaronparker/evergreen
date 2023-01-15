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
    Describe -Name "Invoke-WebRequestWrapper" {
        Context "Ensure Invoke-WebRequestWrapper works as expected" {
            It "Returns data from a URL" {
                $params = @{
                    ContentType          = "text/html"
                    ErrorAction          = "SilentlyContinue"
                    #Headers
                    #Raw
                    #ReturnObject = "Content"
                    Method               = "Default"
                    SkipCertificateCheck = $True
                    SslProtocol          = "Tls12"
                    UserAgent            = [Microsoft.PowerShell.Commands.PSUserAgent]::Safari
                    Uri                  = "https://github.com"
                }
                Invoke-WebRequestWrapper @params | Should -BeOfType [System.String]
            }

            It "Should throw with an invalid URL" {
                { Invoke-WebRequestWrapper -Uri "https://nonsense.git" -WarningAction "SilentlyIgnore" } | Should -Throw
            }

            It "Should throw with an invalid proxy server " {
                Set-ProxyEnv -Proxy "test.local"
                { Invoke-WebRequestWrapper -Uri "https://example.com" -WarningAction "SilentlyIgnore" } | Should -Throw
                Remove-ProxyEnv
            }
        }
    }
}
