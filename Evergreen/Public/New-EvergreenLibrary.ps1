function New-EvergreenLibrary {
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

        [Parameter(
            Mandatory = $False,
            Position = 1,
            HelpMessage = "Specify a name for the library.",
            ParameterSetName = "Path")]
        [ValidateNotNull()]
        [System.String] $Name = "EvergreenLibrary"
    )

    begin {
        try {
            $LibraryJsonTemplate = [System.IO.Path]::Combine($MyInvocation.MyCommand.Module.ModuleBase, "EvergreenLibraryTemplate.json")
            $Library = Get-Content -Path $LibraryJsonTemplate -Verbose:$VerbosePreference | ConvertFrom-Json
        }
        catch {
            throw $_
        }
    }

    process {
        #region Test $Path and attempt to create it if it doesn't exist
        if (Test-Path -Path $Path -PathType "Container") {
            Write-Verbose -Message "Path exists: $Path."
        }
        else {
            try {
                $params = @{
                    Path        = $Path
                    ItemType    = "Container"
                    ErrorAction = "SilentlyContinue"
                    Verbose     = $VerbosePreference
                }
                Write-Verbose -Message "Path does not exist: $Path."
                Write-Verbose -Message "Create: $Path."
                New-Item @params | Out-Null
            }
            catch {
                throw "Failed to create $Path with: $($_.Exception.Message)"
            }
        }
        #endregion

        $LibraryFile = $(Join-Path -Path $Path -ChildPath "EvergreenLibrary.json")
        if (Test-Path -Path $LibraryFile) {
            Write-Verbose -Message "Library exists: $Path."
        }
        else {
            try {
                $Library.Name = $Name
                $Library | ConvertTo-Json -Depth 10 | Out-File -FilePath $LibraryFile -Encoding "Utf8" -NoNewline -Verbose:$VerbosePreference
            }
            catch {
                throw $_
            }
        }
    }

    end {}
}
