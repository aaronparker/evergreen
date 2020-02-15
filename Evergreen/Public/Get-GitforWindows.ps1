Function Get-GitForWindows {
    <#
        .SYNOPSIS
            Returns the available Git for Windows versions.

        .DESCRIPTION
            Returns the available Git for Windows versions.

        .NOTES
            Author: Trond Eirik Haavarstein 
            Twitter: @xenappblog
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-Git

            Description:
            Returns the released Git version and download URI.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Query the Git repository for releases, keeping the latest release
    $iwcParams = @{
        Uri         = $res.Get.Uri
        ContentType = $res.Get.ContentType
    }
    $Content = Invoke-WebContent @iwcParams

    If ($Null -ne $Content) {
        $json = $Content | ConvertFrom-Json
        $latestRelease = $json | Where-Object { $_.prerelease -ne $True } | Select-Object -First 1
        $regexMatch = [Regex]::Match($latestRelease.tag_name, $res.Get.MatchVersion)
        $version = if ($regexMatch.Success) { $regexMatch.Value } else { 'Unknown' }

        # Build and array of the latest release and download URLs
        ForEach ($release in $latestRelease.assets) {
            $PSObject = [PSCustomObject] @{
                Version = $version
                Date    = (ConvertTo-DateTime -DateTime $release.created_at)
                Size    = $release.size
                URI     = $release.browser_download_url
            }
            Write-Output -InputObject $PSObject
        }
    }
}
