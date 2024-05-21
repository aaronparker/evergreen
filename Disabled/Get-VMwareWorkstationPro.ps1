function Get-VMwareWorkstationPro {
    <#
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    $Output = Get-VMwareProductList -Name $res.Get.Download.ProductName | `
        Get-VMwareProductDownload | `
        Where-Object { $_.URI -match $res.Get.Download.MatchFileTypes } | `
        Sort-Object -Property "ReleaseDate" | `
        Select-Object -Last 1 | `
        ForEach-Object { $_.Version = $_.Version -replace $res.Get.Download.ReplaceText, ""; $_ }
    Write-Output -InputObject $Output
}
