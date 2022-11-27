function Get-AWSCLI {
    <#
        .SYNOPSIS
            Get the current versions and download URLs for AWS CLI

        .NOTES
            Author: Kirill Trofimov
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get latest version and download latest release via GitHub API
    $params = @{
        Uri          = $res.Get.Update.Uri
        ContentType  = $res.Get.Update.ContentType
        ReturnObject = "Content"
    }
    $Content = Invoke-WebRequestWrapper @params | ConvertFrom-Json

    if ($null -ne $Content) {
        $Content | Sort-Object -Property "name" | Select-Object -Last 1 | ForEach-Object {
            $PSObject = [PSCustomObject] @{
                Version = $_.name
                Type    = Get-FileType -File $res.Get.Download.Uri
                URI     = $res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $_.name
            }
            Write-Output -InputObject $PSObject
        }
    }
}
