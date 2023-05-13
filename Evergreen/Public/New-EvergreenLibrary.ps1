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
        $LibraryJsonTemplate = [System.IO.Path]::Combine($MyInvocation.MyCommand.Module.ModuleBase, "EvergreenLibraryTemplate.json")
        $Library = Get-Content -Path $LibraryJsonTemplate  -ErrorAction "Stop" -Verbose:$VerbosePreference | ConvertFrom-Json -ErrorAction "Stop"
    }

    process {
        #region Test $Path and attempt to create it if it doesn't exist
        if (Test-Path -Path $Path -PathType "Container") {
            Write-Verbose -Message "Path exists: $Path."
        }
        else {
            $params = @{
                Path        = $Path
                ItemType    = "Container"
                ErrorAction = "Stop"
                Verbose     = $VerbosePreference
            }
            Write-Verbose -Message "Path does not exist: $Path."
            Write-Verbose -Message "Create: $Path."
            New-Item @params | Out-Null
        }
        #endregion

        $LibraryFile = $(Join-Path -Path $Path -ChildPath "EvergreenLibrary.json")
        if (Test-Path -Path $LibraryFile) {
            Write-Verbose -Message "Library exists: $Path."
        }
        else {
            $Library.Name = $Name
            $Library | ConvertTo-Json -ErrorAction "Stop" | Out-File -FilePath $LibraryFile -Encoding "Utf8" -NoNewline -ErrorAction "Stop" -Verbose:$VerbosePreference
        }
    }

    end {}
}
