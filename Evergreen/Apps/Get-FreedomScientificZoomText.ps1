Function Get-FreedomScientificZoomText {
    <#
        .SYNOPSIS
            Get the current version and download URL for Freedom Scientific ZoomText.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # The URI feeds require a unix timestamp as a parameter
    $UnixTimestamp = [int64](([DateTime]::UtcNow) - ([DateTime]'1970-01-01Z')).TotalSeconds

    # Query the API to get the list of major versions
    $MajorVersionsURI = $res.Get.Update.Uri -replace $res.Get.Update.ReplaceTimestamp, $UnixTimestamp
    $MajorVersions = Invoke-RestMethodWrapper $MajorVersionsURI

    # Get latest version
    $LatestVersion = $MajorVersions | Sort-Object -Property { [Int] $_.MajorVersion } -Descending | Select-Object -First 1
    Write-Verbose "$($MyInvocation.MyCommand): Latest version is $LatestVersion"

    # Query the API to get the list of releases
    $DownloadFeedURI = ($res.Get.Download.Uri -replace $res.Get.Download.ReplaceMajorVersion, $LatestVersion.MajorVersion ) -replace $res.Get.Update.ReplaceTimestamp, $UnixTimestamp
    Write-Verbose "$($MyInvocation.MyCommand): Built $DownloadFeedURI"
    $downloadFeed = Invoke-RestMethodWrapper $DownloadFeedURI

    If ($Null -ne $downloadFeed) {

        ForEach ($Release in $downloadFeed) {

            # Extract the version information
            try {
                $Version = [RegEx]::Match($Release.FileName, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
            }
            catch {
                Throw "$($MyInvocation.MyCommand): Failed to extract the version information from the uri."
            }

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version = $Version
                Date    = ConvertTo-DateTime -DateTime $Release.ReleaseDate -Pattern $res.Get.Download.DatePattern
                URI     = $Release.InstallerLocationHTTP
            }
            Write-Output -InputObject $PSObject
        }
    }
    Else {
        Throw "$($MyInvocation.MyCommand): Failed to obtain latest releases for version $($LatestVersion.ProductMajor)."
    }
}
