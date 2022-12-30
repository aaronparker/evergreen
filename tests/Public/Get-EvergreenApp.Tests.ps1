<#
    .SYNOPSIS
        Public Pester function tests.
#>
[OutputType()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification="This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification="Outputs to log host.")]
param ()

BeforeDiscovery {
    # Get the supported applications
    # Sort randomly so that we get test various GitHub applications when we have API request limits
    $AppsToSkip = "FileZilla|Tableau|MicrosoftWvdRemoteDesktop|MicrosoftWvdRtcService|MicrosoftWvdBootloader|MicrosoftWvdMultimediaRedirection|MicrosoftWvdInfraAgent|PaintDotNet|Mozilla"
    $Applications = Find-EvergreenApp | `
        #Where-Object { $_.Name -notmatch $AppsToSkip } | `
        Sort-Object { Get-Random } | Select-Object -ExpandProperty "Name"
}

BeforeAll {
}

Describe -Tag "Get" -Name "Get-EvergreenApp <application>" -ForEach $Applications {
    BeforeAll {
        # Renaming the automatic $_ variable to $application to make it easier to work with
        $application = $_
        $Output = Get-EvergreenApp -Name $application

        # RegEx
        $MatchUrl = "(\s*\[+?\s*(\!?)\s*([a-z]*)\s*\|?\s*([a-z0-9\.\-_]*)\s*\]+?)?\s*([^\s]+)\s*"
        $MatchVersions = "(\d+(\.\d+){1,4}).*|(\d+)|^[0-9]{4}$|insider|Latest|Unknown|Preview|Any|jdk*|RateLimited"
    }

    Context "Validate Get-EvergreenApp works with: <application>." {
        It "<application>: should return something" {
            ($Output | Measure-Object).Count | Should -BeGreaterThan 0
        }

        It "<application>: should return the expected output type" {
            $Output | Should -BeOfType "PSCustomObject"
        }

        # Test that the output has a Version property and that property is a string
        It "<application>: should have a Version property that is a string" {
            if ([System.Boolean]($Output[0].PSObject.Properties.name -match "Version")) {
                ForEach ($object in $Output) {
                    $object.Version | Should -BeOfType [System.String]
                }
            }
            else {
                Write-Host -ForegroundColor Yellow "`t<application> does not have a Version property."
            }
        }

        # Test that output with Version property is valid
        It "<application>: should have a valid version number" {
            if ([System.Boolean]($Output[0].PSObject.Properties.name -match "Version")) {
                foreach ($object in $Output) {
                    if ($object.Version.Length -gt 0) {
                        $object.Version | Should -Match $MatchVersions
                    }
                }
            }
            else {
                Write-Host -ForegroundColor Yellow "`t<application> does not have a Version property."
            }
        }

        # Test that the output has a URI property and that property is a string
        It "<application>: should have a URI property that is a string" {
            foreach ($object in $Output) {
                $object.URI | Should -BeOfType [System.String]
            }
        }
    }
}

Describe -Tag "Get" -Name "Get-EvergreenApp fail tests" {
    Context "Validate 'Get-EvergreenApp fails gracefully" {
        It "Should Throw with invalid app" {
            { Get-EvergreenApp -Name "NonExistentApplication" } | Should -Throw
        }
    }
}
