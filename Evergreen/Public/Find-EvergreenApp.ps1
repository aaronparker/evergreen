Function Find-EvergreenApp {
    <#
        .EXTERNALHELP Evergreen-help.xml
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpURI = "https://stealthpuppy.com/evergreen/find/")]
    [Alias("fea")]
    param (
        [Parameter(
            Mandatory = $False,
            Position = 0,
            ValueFromPipeline,
            HelpMessage = "Specify an a string to search from the list of supported applications.")]
        [ValidateNotNull()]
        [System.String] $Name
    )

    begin {
        #region Get the per-application manifests from the Evergreen/Manifests folder
        try {
            $params = @{
                Path        = Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "Manifests"
                Filter      = "*.json"
                ErrorAction = "SilentlyContinue"
            }
            Write-Verbose -Message "Search path for application manifests: $($params.Path)."
            $Manifests = Get-ChildItem @params
        }
        catch {
            throw $_
        }
        #endregion
    }

    process {
        if ($PSBoundParameters.ContainsKey('Name')) {
            try {
                # If the -Name parameter is specified, filter the included manifests for that application
                Write-Verbose -Message "Filter for: $Name."
                $Manifests = $Manifests | Where-Object { $_.Name -match $Name }
            }
            catch {
                throw $_
            }
            if ($Null -eq $Manifests) {
                Write-Warning -Message "Omit the -Name parameter to return the full list of supported applications."
                Write-Warning -Message "Documentation on how to contribute a new application to the Evergreen project can be found at: $($script:resourceStrings.Uri.Docs)."
                throw "Cannot find application: $Name."
            }
        }

        #region Output details from the manifest/s
        if ($Manifests.Count -gt 0) {
            foreach ($manifest in $Manifests) {
                try {
                    # Read the JSON manifest and convert to an object
                    $Json = Get-Content -Path $manifest.FullName | ConvertFrom-Json
                }
                catch {
                    throw $_
                }

                if ($Null -ne $Json) {
                    # Build an object from the manifest details and file name and output to the pipeline
                    $PSObject = [PSCustomObject] @{
                        Name        = [System.IO.Path]::GetFileNameWithoutExtension($manifest.Name)
                        Application = $Json.Name
                        Link        = $Json.Source
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
        else {
            Write-Warning -Message "Omit the -Name parameter to return the full list of supported applications."
            Write-Warning -Message "Documentation on how to contribute a new application to the Evergreen project can be found at: $($script:resourceStrings.Uri.Docs)."
            throw "Failed to return application manifests."
        }
        #endregion
    }

    end {
        # Remove these variables for next run
        Remove-Variable -Name "PSObject", "Json", "Manifests" -ErrorAction "SilentlyContinue"
    }
}
