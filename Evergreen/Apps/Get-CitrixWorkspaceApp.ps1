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
    ForEach ($item in $res.Get.Uri.Keys) {
        #TODO: Update for Invoke-RestMethod
        $Content = Invoke-WebRequestWrapper -Uri $res.Get.Uri[$item]

        # Convert content to XML document
        If ($Null -ne $Content) {
            Try {
                [System.XML.XMLDocument] $xmlDocument = $Content
            }
            Catch [System.Exception] {
                Throw "$($MyInvocation.MyCommand): failed to convert feed into an XML object."
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
        Write-Warning -Message "$($MyInvocation.MyCommand): HDX RTME for Windows version returned is out of date. See https://stealthpuppy.com/evergreen/changelog.html for more information."
    }
}
