function Get-Npcap {
    <#
        .SYNOPSIS
            Returns the latest Npcap version number and download.

        .NOTES
            Author: Jasper Metselaar
            E-mail: jms@du.se
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get the latest version via the latest tag on the repository
    $Tags = Get-GitHubRepoTag -Uri $res.Get.Update.Uri

    # Select the latest version
    $Version = $Tags | Sort-Object -Property @{ Expression = { [System.Version]$_.Tag }; Descending = $true } | Select-Object -First 1

    # Output the version and download URL
    $PSObject = [PSCustomObject] @{
        Version = $Version.Tag
        Type    = Get-FileType -File $res.Get.Download.Uri
        URI     = $res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $Version.Tag
    }
    Write-Output -InputObject $PSObject

}
