Function Get-BISF {
    <#
        .SYNOPSIS
            Returns the available Base Image Script Framework versions.

        .DESCRIPTION
            Returns the available Base Image Script Framework versions.

        .NOTES
            Author: Trond Eirik Haavarstein 
            Twitter: @xenappblog
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-BISF

            Description:
            Returns the released Base Image Script Framework version and download URI.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Query the BIS-F repository for releases, keeping the latest release
    $iwcParams = @{
        Uri         = $res.Get.Uri
        ContentType = $res.Get.ContentType
    }
    $Content = Invoke-WebContent @iwcParams

    If ($Null -ne $Content) {
        $latestRelease = ($Content | ConvertFrom-Json | Where-Object { $_.prerelease -eq $False }) | Select-Object -First 1        
        $releases = $latestRelease.assets

        # Build and array of the latest release and download URLs
        ForEach ($release in $releases) {
            $PSObject = [PSCustomObject] @{
                Version = $latestRelease.tag_name
                Date    = (ConvertTo-DateTime -DateTime $release.created_at)
                Size    = $release.size
                URI     = $release.browser_download_url
            }
            Write-Output -InputObject $PSObject
        }
    }
}
