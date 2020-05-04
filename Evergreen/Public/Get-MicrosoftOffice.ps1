Function Get-MicrosoftOffice {
    <#
        .SYNOPSIS
            Returns the latest Microsoft Office version number and download.

        .DESCRIPTION
            Returns the latest Microsoft Office version number and download.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-MicrosoftOffice

            Description:
            Returns the latest Microsoft Office version number and download.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # For each Office channel
    ForEach ($channel in $res.Get.Channels.GetEnumerator()) {

        # Get latest version Microsoft Office versions from the Office API
        $iwcParams = @{
            Uri         = "$($res.Get.Uri)$($res.Get.Channels[$channel.Key])"
            ContentType = $res.Get.ContentType
        }
        $Content = Invoke-WebContent @iwcParams
        $Json = $Content | ConvertFrom-Json

        # Build and array of the latest release and download URLs
        $PSObject = [PSCustomObject] @{
            Version = $Json.AvailableBuild
            Date    = ConvertTo-DateTime -DateTime $Json.TimestampUtc -Pattern $res.Get.DateTime
            Channel = $channel.Name
            URI     = $res.Get.DownloadUri
        }
        Write-Output -InputObject $PSObject
    }
}
