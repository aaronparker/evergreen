Function Get-NETworkManager {
    <#
        .SYNOPSIS
            Returns the available NETworkManager versions.

        .NOTES
            Author: BornToBeRoot
            Twitter: @_BornToBeRoot
        
        .LINK
            https://github.com/BornToBeRoot/NETworkManager

        .EXAMPLE
            Get-NETworkManager

            Description:
            Returns the released NETworkManager version and download URI.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Pass the repo releases API URL and return a formatted object
    $params = @{
        Uri          = $res.Get.Uri
        MatchVersion = $res.Get.MatchVersion
        Filter       = $res.Get.MatchFileTypes
    }
    $object = Get-GitHubRepoRelease @params
    If ($object) {
        Write-Output -InputObject $object
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to return a usable object from the repo."
    }
}
