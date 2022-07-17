<#
    .SYNOPSIS
        Private Pester function tests.
#>
[OutputType()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
param ()

BeforeDiscovery {
}

Describe -Name "Test-PSCore" {
    Context "Tests whether we are running on PowerShell Core" {
        It "Returns True if running Windows PowerShell" {
            InModuleScope Evergreen {
                $Version = "6.0.0"
                If (($PSVersionTable.PSVersion -ge [version]::Parse($Version)) -and ($PSVersionTable.PSEdition -eq "Core")) {
                    Test-PSCore | Should -Be $True
                }
            }
        }
    }
    Context "Tests whether we are running on Windows PowerShell" {
        It "Returns False if running Windows PowerShell" {
            InModuleScope Evergreen {
                $Version = "6.0.0"
                If (($PSVersionTable.PSVersion -lt [version]::Parse($Version)) -and ($PSVersionTable.PSEdition -eq "Desktop")) {
                    Test-PSCore | Should -Be $False
                }
            }
        }
    }
}

Describe -Name "Get-Architecture" {
    Context "It returns expected output" {
        It "Returns x64 given an x64 URL" {
            InModuleScope Evergreen {
                $64bitUrl = "https://statics.teams.cdn.office.net/production-windows-x64/1.3.00.34662/Teams_windows_x64.msi"
                Get-Architecture -String $64bitUrl | Should -Be "x64"
            }
        }

        It "Returns x86 given an x86 URL" {
            InModuleScope Evergreen {
                $32bitUrl = "http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/2001320074/AcroRdrDCUpd2001320074.msp"
                Get-Architecture -String $32bitUrl | Should -Be "x86"
            }
        }

        It "Returns x86 given a string that won't match anything" {
            InModuleScope Evergreen {
                Get-Architecture -String "the quick brown fox" | Should -Be "x86"
            }
        }
    }
}

Describe -Name "Get-GitHubRepoRelease" {
    Context "It correctly returns an object" {
        It "Does not Throw" {
            InModuleScope Evergreen {

                # Params for Get-GitHubRepoRelease
                $gitHubParams = @{
                    Uri          = "https://api.github.com/repos/atom/atom/releases/latest"
                    MatchVersion = "(\d+(\.\d+){1,4}).*"
                }

                { Get-GitHubRepoRelease @gitHubParams } | Should -Not -Throw
            }
        }

        <#
        It "Returns the expected properties" {
            InModuleScope Evergreen {

                # Params for Get-GitHubRepoRelease
                $gitHubParams = @{
                    Uri          = "https://api.github.com/repos/atom/atom/releases/latest"
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
        #>
    }
}

Describe -Name "ConvertTo-DateTime" {
    Context "Format and return a datetime string" {
        It "Correctly formats the provided datetime" {
            InModuleScope Evergreen {
                (ConvertTo-DateTime -DateTime "2000/14/2" -Pattern "yyyy/d/M").Split("/")[-1] | Should -Be "2000"
            }
        }
    }
}

Describe -Name "ConvertTo-Hashtable" {
    Context "Test conversion to hashtable" {
        It "Converts a PSObject into a hashtable" {
            InModuleScope Evergreen {
                $ps = [PSCustomObject]@{ Name = "Name1"; Address = "Address1" }
                $object = $ps | ConvertTo-Hashtable
                $object | Should -BeOfType "Hashtable"
            }
        }
    }
}

Describe -Name "Get-Platform" {
    Context "Ensure platform is returned" {
        It "Given a platform string it returns the right platform" {
            InModuleScope Evergreen {
                Get-Platform -String "osx" | Should -Be "macOS"
            }
        }

        It "Given a string that won't match, returns Windows" {
            InModuleScope Evergreen {
                Get-Platform -String "Neque porro quisquam est qui dolorem" | Should -Be "Windows"
            }
        }
    }
}

Describe -Name "Get-SourceForgeRepoRelease" {
    Context "Validate function returns expected object" {
        It "Returns an object with expected properties" {
            InModuleScope Evergreen {
                $Uri = "https://sourceforge.net/projects/sevenzip/best_release.json"
                $Download = @{
                    "Folder"         = "7-Zip"
                    "Feed"           = "https://sourceforge.net/projects/sevenzip/rss?path="
                    "XPath"          = "//item"
                    "FilterProperty" = "link"
                    "ContentType"    = "application/rss+xml; charset=utf-8"
                    "Uri"            = "https://nchc.dl.sourceforge.net/project/sevenzip"
                }
                $params = @{
                    Uri          = $Uri
                    Download     = $Download
                    MatchVersion = "(\d+(\.\d+){1,3})"
                }
                $object = Get-SourceForgeRepoRelease @params
                $object.Version.Length | Should -BeGreaterThan 0
                $object.Architecture.Length | Should -BeGreaterThan 0
                $object.Type.Length | Should -BeGreaterThan 0
                $object.URI.Length | Should -BeGreaterThan 0
            }
        }
    }
}

