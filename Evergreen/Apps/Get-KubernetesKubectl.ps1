function Get-KubernetesKubectl {
    <#
        .SYNOPSIS
            Returns the available Kubernetes Kubectl versions.

        .NOTES
            Author: BornToBeRoot
            Twitter: @_BornToBeRoot
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get the latest version for kubectl
    $Version = Invoke-RestMethod -Uri $res.Get.Update.Uri

    # Build the download links for each platform & architecture
    foreach ($DownloadUri in $res.Get.Download.Uri.GetEnumerator()) {
        [PSCustomObject] @{
            Version      = $Version.TrimStart("v")
            Architecture = $DownloadUri.Name.Split("_")[1]
            Platform     = $DownloadUri.Name.Split("_")[0]
            URI          = $DownloadUri.Value -replace $res.Get.Download.ReplaceVersionText, $Version
        }
    }
}
