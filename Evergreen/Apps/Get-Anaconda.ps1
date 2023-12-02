function Get-Anaconda {
    <#
        .SYNOPSIS
            Get the current version and download URL for Anaconda.

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

    # Query the repo to get the full list of files
    $Uri = $res.Get.Update.Uri -replace "#replace", $res.Get.Update.ReplaceFileList
    $UpdateFeed = Invoke-EvergreenRestMethod -Uri $Uri
    if ($null -ne $UpdateFeed) {

        # Grab the Windows files
        $FileNames = $UpdateFeed.PSObject.Properties.name -match $res.Get.MatchFileTypes

        try {
            # Grab all the version numbers; Grab latest version number
            $AllVersions = [RegEx]::Matches($FileNames, $res.Get.MatchVersion) | Select-Object -ExpandProperty "Value" -Unique
            $Version = $AllVersions | Sort-Object { [System.Version]$_ } -Descending | Select-Object -First 1
            Write-Verbose -Message "$($MyInvocation.MyCommand): Latest version: $Version."
        }
        catch {
            throw "$($MyInvocation.MyCommand): Failed to extract version numbers from $uri. $($_.Exception.Message)"
        }

        # Grab latest Windows files
        $LatestReleases = ($FileNames -match $Version)[-1]

        # We need to rebase the timestamps from unix time, so need the Unix Epoch
        $UnixEpoch = ([System.DateTime] '1970-01-01Z').ToUniversalTime()

        # Build the output object for each release
        foreach ($Release in $LatestReleases) {

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Architecture = Get-Architecture -String $Release
                Date         = $UnixEpoch.AddSeconds($UpdateFeed.$Release.mtime)
                Size         = $UpdateFeed.$Release.size
                MD5          = $UpdateFeed.$Release.md5
                Sha256       = $UpdateFeed.$Release.sha256
                URI          = $res.Get.Update.Uri -replace "#replace", $release
            }
            Write-Output -InputObject $PSObject
        }
    }
}
