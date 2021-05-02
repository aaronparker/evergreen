Function Get-EvergreenApp {
    <#
        .SYNOPSIS
            Returns the latest version and download link/s for an application supported by the module.

        .DESCRIPTION
            Queries the internal application functions and manifests included in the module to find the latest version and download link/s for the specified application.

            The output from this function can be passed to Where-Object to filter for a specific download based on properties including processor architecture, file type or other properties.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://stealthpuppy.com/Evergreen/use.html

        .PARAMETER Name
            The application name to return details for. The list of supported applications can be found with Find-EvergreenApp.

        .EXAMPLE
            Get-EvergreenApp -Name "MicrosoftEdge"

            Description:
            Returns the current version and download URLs for Microsoft Edge.

        .EXAMPLE
            Get-EvergreenApp -Name "MicrosoftEdge" | Where-Object { $_.Architecture -eq "x64" -and $_.Channel -eq "Stable" }

            Description:
            Returns the current version and download URL for the Stable channel of the 64-bit release of Microsoft Edge.

        .EXAMPLE
            (Get-EvergreenApp -Name "MicrosoftOneDrive" | Where-Object { $_.Type -eq "Exe" -and $_.Ring -eq "Production" }) | `
                Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } | Select-Object -First 1

            Description:
            Returns the current version and download URL for the Production ring of Microsoft OneDrive and selects the latest version in the event that more that one release is returned.

        .EXAMPLE
            Get-EvergreenApp -Name "AdobeAcrobatReaderDC" | Where-Object { $_.Language -eq "English" -and $_.Architecture -eq "x86" }

            Description:
            Returns the current version and download URL that matches the English language, 32-bit release of Adobe Acrobat Reader DC.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpURI = "https://stealthpuppy.com/Evergreen/use.html")]
    [Alias("gea")]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = "Specify an application name. Use Find-EvergreenApp to list supported applications.")]
        [ValidateNotNull()]
        [System.String] $Name
    )

    Begin {}

    Process {
        
        try {
            # Build a path to the application function
            # This will build a path like: Evergreen/Apps/Get-TeamViewer.ps1
            $Function = [System.IO.Path]::Combine($MyInvocation.MyCommand.Module.ModuleBase, "Apps", "Get-$Name.ps1")
        }
        catch {
            Throw "Failed to combine: $($MyInvocation.MyCommand.Module.ModuleBase), Apps, Get-$Name.ps1"
        }

        #region Test that the function exists and run it to return output
        If (Test-Path -Path $Function -PathType "Leaf" -ErrorAction "SilentlyContinue") {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Function exists: $Function."

            try {
                # Dot source the function so that we can use it
                # Import function here rather than at module import to reduce IO and memory footprint as the module grows
                # This also allows us to add an application manifest and function without having to re-load the module
                Write-Verbose -Message "$($MyInvocation.MyCommand): Dot sourcing: $Function."
                . $Function
            }
            catch {
                Throw "$($MyInvocation.MyCommand): Failed to load function: $Function."
            }

            try {
                # Run the function to grab the application details; pass the per-app manifest to the app function
                # Application manifests are located under Evergreen/Manifests 
                Write-Verbose -Message "$($MyInvocation.MyCommand): Call: Get-$Name."
                $Output = Get-$Name -res (Get-FunctionResource -AppName $Name)
            }
            catch {
                Throw "Internal application function: $Function, failed with: $($_.Exception.Message)"
            }

            # If we get an object, return it to the pipeline
            If ($Output) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Output result from: $Function."
                Write-Output -InputObject $Output
            }
            Else {
                Throw "$($MyInvocation.MyCommand): Failed to capture output from: Get-$Name."
            }
        }
        Else {
            Write-Warning -Message "Please list valid application names with Find-EvergreenApp."
            Write-Warning -Message "Documentation on how to contribute a new application to the Evergreen project can be found at: $($script:resourceStrings.Uri.Documentation)."
            Throw "Cannot find application script at: $Function."
        }
        #endregion
    }

    End {
        # Remove these variables for next run
        Remove-Variable -Name "Output", "Function"
    }
}
