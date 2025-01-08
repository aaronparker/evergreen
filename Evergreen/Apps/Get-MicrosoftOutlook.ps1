function Get-MicrosoftOutlook {
    <#
        .SYNOPSIS
            Returns the available Microsoft Outlook versions and download URIs.

        .NOTES
            Author: Aaron Parker
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    foreach ($Url in $res.Get.Download.Uri) {
        Resolve-MicrosoftFwLink -Uri $Url | `
            ForEach-Object { $_.Language = "Neutral"; $_ } | `
            Write-Output
    }
}
