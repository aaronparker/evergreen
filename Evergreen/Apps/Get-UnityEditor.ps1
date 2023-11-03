function Get-UnityEditor {
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
        Uri         = $res.Get.Download.Uri
        ContentType = $res.Get.Download.ContentType
    }
    $DownloadsFeed = Invoke-EvergreenRestMethod @params

    foreach ($Channel in $res.Get.Download.Channels) {
        foreach ($item in $DownloadsFeed.$Channel) {

            # Build the object
            $PSObject = [PSCustomObject] @{
                Version  = $item.version
                Release  = $item.version.Substring(0, [Math]::Min($item.version.Length, 4))
                Channel  = $Channel
                LTS      = $item.lts
                Size     = $item.downloadSize
                Checksum = $item.checksum
                Type     = Get-FileType -File $item.downloadUrl
                URI      = $item.downloadUrl
            }
            Write-Output -InputObject $PSObject
        }
    }
}
