function Get-Zoom {
    <#
        .SYNOPSIS
            Get the current version and download URL for Zoom.

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

    # Get the download data from the API
    $params = @{
        Uri         = $res.Get.Download.Uri
        ContentType = $res.Get.Download.ContentType
    }
    $DownloadFeed = Invoke-EvergreenRestMethod @params

    # Step through each the download types
    foreach ($Property in $res.Get.Download.Properties) {

        # Construct the URL for the User installer
        $Url = "$($res.Get.Download.Hostname)/$($DownloadFeed.result.downloadVO.$Property.version)/$($DownloadFeed.result.downloadVO.$Property.packageName)"

        # Add the architecture to the URL
        if (-not([System.String]::IsNullOrEmpty($DownloadFeed.result.downloadVO.$Property.archType))) {
            $Url = "$Url$("?archType=")$($DownloadFeed.result.downloadVO.$Property.archType)"
        }

        # Resolve the download URL
        $ResolvedUrl = Resolve-SystemNetWebRequest -Uri $Url

        # Version number
        if ($DownloadFeed.result.downloadVO.$Property.version -eq "latest") {
            $Version = $DownloadFeed.result.downloadVO.$Property.displayVersion -replace "\s+\(", "." -replace "\)", ""
        }
        else {
            $Version = $DownloadFeed.result.downloadVO.$Property.version
        }

        # Create an output object
        $Output = [PSCustomObject]@{
            Version      = $Version
            Platform     = $res.Get.Download.PropertyMatrix[$Property]
            Installer    = "User"
            Size         = $ResolvedUrl.ContentLength
            Type         = Get-FileType -File $ResolvedUrl.ResponseUri.AbsoluteUri
            Architecture = Get-Architecture -String $ResolvedUrl.ResponseUri.AbsoluteUri
            URI          = $ResolvedUrl.ResponseUri.AbsoluteUri
        }
        Write-Output -InputObject $Output

        # Construct the URL for the IT installer
        if (-not([System.String]::IsNullOrEmpty($DownloadFeed.result.downloadVO.$Property.packageNameForIT))) {
            $Url = "$($res.Get.Download.Hostname)/$($DownloadFeed.result.downloadVO.$Property.version)/$($DownloadFeed.result.downloadVO.$Property.packageNameForIT)"

            # Add the architecture to the URL
            if (-not([System.String]::IsNullOrEmpty($DownloadFeed.result.downloadVO.$Property.archType))) {
                $Url = "$Url$("?archType=")$($DownloadFeed.result.downloadVO.$Property.archType)"
            }

            # Resolve the download URL
            $ResolvedUrl = Resolve-SystemNetWebRequest -Uri $Url

            # Create an output object
            $Output = [PSCustomObject]@{
                Version      = $Version
                Platform     = $res.Get.Download.PropertyMatrix[$Property]
                Installer    = "Admin"
                Size         = $ResolvedUrl.ContentLength
                Type         = Get-FileType -File $ResolvedUrl.ResponseUri.AbsoluteUri
                Architecture = Get-Architecture -String $ResolvedUrl.ResponseUri.AbsoluteUri
                URI          = $ResolvedUrl.ResponseUri.AbsoluteUri
            }
            Write-Output -InputObject $Output
        }
    }
}
