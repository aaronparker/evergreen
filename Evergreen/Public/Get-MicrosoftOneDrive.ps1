Function Get-MicrosoftOneDrive {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Microsoft OneDrive sync client.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-MicrosoftOneDrive

            Description:
            Returns the current version and download URL for the Microsoft OneDrive sync client for Windows.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Step through each release URI
    ForEach ($ring in $res.Get.Uri.GetEnumerator()) {

        # Read the XML
        $Content = Invoke-WebContent -Uri $res.Get.Uri[$ring.Key]
        If ($Null -ne $Content) {

            Try {
                #TODO: remove invalid chars before the XML in a more robust manner
                [System.XML.XMLDocument] $xmlDocument = ($Content -replace "ï»¿", "")
            }
            Catch [System.Exception] {
                Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert feed into an XML object."
                Break
            }

            # Build an output object by selecting installer entries from the feed
            If ($xmlDocument -is [System.XML.XMLDocument]) {

                # Select the required node/s from the XML feed
                $nodes = Select-Xml -Xml $xmlDocument -XPath $res.Get.XmlNode | Select-Object –ExpandProperty "node"

                # Find the latest version
                ForEach ($node in $nodes) {

                    # Construct the output; Return the custom object to the pipeline
                    $PSObject = [PSCustomObject] @{
                        Version    = $node.currentversion
                        Platform   = "Windows"
                        Ring       = $ring.Name
                        SHA256hash = $node.binary.sha256hash
                        URI        = $node.binary.url
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}
