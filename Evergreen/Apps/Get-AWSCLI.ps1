Function Get-AWSCLI {
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
    $Params = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $Content = Invoke-WebRequestWrapper @Params | ConvertFrom-Json

    If ($Null -ne $Content) {
        $Content | Sort-Object name | Select-Object -Last 1 | ForEach-Object {
            $PSObject = [PSCustomObject] @{
                Version = $_.name
                URI     = $res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $_.name
            }
            Write-Output -InputObject $PSObject
        }
    }

}
