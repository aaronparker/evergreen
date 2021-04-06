<#
    .SYNOPSIS
        Public Pester function tests.
#>
[OutputType()]
param ()

# Set variables
If (Test-Path "env:APPVEYOR_BUILD_FOLDER") {
    # AppVeyor Testing
    $projectRoot = Resolve-Path -Path $env:APPVEYOR_BUILD_FOLDER
    $module = $env:Module
}
Else {
    # Local Testing 
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
    $module = Split-Path -Path $projectRoot -Leaf
}
$moduleParent = Join-Path -Path $projectRoot -ChildPath $module
$manifestPath = Join-Path -Path $moduleParent -ChildPath "$module.psd1"
$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
$WarningPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

# Import module
Write-Host ""
Write-Host "Importing module: $manifestPath." -ForegroundColor Cyan
Import-Module $manifestPath -Force


BeforeDiscovery {
    # Get the module commands
    $Applications = Find-EvergreenApp | Select-Object -ExpandProperty Name

    # Get details for Microsoft Edge
    $Installers = Get-EvergreenApp -Name "MicrosoftEdge" | Where-Object { $_.Channel -eq "Stable" }
}

Describe -Tag "Get" -Name "Get-EvergreenApp <application>" -ForEach $Applications {
    BeforeAll {
        # Renaming the automatic $_ variable to $application to make it easier to work with
        $application = $_
        $Output = Get-EvergreenApp -Name $application

        # RegEx
        $MatchUrl = "(\s*\[+?\s*(\!?)\s*([a-z]*)\s*\|?\s*([a-z0-9\.\-_]*)\s*\]+?)?\s*([^\s]+)\s*"
        $MatchVersions = "(\d+(\.\d+){1,4}).*|^[0-9]{4}$|insider|Latest|Unknown|Preview|Any|jdk*"
    }

    Context "Validate 'Get-EvergreenApp works with: <application>." {
        It "<application>: should return something" {
            ($Output | Measure-Object).Count | Should -BeGreaterThan 0
        }

        It "<application>: should return the expected output type" {
            $Output | Should -BeOfType "PSCustomObject"
        }

        # Test that output with Version property includes numbers and "." only
        It "<application>: should have a valid version number" {
            If ([System.Boolean]($Output[0].PSObject.Properties.name -match "Version")) {
                ForEach ($object in $Output) {
                    If ($object.Version.Length -gt 0) {
                        $object.Version | Should -Match $MatchVersions
                    }
                }
            }
            Else {
                Write-Host -ForegroundColor Yellow "`t<application> does not have a Version property."
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

Describe -Tag "Find" -Name "Find-EvergreenApp" {
    Context "Validate Find-EvergreenApp works" {

        # Test that the function returns OK
        It "Should not Throw" {
            { Find-EvergreenApp } | Should -Not -Throw
        }

        # Test that the function returns something
        It "Should returns an object" {
            $Applications = Find-EvergreenApp
            ($Applications | Measure-Object).Count | Should -BeGreaterThan 0
        }
    }

    Context "Validate Find-EvergreenApp fails gracefully" {
        It "Should Throw with invalid app" {
            { Find-EvergreenApp -Name "NonExistentApplication" } | Should -Throw
        }
    }
}

Describe -Tag "Save" -Name "Save-EvergreenApp" -ForEach $Installers {
    BeforeAll {
        # Renaming the automatic $_ variable to $application to make it easier to work with
        $installer = $_

        # Create download path
        If ($env:Temp) {
            $Path = Join-Path -Path $env:Temp -ChildPath "Downloads"
        }
        else {
            $Path = Join-Path -Path $env:TMPDIR -ChildPath "Downloads"
        }
        New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $Null
    }

    # Test that Save-EvergreenApp accepts the object and saves the file
    Context "Validate Save-EvergreenApp works with <installer>." {
        It "Save-EvergreenApp should not Throw" {
            { $File = $installer | Save-EvergreenApp -Path $Path } | Should -Not -Throw
        }

        # Test that the file downloaded into the path: "$Path/Stable/Enterprise/<version>/x64/MicrosoftEdgeEnterpriseX64.msi"
        It "Should save in the right path" {
            $File = [System.IO.Path]::Combine($Path, $installer.Channel, $installer.Release, $installer.Version, $installer.Architecture, $(Split-Path -Path $installer.URI -Leaf))
            Test-Path -Path $File -PathType Leaf | Should -Be $True
        }
    }
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

Write-Host ""
