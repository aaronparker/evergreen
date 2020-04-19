Function Get-GitHubRelease {
    <#
        .SYNOPSIS
            Returns latest version and URI from a GitHub repository release list.

        .DESCRIPTION
            Returns latest version and URI from a GitHub repository release list.

            The releases URI is expected in the following format: https://api.github.com/repos/<account>/<repository>/releases/latest.
            
            More information on the GitHub releases API can be found here: https://developer.github.com/v3/repos/releases/.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-GitHubRelease -Uri "https://api.github.com/repos/Open-Shell/Open-Shell-Menu/releases/latest"

            Description:
            Returns version and download URIs from the supplied GitHub repository.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Uri
    )

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Get latest version and download latest release via GitHub API
    $iwcParams = @{
        Uri         = $Uri
        ContentType = $res.Get.ContentType
    }
    $Content = Invoke-WebContent @iwcParams

    # Convert the returned release data into a useable object with Version, URI etc.
    $object = ConvertFrom-GitHubReleasesJson -Content $Content -MatchVersion $res.Get.MatchVersion
    Write-Output -InputObject $object
}
