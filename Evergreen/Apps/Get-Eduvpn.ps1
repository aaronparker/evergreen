Function Get-eduVPN {
    <#
        .SYNOPSIS
            Returns the latest EduVPN version number and download.

        .NOTES
            Author: Jasper Metselaar
            E-mail: jms@du.se
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
    $object = Get-CodebergRepoRelease @params
    Write-Output -InputObject $object
}
