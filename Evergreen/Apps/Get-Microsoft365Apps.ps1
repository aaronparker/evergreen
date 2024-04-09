function Get-Microsoft365Apps {
    <#
        .SYNOPSIS
            Returns the latest Microsoft 365 Apps version number for each channel and download.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
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

    # Get the channels for the Microsoft 365 Apps
    $params = @{
        Uri         = $res.Get.Update.Channels
        ContentType = $res.Get.Update.ContentType
    }
    $Channels = Invoke-EvergreenRestMethod @params

    # Get the latest version details for the Microsoft 365 Apps
    $params = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $Updates = Invoke-EvergreenRestMethod @params

    # Walk through the channels to match versions and return details
    foreach ($Channel in $Channels) {
        $Item = $Updates | Where-Object { $_.channelId -eq $Channel.name }
        if ($Item) {

            # Find the release date for this version
            $OfficeVersion = $Item.officeVersions | Where-Object { $_.legacyVersion -eq $Item.latestVersion }

            # Build and array of the latest release and download URLs
            $PSObject = [PSCustomObject] @{
                Version        = $Item.latestVersion
                ReleaseVersion = $OfficeVersion.releaseVersion
                Channel        = $Channel.name
                Name           = $Channel.displayName
                Date           = ConvertTo-DateTime -DateTime $OfficeVersion.availabilityDate -Pattern $res.Get.Update.DateTime
                EOSDate        = ConvertTo-DateTime -DateTime $OfficeVersion.endOfSupportDate -Pattern $res.Get.Update.DateTime
                URI            = $res.Get.Download.Uri
            }
            Write-Output -InputObject $PSObject
        }
    }
}
