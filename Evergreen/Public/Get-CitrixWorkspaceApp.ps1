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

                # Select the required node/s from the XML feed
                $nodes = Select-Xml -Xml $xmlDocument -XPath $res.Get.XmlNode | Select-Object –ExpandProperty "node"

                # Walk through each node to output details
                ForEach ($node in $nodes) {
                    $PSObject = [PSCustomObject] @{
                        Version  = $node.Version
                        Title    = $($node.ShortDescription -replace ":", "")
                        Size     = $(If ($node.Size) { $node.Size } Else { "Unknown" })
                        Hash     = $node.Hash
                        Date     = ConvertTo-DateTime -DateTime $node.StartDate -Pattern $res.Get.DatePattern
                        Platform = $item
                        URI      = "$($res.Get.DownloadUri)$($node.DownloadURL)"
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
