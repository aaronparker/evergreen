function Get-GoogleDrive {
    <#
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    $params = @{
        Uri              = $res.Get.Update.Uri
        Method           = $res.Get.Update.Method
        Body             = $res.Get.Update.RequestBody
    }
    $Response = Invoke-EvergreenRestMethod @params
    if ($null -ne $Response) {
        [PSCustomObject]@{
            Version = $Response.response.app.updatecheck.manifest.version
            Sha256  = $Response.response.app.updatecheck.manifest.packages.package.hash_sha256
            Size    = $Response.response.app.updatecheck.manifest.packages.package.size
            URI     = $res.Get.Download.Uri
        }
    }
}
