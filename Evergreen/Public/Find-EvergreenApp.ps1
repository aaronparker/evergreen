Function Find-EvergreenApp {
    <#
        .SYNOPSIS
            Outputs a table with the applications that Evergreen supports.

        .DESCRIPTION
            Outputs a table from the internal application functions and manifests to list the applications supported by Evergreen. 

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
            Alias: Espero que este módulo no sea fea. ;)
        
        .LINK
            https://stealthpuppy.com/Evergreen/find.html

        .PARAMETER Name
            The application name to return details for. This can be the entire application name or a portion thereof.

        .EXAMPLE
            Find-EvergreenApp

            Description:
            Returns a table with the all of the currently supported applications.

        .EXAMPLE
            Find-EvergreenApp -Name "Edge"

            Description:
            Returns a table with the all of the currently supported applications that match "Edge".

        .EXAMPLE
            Find-EvergreenApp -Name "Microsoft"

            Description:
            Returns a table with the all of the currently supported applications that match "Microsoft".
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpURI = "https://stealthpuppy.com/Evergreen/find.html")]
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

    Begin {

        # Get the application manifests from the module/Manifests folder
        try {
            $params = @{
                Path        = Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "Manifests"
                Filter      = "*.json"
                ErrorAction = "SilentlyContinue"
            }
            Write-Verbose -Message "$($MyInvocation.MyCommand): Search path for application manifests: $($params.Path)."
            $Manifests = Get-ChildItem @params
        }
        catch {
            Throw $_
        }
    }

    Process {
        # Filter the included manifests based on the -Name parameter
        If ($PSBoundParameters.ContainsKey('Name')) {
            try {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Filter for: $Name."
                $Manifests = $Manifests | Where-Object { $_.Name -match $Name }
            }
            catch {
                Throw $_
            }
        }

        # Build an object from the manifest details and file name and output to the pipeline
        If ($Null -ne $Manifests) {
            ForEach ($manifest in $Manifests) {
                try {
                    $Json = Get-Content -Path $manifest.FullName | ConvertFrom-Json
                }
                catch {
                    Throw $_
                }
                $PSObject = [PSCustomObject] @{
                    Name        = [System.IO.Path]::GetFileNameWithoutExtension($manifest.Name)
                    Application = $Json.Name
                    Link        = $Json.Source
                }
                Write-Output -InputObject $PSObject
            }
        }
        Else {
            Write-Warning -Message "Omit the -Name parameter to return the full list of supported applications."
            Write-Warning -Message "Documentation on how to contribute a new application to the Evergreen project can be found at: $($script:resourceStrings.Uri.Documentation)."
            Throw "Cannot find application: $Name."
        }
    }

    End {
        Remove-Variable -Name "PSObject", "Json", "Manifests"
    }
}
