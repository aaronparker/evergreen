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

    # Get the latest version of AWS CLI via the latest tag on the repository
    $Tags = Get-GitHubRepoTag -Uri $res.Get.Update.Uri

    # Select the latest version
    $Version = $Tags | Sort-Object -Property @{ Expression = { [System.Version]$_.Tag }; Descending = $true } | Select-Object -First 1

    # Output the version and download URL
    $PSObject = [PSCustomObject] @{
        Version = $Version.Tag
        Type    = "msi"
        URI     = $res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $Version.Tag
    }
    Write-Output -InputObject $PSObject
}
