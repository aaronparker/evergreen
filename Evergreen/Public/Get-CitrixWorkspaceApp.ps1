Function Get-CitrixWorkspaceApp {
    <#
        .SYNOPSIS
            Returns the current Citrix Workspace app, Receiver and HDX RTME releases.

        .DESCRIPTION
            Returns the current Citrix Workspace app, Receiver and HDX RTME releases.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://stealthpuppy.com/latest-receiver-version-powershell/

        .EXAMPLE
            Get-CitrixWorkspaceApp

            Description:
            Returns the available Citrix Workspace app, Receiver and HDX RTME releases for all platforms.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Read the Citrix Workspace app for updater feed for each OS in the list
    ForEach ($item in $res.Get.Uri.Keys) {
        $Content = Invoke-WebContent -Uri $res.Get.Uri[$item]

        # Convert content to XML document
        If ($Null -ne $Content) {
            Try {
                [System.XML.XMLDocument] $xmlDocument = $Content
            }
            Catch [System.Exception] {
                Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert feed into an XML object."
            }

            # Build an output object by selecting installer entries from the feed
            If ($xmlDocument -is [System.XML.XMLDocument]) {
                ForEach ($installer in (Select-Xml -Xml $xmlDocument -XPath "//Installer")) {
                    $PSObject = [PSCustomObject] @{
                        Version  = $installer.Node.Version
                        Title    = $($installer.Node.ShortDescription -replace ":", "")
                        Size     = $(If ($installer.Node.Size) { $installer.Node.Size } Else { "Unknown" })
                        Hash     = $installer.Node.Hash
                        Date     = $installer.Node.StartDate
                        Platform = $item
                        URI      = "$($res.Get.DownloadUri)$($installer.Node.DownloadURL)"
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to read Citrix Workspace update feed."
        }
    }
}
