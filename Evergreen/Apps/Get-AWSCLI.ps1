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

    # Get only latest version tag from GitHub API
    $Content = ((Invoke-WebRequestWrapper @params | ConvertFrom-Json).name | ForEach-Object { New-Object -TypeName "System.Version" ($_) } | Sort-Object -Descending | Select-Object -First 1 | ForEach-Object {("{0}.{1}.{2}" -f $_.Major,$_.Minor,$_.Build)})

    if ($null -ne $Content) {
        $Content | ForEach-Object {
            $PSObject = [PSCustomObject] @{
                Version = $_
                Type    = "msi"
                URI     = $res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $_
            }
            Write-Output -InputObject $PSObject
        }
    }
}
