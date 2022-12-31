Function Get-TechSmithSnagit {
    <#
        .SYNOPSIS
            Get the current version and download URL for Snagit.

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

    # Query the TechSmith update URI to get the list of versions
    $updateFeed = Invoke-RestMethodWrapper -Uri $res.Get.Update.UpdateFeed
    if ($null -ne $updateFeed) {

        # Grab latest version, sort by descending version number
        $Latest = $updateFeed | `
            Sort-Object -Property @{ Expression = { [System.Version]"$($_.Major).$($_.Minor).$($_.Maintenance)" }; Descending = $true } | `
            Select-Object -First 1

        if ($null -ne $Latest) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Latest is $Latest"

            # Build uri so we can query the api to find the file corresponding to this version
            $latestUpdateFeedUri = $res.Get.Update.Uri -replace $res.Get.Update.ReplaceVersion, $Latest.VersionID
            $latestUpdateFeed = (Invoke-RestMethodWrapper -Uri $latestUpdateFeedUri).PrimaryDownloadInformation
            if ($null -ne $latestUpdateFeed) {

                # Strip the file extension from the filename (eg snagit.exe becomes snagit)
                $FileName = [System.IO.Path]::GetFileNameWithoutExtension($latestUpdateFeed.Name)
                foreach ($InstallerType in $res.Get.Download.Uri.GetEnumerator()) {

                    # Build the download URL
                    $Uri = ($InstallerType.Value -replace $res.Get.Download.ReplaceFileName, $FileName) -replace $res.Get.Download.ReplaceRelativePath, $latestUpdateFeed.RelativePath

                    # Extract file type
                    try {
                        $Type = [RegEx]::Match($InstallerType.Key, $res.Get.Update.MatchType).Captures.Groups[0].Value
                    }
                    catch {
                        throw "$($MyInvocation.MyCommand): failed to obtain file type information."
                    }

                    # Construct the output; Return the custom object to the pipeline
                    $PSObject = [PSCustomObject] @{
                        Version      = "$($latestUpdateFeed.Major).$($latestUpdateFeed.Minor).$($latestUpdateFeed.Maintenance)"
                        Date         = ConvertTo-DateTime -DateTime $latestUpdateFeed.Release -Pattern $res.Get.Update.DatePattern
                        Type         = $Type
                        Architecture = Get-Architecture $InstallerType.Key
                        URI          = $Uri
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }

}
