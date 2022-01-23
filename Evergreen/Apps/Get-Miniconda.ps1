Function Get-Miniconda {
    <#
        .SYNOPSIS
            Get the current version and download URL for Miniconda.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Construct the Miniconda repo uri
    $Uri = $res.Get.Update.Uri -replace "#replace", $res.Get.Update.ReplaceFileList

    # Query the repo to get the full list of files
    $updateFeed = Invoke-RestMethodWrapper -Uri $Uri

    If ($Null -ne $updateFeed) {

        # Grab the Windows files
        $FileNames = $updateFeed.PSObject.Properties.name -match $res.Get.MatchFileTypes

        # Grab all the version numbers
        try {
            $AllVersions = [RegEx]::Matches($FileNames, $res.Get.MatchVersion) | Select-Object -ExpandProperty "Value" -Unique
        }
        catch {
            Throw "$($MyInvocation.MyCommand): Failed to extract version numbers from $uri"
        }

        # Grab latest version number
        $Version = ($AllVersions | Sort-Object { [System.Version]$_ } -Descending) | Select-Object -First 1
        Write-Verbose -Message "$($MyInvocation.MyCommand): Latest version: $Version."

        # Grab latest Windows files
        $LatestReleases = $FileNames -match $Version

        # We need to rebase the timestamps from unix time, so need the Unix Epoch
        $UnixEpoch = ([System.DateTime] '1970-01-01Z').ToUniversalTime()

        # Build the output object for each release
        ForEach ($Release in $LatestReleases) {
            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Architecture = Get-Architecture $Release
                Date         = $UnixEpoch.AddSeconds($updateFeed.$Release.mtime)
                Size         = $updateFeed.$Release.size
                MD5          = $updateFeed.$Release.md5
                Sha256       = $updateFeed.$Release.sha256
                URI          = $res.Get.Update.Uri -replace "#replace", $release
            }
            Write-Output -InputObject $PSObject
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): unable to retrieve content from $Uri."
    }
}