Function Get-MicrosoftOneDrive {
    <#
        .SYNOPSIS
            Returns the current version and download URL for the Microsoft OneDrive sync client for Windows.

        .NOTES
            Site: https://stealthpuppy.com
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

    # Step through each release URI
    ForEach ($ring in $res.Get.Uri.GetEnumerator()) {

        # Read the XML
        $Content = Invoke-WebRequestWrapper -Uri $res.Get.Uri[$ring.Key]
        If ($Null -ne $Content) {

            Try {
                #TODO: remove invalid chars before the XML in a more robust manner
                [System.XML.XMLDocument] $xmlDocument = ($Content -replace "ï»¿", "")
            }
            Catch [System.Exception] {
                Throw "$($MyInvocation.MyCommand): failed to convert feed into an XML object."
            }

            # Build an output object by selecting installer entries from the feed
            If ($xmlDocument -is [System.XML.XMLDocument]) {

                # Select the required node/s from the XML feed
                $nodes = Select-Xml -Xml $xmlDocument -XPath $res.Get.XmlNode | Select-Object –ExpandProperty "node"

                # Find the latest version
                ForEach ($node in $nodes) {

                    # Construct the output for EXE; Return the custom object to the pipeline
                    If ([System.Boolean]($node.PSobject.Properties.name -match "binary")) {
                        $PSObject = [PSCustomObject] @{
                            Version      = $node.currentversion
                            Architecture = Get-Architecture -String $node.binary.url
                            Ring         = $ring.Name
                            Sha256       = $node.binary.sha256hash
                            Type         = [System.IO.Path]::GetExtension($node.binary.url).Split(".")[-1]
                            URI          = $node.binary.url
                        }
                        Write-Output -InputObject $PSObject
                    }

                    If ([System.Boolean]($node.PSobject.Properties.name -match "amd64binary")) {
                        $PSObject = [PSCustomObject] @{
                            Version      = $node.currentversion
                            Architecture = Get-Architecture -String $node.amd64binary.url
                            Ring         = $ring.Name
                            Sha256       = $node.amd64binary.sha256hash
                            Type         = [System.IO.Path]::GetExtension($node.amd64binary.url).Split(".")[-1]
                            URI          = $node.amd64binary.url
                        }
                        Write-Output -InputObject $PSObject
                    }

                    If ([System.Boolean]($node.PSobject.Properties.name -match "msixbinary")) {
                        # Construct the output for MSIX; Return the custom object to the pipeline
                        $PSObject = [PSCustomObject] @{
                            Version      = $node.currentversion
                            Architecture = Get-Architecture -String $node.msixbinary.url
                            Ring         = $ring.Name
                            Sha256       = If ($node.msixbinary.sha256hash) { $node.msixbinary.sha256hash } Else { "N/A" }
                            Type         = [System.IO.Path]::GetExtension($node.msixbinary.url).Split(".")[-1]
                            URI          = $node.msixbinary.url
                        }
                        Write-Output -InputObject $PSObject
                    }
                }
            }
        }
    }
}
