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
        Where-Object { $_.Name -notmatch $AppsToSkip } | `
        Sort-Object { Get-Random } | Select-Object -ExpandProperty "Name"
}

BeforeAll {
}

Describe -Tag "Export" -Name "Export-EvergreenManifest" -ForEach $Applications {
    BeforeAll {
        # Renaming the automatic $_ variable to $application to make it easier to work with
        $application = $_
    }

    Context "Validate Export-EvergreenManifest works with: <application>." {

        # Test that Export-EvergreenManifest does not throw
        It "'Export-EvergreenManifest -Name <application>' should not Throw" {
            { Export-EvergreenManifest -Name $application } | Should -Not -Throw
        }

        # The manifest should have the right properties
        It "<application> has expected properties" {
            $Manifest = Export-EvergreenManifest -Name $application
            $Manifest.Name.Length | Should -BeGreaterThan 0
            $Manifest.Source.Length | Should -BeGreaterThan 0
            $Manifest.Get.Length | Should -BeGreaterThan 0
            $Manifest.Install.Length | Should -BeGreaterThan 0
        }
    }
}

Describe -Tag "Export" -Name "Export-EvergreenManifest fail tests" {
    Context "Validate Export-EvergreenManifest fails gracefully" {
        It "Should Throw with invalid app" {
            { Export-EvergreenManifest -Name "NonExistentApplication" } | Should -Throw
        }
    }
}
