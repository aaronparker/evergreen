function Get-MicrosoftODBCDriverForSQLServer {
    <#
        .SYNOPSIS

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
        Uri                = $res.Get.Download.Uri
        MaximumRedirection = $res.Get.Download.MaximumRedirection
    }
    Resolve-MicrosoftFwLink @params | Write-Output
}
