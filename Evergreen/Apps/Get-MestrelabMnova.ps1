Function Get-MestrelabMnova {
    <#
        .SYNOPSIS
            Get the current version and download URL for Mestrelab MNova.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Query the repo to get the full list of files
    $updateFeed = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri

    If ($Null -ne $updateFeed) {

        # Grab the Windows files
        Try {
            $windowsReleases = $updateFeed.Products.Product | Where-Object { $_.Platform -match $res.Get.Platform }
        }
        Catch {
            Throw "$($MyInvocation.MyCommand): Failed to extract windows versions"
        }

        # Build the output object for each release
        ForEach ($Release in $windowsReleases) {
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
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): unable to retrieve content from $($res.Get.Update.Uri)."
    }
}
