<#
    .SYNOPSIS
        Public Pester function tests.
#>
[OutputType()]
Param()

# RegEx
$matchUrl = "(\s*\[+?\s*(\!?)\s*([a-z]*)\s*\|?\s*([a-z0-9\.\-_]*)\s*\]+?)?\s*([^\s]+)\s*"

Describe -Tag "AppVeyor" -Name "Test" {
    $commands = Get-Command -Module Evergreen
    ForEach ($command in $commands) {
            
        Context "Validate $($command.Name)" {
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
                    It "$($command.Name): [$($object.URI)] is a valid URL" {
                        $object.URI | Should -Match $matchUrl
                    }
                }
            }
            Else {
                Write-Host -ForegroundColor Yellow "`t$($command.Name) does not have a URI property."
            }
        }
    }
}
