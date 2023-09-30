function Get-Zoom {
    <#
        .SYNOPSIS
            Get the current version and download URL for Zoom.

        .NOTES
            Author: Trond Eirik Haavarstein
            Twitter: @xenappblog
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    <#
    foreach ($platform in $res.Get.Download.Keys) {
        foreach ($installer in $res.Get.Download[$platform].Keys) {

            # Follow the download link which will return a 301/302
            $redirectUrl = Resolve-SystemNetWebRequest -Uri $res.Get.Download[$platform][$installer]

            # Match the URL without the text after the ?
            if ($null -eq $redirectUrl) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Setting fallback URL to: $($script:resourceStrings.Uri.Issues)."
                $Url = $script:resourceStrings.Uri.Issues
            }
            else {
                try {
                    $Url = [RegEx]::Match($redirectUrl.ResponseUri.AbsoluteUri, $res.Get.MatchUrl).Captures.Groups[1].Value
                }
                catch {
                    $Url = $redirectUrl.ResponseUri.AbsoluteUri
                }
            }

            # Match version number from the download URL
            try {
                $Version = [RegEx]::Match($Url, $res.Get.MatchVersion).Captures.Groups[0].Value
            }
            catch {
                $Version = "Latest"
            }

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Platform     = $platform
                Type         = Get-FileType -File $Url
                Architecture = Get-Architecture -String $Url
                URI          = $Url
            }
            Write-Output -InputObject $PSObject
        }
    }
    #>

    # Get the download data from the API
    $params = @{
        Uri         = $res.Get.Download.Uri
        ContentType = $res.Get.Download.ContentType
    }
    $DownloadFeed = Invoke-RestMethodWrapper @params

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
        [PSCustomObject]@{
            Version      = $Version
            Platform     = $res.Get.Download.PropertyMatrix[$Property]
            Installer    = "User"
            Size         = $ResolvedUrl.ContentLength
            Type         = Get-FileType -File $ResolvedUrl.ResponseUri.AbsoluteUri
            Architecture = Get-Architecture -String $ResolvedUrl.ResponseUri.AbsoluteUri
            URI          = $ResolvedUrl.ResponseUri.AbsoluteUri
        }

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
            [PSCustomObject]@{
                Version      = $Version
                Platform     = $res.Get.Download.PropertyMatrix[$Property]
                Installer    = "Admin"
                Size         = $ResolvedUrl.ContentLength
                Type         = Get-FileType -File $ResolvedUrl.ResponseUri.AbsoluteUri
                Architecture = Get-Architecture -String $ResolvedUrl.ResponseUri.AbsoluteUri
                URI          = $ResolvedUrl.ResponseUri.AbsoluteUri
            }
        }
    }
}
