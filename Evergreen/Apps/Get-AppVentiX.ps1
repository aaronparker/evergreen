Function Get-AppVentiX {
    <#
        .SYNOPSIS
            Get the current version and download URIs for AppVentix.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    $params = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $Content = Invoke-EvergreenRestMethod @params
    If ($Null -ne $Content) {

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version      = $Content.Trim()
            Filename     = $res.Get.Download.Filename -replace "#version", $Content.Trim()
            URI          = $res.Get.Download.Uri
        }
        Write-Output -InputObject $PSObject
    }
}
