Function Get-TelegramDesktop {
    <#
        .SYNOPSIS
            Returns the latest Telegram Desktop version number and download.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
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
        Uri               = $res.Get.Update.Uri
        MatchVersion      = $res.Get.Update.MatchVersion
        Filter            = $res.Get.Update.MatchFileTypes
        ReturnVersionOnly = $True
    }
    $object = Get-GitHubRepoRelease @params

    # Build the output object
    If ($Null -ne $object) {
        $PSObject = [PSCustomObject] @{
            Version = $object.Version
            URI     = $res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $object.Version
        }
        Write-Output -InputObject $PSObject
    }
}
