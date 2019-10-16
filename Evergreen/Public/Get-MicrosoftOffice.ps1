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

    # Get latest version Microsoft Office versions from the Office API
    ForEach ($channel in $script:resourceStrings.Applications.MicrosoftOffice.Channels.GetEnumerator()) {

        $iwcParams = @{
            Uri         = "$($script:resourceStrings.Applications.MicrosoftOffice.Uri)$($script:resourceStrings.Applications.MicrosoftOffice.Channels[$channel.Key])"
            ContentType = $script:resourceStrings.Applications.MicrosoftOffice.ContentType
        }
        $Content = Invoke-WebContent @iwcParams
        $Json = $Content | ConvertFrom-Json

        $PSObject = [PSCustomObject] @{
            Version = $Json.AvailableBuild
            Date    = (ConvertTo-DateTime -DateTime $Json.TimestampUtc -Pattern $script:resourceStrings.Applications.MicrosoftOffice.DateTime)
            Channel = $channel.Name
            URI     = $script:resourceStrings.Applications.MicrosoftOffice.DownloadUri
        }
        Write-Output -InputObject $PSObject
    }
}