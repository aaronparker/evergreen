Function Get-PodmanDesktop {
    <#
        .SYNOPSIS
            Returns the available Podman Desktop versions.

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

    # For windows there are two different .exe versions.
    foreach ($o in $object) {
        if (-not($o.URI.contains("setup")) -and $o.URI.EndsWith(".exe")) {
            $o.InstallerType = "Portable"
        }
    }

    Write-Output -InputObject $object
}
