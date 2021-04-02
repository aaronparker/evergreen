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
            https://github.com/aaronparker/Evergreen

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
    [CmdletBinding(SupportsShouldProcess = $False, HelpURI = "https://stealthpuppy.com/Evergreen/")]
    [Alias("gea")]
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNull()]
        [System.String] $Name
    )

    # Build a path to the application function
    try {
        $Function = [System.IO.Path]::Combine($MyInvocation.MyCommand.Module.ModuleBase, "Apps", "Get-$Name.ps1")
    }
    catch {
        Throw "Failed to combine: $($MyInvocation.MyCommand.Module.ModuleBase), Apps, Get-$Name.ps1"
    }

    # Test that the function exists and run it to return output
    Write-Verbose -Message "$($MyInvocation.MyCommand): Test path: $Function."
    If (Test-Path -Path $Function -PathType "Leaf" -ErrorAction "SilentlyContinue") {
        try {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Call: $Function."
            $Output = . Get-$Name
        }
        catch {
            Throw $_
        }
        If ($Output) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Output result from: $Function."
            Write-Output -InputObject $Output
        }
    }
    Else {
        Write-Error -Message "Cannot find application: $Name. Please list valid application names with Find-EvergreenApp."
        Write-Error -Message "Documentation on how to contribute a new application to the Evergreen project can be found at: $($script:resourceStrings.Uri.Documentation)."
    }
}
