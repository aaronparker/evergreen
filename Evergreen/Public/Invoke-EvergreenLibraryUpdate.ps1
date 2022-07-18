function Invoke-EvergreenLibraryUpdate {
    <#
        .EXTERNALHELP Evergreen-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
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

    begin {}

    process {

        if (Test-Path -Path $Path -PathType "Container") {
            $LibraryFile = $(Join-Path -Path $Path -ChildPath "EvergreenLibrary.json")

            if (Test-Path -Path $LibraryFile) {
                Write-Verbose -Message "Library exists: $LibraryFile."
                try {
                    $Library = Get-Content -Path $LibraryFile | ConvertFrom-Json
                }
                catch {
                    throw "Encountered an reading library $LibraryFile with: $($_.Exception.Message)"
                }

                foreach ($Application in $Library.Applications) {

                    # Return the application details
                    $AppPath = $(Join-Path -Path $Path -ChildPath $Application.Name)
                    Write-Verbose -Message "Application path: $AppPath."
                    Write-Verbose -Message "Query Evergreen for: $($Application.Name)."

                    try {
                        Write-Verbose -Message "Filter: $($Application.Filter)."
                        $WhereBlock = [ScriptBlock]::Create($Application.Filter)
                    }
                    catch {
                        throw "Encountered an error creating script block with: $($_.Exception.Message)"
                    }

                    $App = Get-EvergreenApp -Name $Application.EvergreenApp | Where-Object $WhereBlock
                    Write-Verbose -Message "Download count for $($Application.EvergreenApp): $($App.Count)."

                    # If something returned, add to the library
                    if ($Null -ne $App) {

                        # Save the installers to the library
                        $Saved = $App | Save-EvergreenApp -Path $AppPath
                        $Saved | Out-Null

                        # Write the application version information to the library
                        Export-EvergreenApp -InputObject $App -Path $(Join-Path -Path $AppPath -ChildPath "$($Application.Name).json")
                    }
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
