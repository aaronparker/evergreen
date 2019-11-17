Function Get-ScooterBeyondCompare {
    <#
        .SYNOPSIS
            Returns the latest Beyond Compare and download URL.

        .DESCRIPTION
            Returns the latest Beyond Compare and download URL.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-ScooterBeyondCompare

            Description:
            Returns the latest Beyond Compare and download URL.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name    

    ForEach ($language in $res.Get.Uri.GetEnumerator()) {

        # Query the Beyond Compare update API
        $iwcParams = @{
            Uri       = $res.Get.Uri[$language.key]
            UserAgent = $res.Get.UserAgent
            Raw       = $True
        }
        $Content = Invoke-WebContent @iwcParams

        # If something is returned
        If ($Null -ne $Content) {
            Try {
                [System.XML.XMLDocument] $xmlDocument = $Content
            }
            Catch [System.Exception] {
                Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert content to an XML object."
            }

            # Build an output object by selecting Citrix XML entries from the feed
            If ($xmlDocument -is [System.XML.XMLDocument]) {

                # Select the required node/s from the XML feed
                $nodes = Select-Xml -Xml $xmlDocument -XPath $res.Get.XmlNode | Select-Object –ExpandProperty "node"
                ForEach ($node in $nodes) {

                    # Extract version number
                    $node.latestversion -match $res.Get.MatchVersion | Out-Null

                    # Build an array of the latest release and download URLs
                    $PSObject = [PSCustomObject] @{
                        Version  = $matches[0]
                        Language = $res.Get.Languages[$language.key]
                        URI      = $node.download
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}
