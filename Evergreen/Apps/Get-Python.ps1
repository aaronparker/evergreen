Function Get-Python {
    <#
        .SYNOPSIS
            Get the current version and download URL for Python Software Foundation version of Python.

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

    # Query the python API to get the list of versions
    $updateFeed = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri

    if ($null -ne $updateFeed) {

        # Get latest versions from update feed (PSF typically maintain a version of Python2 and a version of Python 3)
        #$LatestVersions = $updateFeed | Where-Object { $_.is_latest -eq "True" }
        $LatestVersions = $updateFeed | Where-Object { $_.is_published -eq "True" -and $_.pre_release -ne $true -and $_.name -notlike "*rc*"}

        # For each minor version of python, select only the latest version
        # The "Name" field contains a string like "Python 3.13.1" or "Python 3.13.1rc1"
        # 3.1.1, 3.1.2, 3.1.3, etc should all be grouped together as "3.1" and have the latest version selected
        $LatestVersions = $LatestVersions | Group-Object { $_.name -replace '\.\d+$' } | ForEach-Object { $_.Group | Sort-Object -Property name -Descending | Select-Object -First 1 }

        if ($null -ne $LatestVersions) {
            foreach ($PythonVersion in $LatestVersions) {

                # Extract release ID from resource uri
                try {
                    $releaseToQuery = [RegEx]::Match($PythonVersion.resource_uri, $res.Get.Update.MatchRelease).Captures.Groups[0].Value
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Found ReleaseID: [$releaseToQuery]."
                }
                catch {
                    throw "$($MyInvocation.MyCommand): could not find release ID in resource uri."
                }

                # Query the python API to get the list of download uris
                $params = @{
                    Uri  = $res.Get.Download.Uri
                    Body = @{
                        os      = "1"
                        release = $releaseToQuery
                    }
                }
                $downloadFeed = Invoke-EvergreenRestMethod @params

                # Filter the download feed to obtain the installers; Match this release with entries from the download feed
                $windowsDownloadFeed = $downloadFeed | Where-Object { $_.url -match $res.Get.Download.MatchFileTypes }
                Write-Verbose -Message "$($MyInvocation.MyCommand): Processing $($PythonVersion.name)"
                $WindowsRelease = $windowsDownloadFeed | Where-Object { $_.release -eq $PythonVersion.resource_uri }

                if ($null -ne $WindowsRelease) {

                    # Each release typically has an x86 and x64 installer, so we need to loop through the results
                    foreach ($UniqueFile in $WindowsRelease) {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Found: $($UniqueFile.name)."

                        # Extract exact version (eg 3.9.6) from URI
                        try {
                            $FileVersion = [RegEx]::Match($UniqueFile.url, $res.Get.Download.MatchVersion).Captures.Groups[0].Value
                            Write-Verbose -Message "$($MyInvocation.MyCommand): Found version:  [$FileVersion]."
                        }
                        catch {
                            throw "$($MyInvocation.MyCommand): Failed to find exact version from: $($UniqueFile.url)"
                        }

                        # Construct the output; Return the custom object to the pipeline
                        $PSObject = [PSCustomObject] @{
                            Version      = $FileVersion
                            Release      = $FileVersion.split('.')[0..1] -join '.' # Get the major.minor version
                            Python       = $PythonVersion.version
                            md5          = $UniqueFile.md5_sum
                            Size         = $UniqueFile.filesize
                            Date         = ConvertTo-DateTime -DateTime $PythonVersion.release_date -Pattern $res.Get.Download.DatePattern
                            Type         = ($UniqueFile.url).Split('.')[-1]
                            Architecture = Get-Architecture $UniqueFile.name
                            URI          = $UniqueFile.url
                        }
                        Write-Output -InputObject $PSObject
                    }
                }
            }
        }
    }
}
