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

# Get the module commands
$Applications = Find-EvergreenApp | Select-Object -ExpandProperty Name

Describe -Tag "General" -Name "Properties" {
    ForEach ($application in $Applications) {

        Context "Validate $($application) properties" {

            # Run each command and capture output in a variable
            New-Variable -Name "tempOutput" -Value (Get-EvergreenApp -Name $application)
            $Output = (Get-Variable -Name "tempOutput").Value
            Remove-Variable -Name tempOutput
            
            # Test that the function returns something
            It "$($application): Function returns something" {
                ($Output | Measure-Object).Count | Should -BeGreaterThan 0
            }

            # Test that the function output matches OutputType in the function
            It "$($application): Function returns the expected output type" {
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

Write-Host ""
