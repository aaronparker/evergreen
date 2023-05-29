function Get-CitrixWorkspaceApp {
    <#
        .SYNOPSIS
            Returns the current Citrix Workspace app releases and HDX RTME release.

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

    # Read the Citrix Workspace app for updater feed for each OS in the list
    $params = @{
        Uri       = $res.Get.Update.Uri
        UserAgent = $res.Get.Update.UserAgent
    }
    $UpdateFeed = Invoke-RestMethodWrapper @params

    # Convert content to XML document
    if ($null -ne $UpdateFeed) {

        # Filter the update feed for just the installers we want
        $Installers = $UpdateFeed.Catalog.Installers | `
            Where-Object { $_.name -eq $res.Get.Update.FilterName } | `
            Select-Object -ExpandProperty $res.Get.Update.ExpandProperty

        # Walk through each node to output details
        foreach ($Installer in $Installers) {
            $PSObject = [PSCustomObject] @{
                Version = $Installer.Version
                Title   = $($Installer.ShortDescription -replace ":", "")
                Size    = $(if ($Installer.Size) { $Installer.Size } else { "Unknown" })
                Hash    = $Installer.Hash
                Date    = ConvertTo-DateTime -DateTime $Installer.StartDate -Pattern $res.Get.Update.DatePattern
                Stream  = $Installer.Stream
                URI     = "$($res.Get.Download.Uri)$($Installer.DownloadURL)"
            }
            Write-Output -InputObject $PSObject
        }
    }
}
