<#
    .SYNOPSIS
        Public Pester function tests.
#>
[OutputType()]
Param ()

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
# $modulePath = Join-Path -Path $moduleParent -ChildPath "$module.psm1"

# Import module
Write-Host ""
Write-Host "Importing module." -ForegroundColor Cyan
Import-Module $manifestPath -Force

# Read module resource strings for testing
#. "$moduleParent\Private\Test-PSCore.ps1"
#. "$moduleParent\Private\Get-ModuleResource.ps1"
#. "$moduleParent\Private\ConvertTo-Hashtable.ps1"
# $ResourceStrings = Get-ModuleResource -Path "$moduleParent\Evergreen.json"

# Create a downloads target folder
$Path = Join-Path -Path "$env:Temp" -ChildPath "Downloads"
New-Item -Path $Path -ItemType Directory -Force -ErrorAction SilentlyContinue

Describe -Tag "AppVeyor" -Name "Test" {
    Context "Validate" {
        $commands = Get-Command -Module Evergreen
        ForEach ($command in $commands) {
            New-Variable -Name "tempOutput" -Value (. $command.Name)
            $Output = (Get-Variable -Name "tempOutput").Value
            Remove-Variable -Name tempOutput
            It "$($command.Name): Fuction returns something" {
                ($Output | Measure-Object).Count | Should -BeGreaterThan 0
            }
            It "$($command.Name): Function returns the expected output type" {
                $Output | Should -BeOfType ((Get-Command -Name $command.Name).OutputType.Type.Name)
            }
            Push-Location -Path $Path
            It "$($command.Name): Function returns correct URI" {
                ForEach ($object in $Output) {
                    $r = Invoke-WebRequest -Uri $object.URI -Method Head -UseBasicParsing
                    $r.StatusCode | Should -Be 200
                }
            }
            Pop-Location
        }
    }
}
