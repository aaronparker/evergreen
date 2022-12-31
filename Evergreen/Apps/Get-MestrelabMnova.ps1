Function Get-MestrelabMnova {
    <#
        .SYNOPSIS
            Get the current version and download URL for Mestrelab MNova.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "Product name is a plural")]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Query the repo to get the full list of files
    $updateFeed = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri
    if ($null -ne $updateFeed) {

        # Grab the Windows files
        $windowsReleases = $updateFeed.Products.Product | Where-Object { $_.Platform -match $res.Get.Platform }

        # Build the output object for each release
        foreach ($Release in $windowsReleases) {
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
}
