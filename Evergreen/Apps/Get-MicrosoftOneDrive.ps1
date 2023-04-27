function Get-MicrosoftOneDrive {
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
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Step through each release URI
    foreach ($ring in $res.Get.Uri.GetEnumerator()) {
        try {
            [System.XML.XMLDocument] $xmlDocument = Invoke-WebRequestWrapper -Uri $res.Get.Uri[$ring.Key] -Raw
        }
        catch [System.Exception] {
            throw "$($MyInvocation.MyCommand): failed to convert feed into an XML object with: $($_.Exception.Message)"
        }

        # Build an output object by selecting installer entries from the feed
        if ($xmlDocument -is [System.XML.XMLDocument]) {

            # Select the required node/s from the XML feed
            $nodes = Select-Xml -Xml $xmlDocument -XPath $res.Get.XmlNode | Select-Object –ExpandProperty "node"

            # Find the latest version
            foreach ($node in $nodes) {
                if ([System.Boolean]($node.PSobject.Properties.name -match "amd64binary")) {
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

                if ([System.Boolean]($node.PSobject.Properties.name -match "arm64binary")) {
                    $PSObject = [PSCustomObject] @{
                        Version      = $node.currentversion
                        Architecture = Get-Architecture -String $node.arm64binary.url
                        Ring         = $ring.Name
                        Sha256       = $node.arm64binary.sha256hash
                        Type         = [System.IO.Path]::GetExtension($node.arm64binary.url).Split(".")[-1]
                        URI          = $node.arm64binary.url
                    }
                    Write-Output -InputObject $PSObject
                }

                if ([System.Boolean]($node.PSobject.Properties.name -match "msixbinary")) {
                    # Construct the output for MSIX; Return the custom object to the pipeline
                    $PSObject = [PSCustomObject] @{
                        Version      = $node.currentversion
                        Architecture = Get-Architecture -String $node.msixbinary.url
                        Ring         = $ring.Name
                        Sha256       = if ($node.msixbinary.sha256hash) { $node.msixbinary.sha256hash } else { "N/A" }
                        Type         = [System.IO.Path]::GetExtension($node.msixbinary.url).Split(".")[-1]
                        URI          = $node.msixbinary.url
                    }
                    Write-Output -InputObject $PSObject
                }

                # Construct the output for EXE; Return the custom object to the pipeline
                if ([System.Boolean]($node.PSobject.Properties.name -match "binary")) {
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
            }
        }
    }
}
