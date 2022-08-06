function Get-EvergreenLibrary {
    <#
        .EXTERNALHELP Evergreen-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipelineByPropertyName,
            HelpMessage = "Specify the path to the library.",
            ParameterSetName = "Path")]
        [ValidateNotNull()]
        [System.IO.FileInfo] $Path
    )

    begin {
    }

    process {
        if (Test-Path -Path $Path -PathType "Container") {
            $LibraryFile = $(Join-Path -Path $Path -ChildPath "EvergreenLibrary.json")

            if (Test-Path -Path $LibraryFile) {
                Write-Verbose -Message "Library exists: $LibraryFile."

                try {
                    # Read the library file
                    Write-Verbose -Message "Read: $LibraryFile."
                    $Library = Get-Content -Path $LibraryFile | ConvertFrom-Json
                }
                catch {
                    throw "Encountered an error reading library $LibraryFile with: $($_.Exception.Message)"
                }

                if ($Null -ne $Library) {

                    # Build the output object
                    $Output = [PSCustomObject] @{
                        "Library"   = $Library
                        "Inventory" = (New-Object -TypeName "System.Collections.ArrayList")
                    }

                    foreach ($Application in $Library.Applications) {

                        # Add details for the application to the output object
                        $AppPath = $(Join-Path -Path $Path -ChildPath $Application.Name)
                        if (Test-Path -Path $AppPath) {

                            $AppManifest = $(Join-Path -Path $AppPath -ChildPath "$($Application.Name).json")
                            if (Test-Path -Path $AppManifest) {

                                try {
                                    Write-Verbose -Message "Read: $AppManifest."
                                    $Versions = Get-Content -Path $AppManifest | ConvertFrom-Json
                                }
                                catch {
                                    Write-Warning -Message "Encountered an error reading $AppManifest with: $($_.Exception.Message)"
                                }

                                try {
                                    # Add details for this application
                                    $App = [PSCustomObject] @{
                                        ApplicationName = $Application.Name
                                        Versions        = $Versions
                                    }
                                    $Output.Inventory.Add($App) | Out-Null
                                }
                                catch {
                                    Write-Warning -Message "Encountered an error adding details for $($Application.Name) with: $($_.Exception.Message)"
                                }

                            }
                            else {
                                Write-Warning -Message "Unable to find $AppManifest. Update the library with Invoke-EvergreenLibraryUpdate."
                            }
                        }
                        else {
                            Write-Warning -Message "Unable to find $AppPath. Update the library with Invoke-EvergreenLibraryUpdate."
                        }
                    }

                    # Output the object to the pipeline
                    Write-Output -InputObject $Output
                }
            }
            else {
                throw "$Path is not an Evergreen Library. Cannot find EvergreenLibrary.json. Create a library with New-EvergreenLibrary."
            }
        }
        else {
            throw "Cannot find path $Path because it does not exist."
        }
    }

    end {}
}
