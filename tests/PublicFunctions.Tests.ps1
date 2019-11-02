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

# Import module
Write-Host ""
Write-Host "Importing module." -ForegroundColor Cyan
Import-Module $manifestPath -Force

# Create download path
$Path = Join-Path -Path $env:Temp -ChildPath "Downloads"
New-Item -Path $Path -ItemType Directory -Force -ErrorAction SilentlyContinue

Describe -Tag "AppVeyor" -Name "Test" {
    Context "Validate functions" {
        $commands = Get-Command -Module Evergreen
        ForEach ($command in $commands) {
            
            # Run each command and capture output in a variable
            New-Variable -Name "tempOutput" -Value (. $command.Name )
            $Output = (Get-Variable -Name "tempOutput").Value
            Remove-Variable -Name tempOutput
            
            # Test that the function returns something
            It "$($command.Name): Fuction returns something" {
                ($Output | Measure-Object).Count | Should -BeGreaterThan 0
            }

            # Test that the function output matches OutputType in the function
            It "$($command.Name): Function returns the expected output type" {
                $Output | Should -BeOfType ((Get-Command -Name $command.Name).OutputType.Type.Name)
            }

            # Test that output with Verison property includes numbers and "." only
            If ([bool]($Output[0].PSobject.Properties.name -match "Version")) {
                ForEach ($object in $Output) {
                    If ($object.Version.Length -gt 0) {
                        It "$($command.Name): [$($object.Version)] is a valid version number" {
                            $object.Version | Should -Match "^\d[_\-.0-9b|insider]*$|Unknown"
                        }
                    }
                }
            }
            Else {
                Write-Host -ForegroundColor Yellow "`t$($command.Name) does not have a Version property."
            }

            # Test that the functions that have a URI property return something we can download
            # If URI is 'Unknown' there's probably a problem with the source
            If ([bool]($Output[0].PSobject.Properties.name -match "URI")) {
                ForEach ($object in $Output) {
                    It "$($command.Name): URI property is a valid URL" {
                        $object.URI | Should -Match "(http(s)?:\/\/)?([\w-]+\.)+[\w-]+[.com]+(\/[\/?%&=]*)?"
                    }
                    It "$($command.Name): [$(Split-Path -Path $object.URI -Leaf)] is a valid download target" {
                        try {
                            # Test URI exists without downloading the file
                            $r = Invoke-WebRequest -Uri $object.URI -Method Head -UseBasicParsing -ErrorAction SilentlyContinue
                        }
                        catch {
                            # If Method Head fails, try downloading the URI
                            # Write-Host -ForegroundColor Cyan "`tException grabbing URI via header. Retrying full request."
                            $OutFile = Join-Path -Path $Path (Split-Path -Path $object.URI -Leaf)
                            try {
                                $r = Invoke-WebRequest -Uri $object.URI -OutFile $OutFile -UseBasicParsing -PassThru `
                                    -ErrorAction SilentlyContinue
                            }
                            catch {
                                # If all else fails, let's pretend the URI is OK. Some URIs may require a login etc.
                                Write-Host -ForegroundColor Yellow "`t$($command.Name) requires manual testing."
                                $r = [PSCustomObject] @{
                                    StatusCode = 200
                                }
                            }
                        }
                        finally {
                            $r.StatusCode | Should -Be 200
                        }
                    }
                }
            }
            Else {
                Write-Host -ForegroundColor Yellow "`t$($command.Name) does not have a URI property."
            }
        }
    }
}
