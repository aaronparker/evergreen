Function Get-Greenshot {
    <#
        .SYNOPSIS
            Returns the available Greenshot versions.

        .DESCRIPTION
            Returns the available Greenshot versions.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-Greenshot

            Description:
            Returns the released Greenshot version and download URI.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Query the Greenshot repository for releases, keeping the latest release
    $iwcParams = @{
        Uri         = $res.Get.Uri
        ContentType = $res.Get.ContentType
    }
    $Content = Invoke-WebContent @iwcParams

    If ($Null -ne $Content) {
        $latestRelease = ($Content | ConvertFrom-Json | Where-Object { $_.prerelease -eq $False }) | Select-Object -First 1 

        # Latest version number 'Greenshot-RELEASE-1.2.10.6'
        $latestRelease.tag_name -match $res.Get.MatchVersion | Out-Null
        $latestVersion = $Matches[0]

        # Build and array of the latest release and download URLs
        $releases = $latestRelease.assets | Where-Object { $_.name -like "Greenshot*" }
        ForEach ($release in $releases) {
            $PSObject = [PSCustomObject] @{
                Version = $latestVersion
                Date    = (ConvertTo-DateTime -DateTime $release.created_at)
                Size    = $release.size
                URI     = $release.browser_download_url
            }
            Write-Output -InputObject $PSObject
        }
    }
}

