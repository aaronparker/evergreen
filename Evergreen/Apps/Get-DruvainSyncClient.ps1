function Get-DruvainSyncClient {
    <#
        .NOTES
            Site: https://stealthpuppy.com
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

    # Get download release details from the API
    $params = @{
        Uri         = $res.Get.Download.Uri
        ContentType = $res.Get.Download.ContentType
    }
    $DownloadFeed = Invoke-EvergreenRestMethod @params

    if ($null -ne $DownloadFeed) {
        try {
            # Sort the download feed for Windows, and the latest version number
            $LatestVersion = $DownloadFeed | Where-Object { $_.title -eq "Windows" } | `
                Select-Object -ExpandProperty "supportedVersions" | `
                ForEach-Object { [System.Version]$_ } | `
                Sort-Object -Descending | Select-Object -First 1
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $($LatestVersion.ToString())"

            # Find the latest release object using the version number
            $LatestRelease = $DownloadFeed | Where-Object { $_.title -eq "Windows" -and $LatestVersion.ToString() -in $_.supportedVersions } | `
                Where-Object { $_.installerDetails.version -eq $LatestVersion.ToString() }
        }
        catch {
            throw $_
        }

        # Output the object to the pipeline
        foreach ($Release in $LatestRelease) {

            # Filter the platform based on the release notes
            switch -Regex ($Release.cloudopsNotes) {
                ".*GOVCloud.*" { $Platform = "GOVCloud"; break }
                default { $Platform = "Cloud" }
            }

            # Build the output object
            $PSObject = [PSCustomObject] @{
                Version          = $Release.installerDetails[0].version
                InstallerVersion = $Release.installerDetails[0].installerVersion
                CloudPlatform    = $Platform
                Md5sum           = $Release.installerDetails[0].md5sum
                Type             = Get-FileType -File $Release.installerDetails[0].downloadURL
                URI              = $Release.installerDetails[0].downloadURL
            }
            Write-Output -InputObject $PSObject
        }
    }
}
