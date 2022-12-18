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
        [System.IO.FileInfo] $Path,

        [Parameter(Mandatory = $False, Position = 1)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $False, Position = 2)]
        [System.Management.Automation.PSCredential]
        $ProxyCredential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        $params = @{}
        if ($PSBoundParameters.ContainsKey("Proxy")) {
            $params.Proxy = $Proxy
        }
        if ($PSBoundParameters.ContainsKey("ProxyCredential")) {
            $params.ProxyCredential = $ProxyCredential
        }
    }

    process {

        if (Test-Path -Path $Path -PathType "Container") {
            $LibraryFile = $(Join-Path -Path $Path -ChildPath "EvergreenLibrary.json")

            if (Test-Path -Path $LibraryFile) {
                Write-Verbose -Message "Library exists: $LibraryFile."
                try {
                    $Library = Get-Content -Path $LibraryFile | ConvertFrom-Json
                }
                catch {
                    Write-Error -Message "Encountered an error reading library $LibraryFile"
                    throw $_
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
                        throw $_
                    }

                    # Gather the application version information from Get-EvergreenApp
                    $App = Get-EvergreenApp -Name $Application.EvergreenApp @params | Where-Object $WhereBlock

                    # If something returned, add to the library
                    if ($Null -ne $App) {
                        Write-Verbose -Message "Download count for $($Application.EvergreenApp): $($App.Count)."

                        # Save the installers to the library
                        if ($PSCmdlet.ShouldProcess("Downloading $($App.Count) application installers.", "Save-EvergreenApp")) {
                            $Saved = $App | Save-EvergreenApp -Path $AppPath @params
                        }

                        # Add the saved installer path to the application version information
                        if ($Saved.Count -gt 1) {
                            for ($i = 0; $i -lt $App.Count; $i++) {
                                $Item = $Saved | Where-Object { $_.FullName -match $App[$i].Version }
                                Write-Verbose -Message "Add path to object: $($Item.FullName)"
                                $App[$i] | Add-Member -MemberType "NoteProperty" -Name "Path" -Value $Item.FullName
                            }
                        }
                        else {
                            Write-Verbose -Message "Add path to object: $($Saved.FullName)"
                            $App | Add-Member -MemberType "NoteProperty" -Name "Path" -Value $Saved.FullName
                        }

                        # Write the application version information to the library
                        Export-EvergreenApp -InputObject $App -Path $(Join-Path -Path $AppPath -ChildPath "$($Application.Name).json")
                    }
                }
            }
            else {
                throw [System.IO.FileNotFoundException] "$Path is not an Evergreen Library. Cannot find EvergreenLibrary.json. Create a library with New-EvergreenLibrary."
            }
        }
        else {
            throw [System.IO.DirectoryNotFoundException] "Cannot use path $Path because it does not exist or is not a directory."
        }
    }

    end {}
}
