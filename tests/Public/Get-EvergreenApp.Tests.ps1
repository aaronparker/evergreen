<#
    .SYNOPSIS
        Public Pester function tests.
#>
[OutputType()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
    # Get the supported applications
    # Sort randomly so that we get test various GitHub applications when we have API request limits
    #$AppsToSkip = "FileZilla|Tableau|MicrosoftWvdRemoteDesktop|MicrosoftWvdRtcService|MicrosoftWvdBootloader|MicrosoftWvdMultimediaRedirection|MicrosoftWvdInfraAgent|PaintDotNet|Mozilla"
    $AppsToSkip = "MicrosoftWvdMultimediaRedirection|MicrosoftWvdInfraAgent|MestrelabMnova|MozillaFirefox|AWSCLI"
    $Applications = Find-EvergreenApp | `
        Where-Object { $_.Name -notmatch $AppsToSkip } | `
        Sort-Object { Get-Random } | Select-Object -ExpandProperty "Name"
}

BeforeAll {
}

Describe -Tag "Get" -Name "Get-EvergreenApp works with supported applications" {
    Context "Validate Get-EvergreenApp works with: <application>." -ForEach $Applications {
        BeforeAll {
            # Renaming the automatic $_ variable to $application to make it easier to work with
            $application = $_
            $Output = Get-EvergreenApp -Name $application -WarningAction "SilentlyContinue"

            # RegEx
            $MatchUrl = "(\s*\[+?\s*(\!?)\s*([a-z]*)\s*\|?\s*([a-z0-9\.\-_]*)\s*\]+?)?\s*([^\s]+)\s*"
            $MatchVersions = "(\d+(\.\d+){1,4}).*|(\d+)|^[0-9]{4}$|insider|Latest|Unknown|Preview|Any|jdk*|RateLimited"
        }

        It "Output from <application>: should not be null" -ForEach $Output {
            $_ | Should -Not -BeNullOrEmpty
        }

        It "Output from <application>: should return the expected output type" -ForEach $Output {
            $_ | Should -BeOfType "PSCustomObject"
        }

        It "Get-EvergreenApp -Name <application> should return a count of 1 or more" -ForEach $Output {
            ($_ | Measure-Object).Count | Should -BeGreaterThan 0
        }

        # Test that the output has a Version property and that property is a string
        It "Output for <application> should have a Version property that is a string" -ForEach $Output {
            $_.Version | Should -BeOfType [System.String]
        }

        # Test that output with Version property is valid
        It "Output for <application> should have a valid version number" -ForEach $Output {
            $_.Version | Should -Match $MatchVersions
        }

        # Test that the output has a URI property and that property is a string
        It "Output for <application> should have a URI property that is a string" -ForEach $Output {
            $_.URI | Should -BeOfType [System.String]
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
