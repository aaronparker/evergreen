<#
    .SYNOPSIS
        Public Pester function tests.
#>
[OutputType()]
Param()

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

Describe -Tag "Find" -Name "Properties" {

    Context "Validate Find-EvergreenApp" {

        # Test that the function returns OK
        It "Find-EvergreenApp should not Throw" {
            $Applications = Find-EvergreenApp | Should Not Throw
        }

        # Test that the function returns something
        It "Find-EvergreenApp returns something" {
            $Applications = Find-EvergreenApp
            ($Applications | Measure-Object).Count | Should -BeGreaterThan 0
        }
    }
}

Describe -Tag "Get" -Name "Properties" {

    # Get the module commands
    $Applications = Find-EvergreenApp | Select-Object -ExpandProperty Name

    ForEach ($application in $Applications) {

        Context "Validate 'Get-EvergreenApp -Name $($application)' properties" {

            # Run each command and capture output in a variable
            New-Variable -Name "tempOutput" -Value (Get-EvergreenApp -Name $application)
            $Output = (Get-Variable -Name "tempOutput").Value
            Remove-Variable -Name tempOutput
            
            # Test that the function returns something
            It "$($application): returns something" {
                ($Output | Measure-Object).Count | Should -BeGreaterThan 0
            }

            # Test that the function output matches OutputType in the function
            It "$($application): returns the expected output type" {
                $Output | Should -BeOfType "PSCustomObject"
            }

            # Test that output with Version property includes numbers and "." only
            If ([bool]($Output[0].PSObject.Properties.name -match "Version")) {
                ForEach ($object in $Output) {
                    If ($object.Version.Length -gt 0) {
                        It "$($application): [$($object.Version)] is a valid version number" {
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
            If ([bool]($Output[0].PSObject.Properties.name -match "URI")) {
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
}

Describe -Tag "Save" -Name "Targets" {

    Context "Validate Save-EvergreenApp" {

        # Get details for Microsoft Edge
        $Installers = Get-EvergreenApp -Name "MicrosoftEdge" | Where-Object { $_.Channel -eq "Stable" }
        ForEach ($installer in $Installers) {

            # Test that Save-EvergreenApp accepts the object and saves the file
            It "Save-EvergreenApp should not Throw" {
                { $installer | Save-EvergreenApp -Path $Path } | Should Not Throw
            }

            # Test that the file downloaded into the path: "$Path/Stable/Enterprise/89.0.774.68/x64/MicrosoftEdgeEnterpriseX64.msi"
            It "Should save in the right path" {

                $File = [System.IO.Path]::Combine($Path, $install.Channel, $install.Release, $install.Architecture, $(Split-Path -Path $installer.URI -Leaf))
                Test-Path -Path $File | Should Be $True
            }
        }
    }
}

Write-Host ""
