function Get-YubicoAuthenticator {
    <#
        .SYNOPSIS
            Returns the available Yubico Authenticator versions.

        .NOTES
            Author: Kirill Trofimov
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Pass the repo releases API URL and return a formatted object
    $params = @{
        Uri          = $res.Get.Uri
        MatchVersion = $res.Get.MatchVersion
        Filter       = $res.Get.MatchFileTypes
    }
    $object = Get-GitHubRepoRelease @params

    # Get all builds, based on $LatestRelease version
    $LatestRelease = $object | Select-Object -First 1
    $Release = $object | Where-Object { $_.Version -match "$($LatestRelease.Version)" }
    Write-Output -InputObject $Release
}
