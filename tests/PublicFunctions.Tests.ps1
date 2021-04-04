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

# Import module
Write-Host ""
Write-Host "Importing module." -ForegroundColor Cyan
Import-Module $manifestPath -Force

# Create download path
$Path = Join-Path -Path $env:Temp -ChildPath "Downloads"
New-Item -Path $Path -ItemType Directory -Force -ErrorAction "SilentlyContinue"

# RegEx
$MatchUrl = "(\s*\[+?\s*(\!?)\s*([a-z]*)\s*\|?\s*([a-z0-9\.\-_]*)\s*\]+?)?\s*([^\s]+)\s*"
$MatchVersions = "(\d+(\.\d+){1,4}).*|^[0-9]{4}$|insider|Latest|Unknown|Preview|Any|jdk*"

Describe -Tag "Find" -Name "Find-EvergreenApp" {

    Context "Validate Find-EvergreenApp" {

        # Test that the function returns OK
        It "Should not Throw" {
            { $Applications = Find-EvergreenApp } | Should Not Throw
        }

        It "Should Throw with invalid app" {
            { Find-EvergreenApp -Name "NonExistentApplication" } | Should Throw
        }

        # Test that the function returns something
        It "Should returns an object" {
            $Applications = Find-EvergreenApp
            ($Applications | Measure-Object).Count | Should -BeGreaterThan 0
        }
    }
}

Describe -Tag "Get" -Name "Get-EvergreenApp" {

    # Get the module commands
    $Applications = Find-EvergreenApp | Select-Object -ExpandProperty Name

    ForEach ($application in $Applications) {
        Context "Validate 'Get-EvergreenApp -Name $($application)'" {

            # Run each command and capture output in a variable
            New-Variable -Name "tempOutput" -Value (Get-EvergreenApp -Name $application)
            $Output = (Get-Variable -Name "tempOutput").Value
            Remove-Variable -Name tempOutput
            
            # Test that the function returns something
            It "$($application): should return something" {
                ($Output | Measure-Object).Count | Should -BeGreaterThan 0
            }

            # Test that the function output matches OutputType in the function
            It "$($application): should return the expected output type" {
                $Output | Should -BeOfType "PSCustomObject"
            }

            # Test that output with Version property includes numbers and "." only
            If ([System.Boolean]($Output[0].PSObject.Properties.name -match "Version")) {
                ForEach ($object in $Output) {
                    If ($object.Version.Length -gt 0) {
                        It "$($application): [$($object.Version)] should be a valid version number" {
                            $object.Version | Should -Match $MatchVersions
                        }
                    }
                }
            }
            Else {
                Write-Host -ForegroundColor Yellow "`t$($application) does not have a Version property."
            }

            # Test that the functions that have a URI property return something we can download
            # If URI is 'Unknown' there's probably a problem with the source
            If ([System.Boolean]($Output[0].PSObject.Properties.name -match "URI")) {
                ForEach ($object in $Output) {
                    It "$($application): URI property is a valid URL" {
                        $object.URI | Should -Match $MatchUrl
                    }
                }
            }
            Else {
                Write-Host -ForegroundColor "Yellow" "`t$($application) does not have a URI property."
            }
        }
    }

    Context "Validate 'Get-EvergreenApp fails" {

        It "Should Throw with invalid app" {
            { Get-EvergreenApp -Name "NonExistentApplication" } | Should Throw
        }
    }
}

Describe -Tag "Save" -Name "Save-EvergreenApp" {

    Context "Validate Save-EvergreenApp" {

        # Get details for Microsoft Edge
        $Installers = Get-EvergreenApp -Name "MicrosoftEdge" | Where-Object { $_.Channel -eq "Stable" }
        ForEach ($installer in $Installers) {

            # Test that Save-EvergreenApp accepts the object and saves the file
            It "Save-EvergreenApp should not Throw" {
                { $File = $installer | Save-EvergreenApp -Path $Path } | Should Not Throw
            }

            # Test that the file downloaded into the path: "$Path/Stable/Enterprise/<version>/x64/MicrosoftEdgeEnterpriseX64.msi"
            $File = [System.IO.Path]::Combine($Path, $installer.Channel, $installer.Release, $installer.Version, $installer.Architecture, $(Split-Path -Path $installer.URI -Leaf))
            It "Should save in the right path" {
                Test-Path -Path $File -PathType Leaf | Should Be $True
            }
        }
    }
}

Describe -Tag "Export" -Name "Export-EvergreenManifest" {

    # Get the list of applications
    $Applications = Find-EvergreenApp | Select-Object -ExpandProperty Name

    Context "Validate Export-EvergreenManifest" {
        
        # Test that Export-EvergreenManifest does not throw
        ForEach ($Application in $Applications) {
            It "'Export-EvergreenManifest -Name $Application' should not Throw" {
                { Export-EvergreenManifest -Name $Application } | Should Not Throw
            }
        }

        # The manifest should have the right properties
        ForEach ($Application in $Applications) {
            $Manifest = Export-EvergreenManifest -Name $Application

            It "$Application has expected properties" {
                $Manifest.Name.Length | Should -BeGreaterThan 0
                $Manifest.Source.Length | Should -BeGreaterThan 0
                $Manifest.Get.Length | Should -BeGreaterThan 0
                $Manifest.Install.Length | Should -BeGreaterThan 0
            }
        }
    }

    Context "Validate Export-EvergreenManifest fails" {

        It "Should Throw with invalid app" {
            { Export-EvergreenManifest -Name "NonExistentApplication" } | Should Throw
        }
    }
}

Write-Host ""
