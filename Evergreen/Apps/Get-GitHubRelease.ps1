function Get-GitHubRelease {
    <#
        .SYNOPSIS
            Returns latest version and URI from a GitHub repository release list.

            The releases URI is expected in the following format: https://api.github.com/repos/<account>/<repository>/releases/latest.

            More information on the GitHub releases API can be found here: https://developer.github.com/v3/repos/releases/.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .EXAMPLE
            Get-GitHubRelease -Uri "https://api.github.com/repos/Open-Shell/Open-Shell-Menu/releases/latest"

            Description:
            Returns version and download URIs from the supplied GitHub repository URL.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateScript( {
                if ($_ -match "^(https://api\.github\.com/repos/)([a-zA-Z0-9_-]+)/([a-zA-Z0-9_-]+)(/releases/latest)$") {
                    $True
                }
                else {
                    throw "'$_' must be in the format 'https://api.github.com/repos/user/repository/releases/latest'. Replace 'user' with the user or organisation and 'repository' with the target repository name."
                }
            })]
        [System.String] $Uri = "https://api.github.com/repos/atom/atom/releases/latest"
    )

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]

    # If -Uri isn't used, we'll use the default value to show at least something
    if (-not($PSBoundParameters.ContainsKey("Uri"))) {
        Write-Warning -Message "$($MyInvocation.MyCommand): -Uri parameter not specified. Using the default repository."
    }

    # Pass the repo releases API URL and return a formatted object
    $params = @{
        Uri          = $Uri
        MatchVersion = $res.Get.MatchVersion
        Filter       = $res.Get.MatchFileTypes
    }
    $object = Get-GitHubRepoRelease @params
    Write-Output -InputObject $object
}
