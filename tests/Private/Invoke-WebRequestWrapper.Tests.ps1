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

Describe -Name "Invoke-WebRequestWrapper" {
    Context "Ensure Invoke-WebRequestWrapper works as expected" {
        It "Returns data from a URL" {
            InModuleScope -ModuleName "Evergreen" {
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
        }

        It "Should throws with an invalid URL" {
            Invoke-WebRequestWrapper -Uri "https://nonsense.git" | Should -Throw
        }
    }
}
