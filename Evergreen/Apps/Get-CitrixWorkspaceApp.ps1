Function Get-CitrixWorkspaceApp {
    <#
        .SYNOPSIS
            Returns the current Citrix Workspace app releases and HDX RTME release.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Filter
    )

    # Read the Citrix Workspace app for updater feed for each OS in the list
    $params = @{
        Uri       = $res.Get.Update.Uri
        UserAgent = $res.Get.Update.UserAgent
    }
    $UpdateFeed = Invoke-RestMethodWrapper @params

    # Convert content to XML document
    If ($Null -ne $UpdateFeed) {

        # Walk through each node to output details
        ForEach ($Installer in $UpdateFeed.Catalog.Installers) {
            ForEach ($node in $Installer.Installer) {
                $PSObject = [PSCustomObject] @{
                    Version = $node.Version
                    Title   = $($node.ShortDescription -replace ":", "")
                    Size    = $(If ($node.Size) { $node.Size } Else { "Unknown" })
                    Hash    = $node.Hash
                    Date    = ConvertTo-DateTime -DateTime $node.StartDate -Pattern $res.Get.Update.DatePattern
                    Stream  = $node.Stream
                    URI     = "$($res.Get.Download.Uri)$($node.DownloadURL)"
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
    Write-Warning -Message "$($MyInvocation.MyCommand): HDX RTME for Windows version returned is out of date. See $($script:resourceStrings.Uri.Issues) for more information."
}
