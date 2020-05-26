Function Get-WixToolset {
    <#
        .SYNOPSIS
            Returns the latest Wix Toolset version number and download.

        .DESCRIPTION
            Returns the latest Wix Toolset version number and download.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-WixToolset

            Description:
            Returns the latest Wix Toolset version number and download for each platform.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Get latest version and download latest release via GitHub API
    $iwcParams = @{
        Uri         = $res.Get.Uri
        ContentType = $res.Get.ContentType
    }
    $Content = Invoke-WebContent @iwcParams

    # Convert the returned release data into a useable object with Version, URI etc.
    $params = @{
        Content      = $Content
        MatchVersion = $res.Get.MatchVersion
        VersionTag   = $res.Get.VersionTag
    }
    $object = ConvertFrom-GitHubReleasesJson @params
    Write-Output -InputObject $object
}
