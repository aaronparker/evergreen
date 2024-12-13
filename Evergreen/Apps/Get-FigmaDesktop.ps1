function Get-FigmaDesktop {
    <#
        .NOTES
            Site: https://stealthpuppy.com
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

    $Content = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri
    if ($null -ne $Content) {
        $object = [PSCustomObject]@{
            Version = $Content.title -replace $res.Get.Update.ReplaceText, ""
            Date    = $Content.pubDate
            URI     = $Content.link
        }
        Write-Output -InputObject $object
    }
}
