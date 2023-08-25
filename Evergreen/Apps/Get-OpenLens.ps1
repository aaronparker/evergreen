Function Get-OpenLens {
    <#
        .SYNOPSIS
            Returns the available OpenLens versions.

        .NOTES
            Author: Kirill Trofimov
            Author: BornToBeRoot
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "Product name is a plural")]
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
    # Setup:    OpenLens.Setup.6.5.2-366.exe
    # Portable: OpenLens.6.5.2-366.exe
    foreach ($o in $object) {
        if (-not($o.URI.contains("Setup")) -and $o.URI.EndsWith(".exe")) {
            $o.InstallerType = "Portable"
        }
    }
    Write-Output -InputObject $object
}
