function Get-MestrelabMnova {
    <#
        .SYNOPSIS
            Get the current version and download URL for Mestrelab MNova.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "Product name is a plural")]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Query the repo to get the full list of files
    $UpdateFeed = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri
    if ($UpdateFeed -is [System.Xml.XmlDocument]) {

        # Grab the Windows files
        $WindowsReleases = $UpdateFeed.Products.Product | Where-Object { $_.Platform -match $res.Get.Platform }

        # Build the output object for each release
        foreach ($Release in $WindowsReleases) {

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = $Release.Version
                Revision     = $Release.Revision
                Architecture = Get-Architecture $Release.Architecture
                URI          = $Release.URL
            }
            Write-Output -InputObject $PSObject
        }
    }
    else {
        throw "$($MyInvocation.MyCommand): Xml document not returned from $($res.Get.Update.Uri)."
    }
}
