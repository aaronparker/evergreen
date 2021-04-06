<#
    .SYNOPSIS
        Private Pester function tests.
#>
[OutputType()]
param ()

Describe 'Test-PSCore' {
    Context "Tests whether we are running on PowerShell Core" {
        It "Returns True if running Windows PowerShell" {
            InModuleScope Evergreen {

                $Version = '6.0.0'
                If (($PSVersionTable.PSVersion -ge [version]::Parse($Version)) -and ($PSVersionTable.PSEdition -eq "Core")) {
                    Test-PSCore | Should -Be $True
                }
            }
        }
    }
    Context "Tests whether we are running on Windows PowerShell" {
        It "Returns False if running Windows PowerShell" {
            InModuleScope Evergreen {

                $Version = '6.0.0'
                If (($PSVersionTable.PSVersion -lt [version]::Parse($Version)) -and ($PSVersionTable.PSEdition -eq "Desktop")) {
                    Test-PSCore | Should -Be $False
                }
            }
        }
    }
}

Describe "Get-Architecture" {
    Context "It returns expected output" {
        It "Returns x64" {
            InModuleScope Evergreen {

                $64bitUrl = "https://statics.teams.cdn.office.net/production-windows-x64/1.3.00.34662/Teams_windows_x64.msi"
                Get-Architecture -String $64bitUrl | Should -Be "x64"
            }
        }

        It "Returns x86" {
            InModuleScope Evergreen {

                $32bitUrl = "http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/2001320074/AcroRdrDCUpd2001320074.msp"
                Get-Architecture -String $32bitUrl | Should -Be "x86"
            }
        }
    }
}

Describe "Get-GitHubRepoRelease" {
    Context "It correctly returns an object" {
        It "Does not Throw" {
            InModuleScope Evergreen {

                $Uri = "https://api.github.com/repos/atom/atom/releases/latest"
                $gitHubParams = @{
                    Uri          = $Uri
                    MatchVersion = "(\d+(\.\d+){1,4}).*"
                }

                { Get-GitHubRepoRelease @gitHubParams } | Should -Not -Throw
            }
        }

        It "Returns the expected properties" {
            InModuleScope Evergreen {

                $Uri = "https://api.github.com/repos/atom/atom/releases/latest"
                $gitHubParams = @{
                    Uri          = $Uri
                    MatchVersion = "(\d+(\.\d+){1,4}).*"
                }
                $result = Get-GitHubRepoRelease @gitHubParams

                $result.Version.Length | Should -BeGreaterThan 0
                $result.Platform.Length | Should -BeGreaterThan 0
                $result.Architecture.Length | Should -BeGreaterThan 0
                $result.Type.Length | Should -BeGreaterThan 0
                $result.Date.Length | Should -BeGreaterThan 0
                $result.Size.Length | Should -BeGreaterThan 0
                $result.URI.Length | Should -BeGreaterThan 0
            }
        }
    }
}
