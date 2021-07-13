Function Get-PSFPython {
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
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Filter
    )
      
    # Query the python API to get the list of versions
    $updateFeed = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri
    
    If ($Null -ne $updateFeed) {
             
        # Get latest versions from update feed (PSF typically maintain a version of Python2 and a version of Python 3)
        $LatestVersions = $updateFeed |  Where-Object { $_.is_latest -eq "True" }

        If ($Null -ne $LatestVersions) {

            ForEach ($PythonVersion in $LatestVersions) {

                # Extract release ID from resource uri
                try {
                    $releaseToQuery = [RegEx]::Match($PythonVersion.resource_uri, $res.Get.Update.MatchRelease).Captures.Groups[0].Value
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Found ReleaseID: [$releaseToQuery]."
                }
                Catch {
                    Throw "$($MyInvocation.MyCommand): could not find release ID in resource uri."
                }

                # Query the python API to get the list of download uris
                $iwcParams = @{
                    Uri  = $res.Get.Download.Uri
                    Body = @{ 
                        os      = "1"
                        release = $releaseToQuery 
                    }
                }

                $downloadFeed = Invoke-RestMethodWrapper @iwcParams

                # Filter the download feed to obtain the installers
                Try {
                    $windowsDownloadFeed = $downloadFeed | Where-Object { $_.url -match $res.Get.Download.MatchFileTypes }
                }
                Catch {
                    Throw "$($MyInvocation.MyCommand): could not filter download feed for executable filetypes."
                }

                Write-Verbose -Message "$($MyInvocation.MyCommand): Processing $($PythonVersion.name)"

                # Match this release with entries from the download feed
                $WindowsRelease = $windowsDownloadFeed | Where-Object { $_.release -eq $PythonVersion.resource_uri }

                If ($Null -ne $WindowsRelease) {

                    # Each release typically has an x86 and x64 installer, so we need to loop through the results
                    ForEach ($UniqueFile in $WindowsRelease) {

                        Write-Verbose -Message "$($MyInvocation.MyCommand): Found: $($UniqueFile.name)."

                        # Extract exact version (eg 3.9.6) from URI
                        Try {
                            $FileVersion = [RegEx]::Match($UniqueFile.url, $res.Get.Download.MatchVersion).Captures.Groups[0].Value
                            Write-Verbose -Message "$($MyInvocation.MyCommand): Found version:  [$FileVersion]."
                        }
                        Catch {
                            Throw "$($MyInvocation.MyCommand): Failed to find exact version from: $($UniqueFile.url)" 
                        }

                        # Construct the output; Return the custom object to the pipeline
                        $PSObject = [PSCustomObject] @{
                            Version      = $FileVersion
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
                Else {
                    Throw "$($MyInvocation.MyCommand): Failed to lookup download URI based on release $($PythonVersion.resource_uri)."      
                }
            }
        }
        Else {
            Throw "$($MyInvocation.MyCommand): Release feed didn't contain any releases marked as latest."
        }
    }
    Else {
        Throw "$($MyInvocation.MyCommand): Failed to obtain release information from json release feed."      
    }
}