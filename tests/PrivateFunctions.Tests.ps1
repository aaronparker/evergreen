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

Describe -Name "Get-FileType" {
    Context "Ensure file type is returned" {
        It "Given a file path string it returns the right file type" {
            InModuleScope Evergreen {
                Get-FileType -File "test.txt" | Should -Be "txt"
            }
        }

        It "Given an file path string without an extension it returns null" {
            InModuleScope Evergreen {
                Get-FileType -File "testtxt" | Should -BeNullOrEmpty
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

Describe -Name "Get-FunctionResource" {
    Context "Ensure function resources are returned" {
        It "Given a valid app it returns valid data" {
            InModuleScope Evergreen {
                Get-FunctionResource -AppName "MicrosoftEdge" | Should -BeOfType [System.Object]
            }
        }

        It "Given an invalid application, it throws" {
            InModuleScope Evergreen {
                { Get-FunctionResource -AppName "DoesNotExist" } | Should -Throw
            }
        }
    }
}

Describe -Name "Get-ModuleResource" {
    Context "Ensure module resources are returned" {
        It "Returns the module resource" {
            InModuleScope Evergreen {
                Get-ModuleResource | Should -BeOfType [System.Object]
            }
        }

        It "Given an invalid path, it throws" {
            InModuleScope Evergreen {
                { Get-ModuleResource -Path "C:\Temp\test.txt" } | Should -Throw
            }
        }

        It "Returns an object with the expected properties" {
            InModuleScope Evergreen {
                (Get-ModuleResource).Uri.Project | Should -Not -BeNullOrEmpty
                (Get-ModuleResource).Uri.Docs | Should -Not -BeNullOrEmpty
                (Get-ModuleResource).Uri.Issues | Should -Not -BeNullOrEmpty
                (Get-ModuleResource).Uri.Info | Should -Not -BeNullOrEmpty
            }
        }
    }
}

# Add tests for these functions:
Describe -Name "Invoke-RestMethodWrapper" {
    Context "Ensure Invoke-RestMethodWrapper works as expected" {
        It "Returns data from a proper URL" {
            InModuleScope Evergreen {
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
        }
    }
}

Describe -Name "Invoke-SystemNetRequest" {
    Context "Ensure Invoke-SystemNetRequest works as expected" {
        It "Returns data from a URL" {
            InModuleScope Evergreen {
                $params = @{
                    Uri                = "https://github.com"
                    MaximumRedirection = 1
                }
                Invoke-SystemNetRequest @params | Should -BeOfType [System.String]
            }
        }
    }
}

Describe -Name "Resolve-SystemNetWebRequest" {
    Context "Ensure Resolve-SystemNetWebRequest works as expected" {
        It "Returns data from a URL" {
            InModuleScope Evergreen {
                $params = @{
                    Uri                = "https://github.com"
                    MaximumRedirection = 1
                }
                (Resolve-SystemNetWebRequest @params).ResponseUri | Should -BeOfType [System.Uri]
            }
        }
    }
}

Describe -Name "Invoke-WebRequestWrapper" {
    Context "Ensure Invoke-WebRequestWrapper works as expected" {
        It "Returns data from a URL" {
            InModuleScope Evergreen {
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
    }
}

Describe -Name "New-EvergreenPath" {
    Context "Ensure New-EvergreenPath works as expected" {
        It "Does not throw when creating a directory" {
            InModuleScope Evergreen {
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
                { New-EvergreenPath -InputObject $Object -Path "$Env:Temp" } | Should -Not -Throw
            }
        }

        It "Returns a string when creating a directory" {
            InModuleScope Evergreen {
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
                (New-EvergreenPath -InputObject $Object -Path "$Env:Temp") | Should -BeOfType [System.String]
            }
        }
    }
}

Describe -Name "Resolve-DnsNameWrapper" {
    Context "Ensure Resolve-DnsNameWrapper works as expected" {
        It "Returns DNS records OK" {
            InModuleScope Evergreen {
                $params = @{
                    Name = "github.com"
                    Type = "TXT"
                }
                Resolve-DnsNameWrapper @params | Should -BeOfType [System.String]
            }
        }
    }
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
