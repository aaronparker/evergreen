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
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Step through each release URI
    foreach ($ring in $res.Get.Update.Uri.GetEnumerator()) {
        $params = @{
            Uri         = $res.Get.Update.Uri[$ring.Key]
            ContentType = $res.Get.Update.ContentType
            Raw         = $true
            ErrorAction = "Stop"
        }
        [System.XML.XMLDocument] $xmlDocument = Invoke-EvergreenWebRequest @params

        # Build an output object by selecting installer entries from the feed
        if ($xmlDocument -is [System.XML.XMLDocument]) {

            # Select the required node/s from the XML feed
            $nodes = Select-Xml -Xml $xmlDocument -XPath $res.Get.Update.XmlNode | Select-Object -ExpandProperty "node"

            # Find the latest version
            foreach ($node in $nodes) {
                if ([System.Boolean]($node.PSobject.Properties.name -match "amd64binary")) {
                    [PSCustomObject] @{
                        Version      = $node.currentversion
                        Throttle     = $node.throttle
                        Architecture = Get-Architecture -String $node.amd64binary.url
                        Ring         = $ring.Name
                        Type         = [System.IO.Path]::GetExtension($node.amd64binary.url).Split(".")[-1]
                        Sha256       = $node.amd64binary.sha256hash
                        URI          = $node.amd64binary.url
                    } | Write-Output
                }

                if ([System.Boolean]($node.PSobject.Properties.name -match "arm64binary")) {
                    [PSCustomObject] @{
                        Version      = $node.currentversion
                        Throttle     = $node.throttle
                        Architecture = Get-Architecture -String $node.arm64binary.url
                        Ring         = $ring.Name
                        Type         = Get-FileType -File $node.arm64binary.url
                        Sha256       = $node.arm64binary.sha256hash
                        URI          = $node.arm64binary.url
                    } | Write-Output
                }

                if ([System.Boolean]($node.PSobject.Properties.name -match "msixbinary")) {
                    # Construct the output for MSIX; Return the custom object to the pipeline
                    [PSCustomObject] @{
                        Version      = $node.currentversion
                        Throttle     = $node.throttle
                        Architecture = Get-Architecture -String $node.msixbinary.url
                        Ring         = $ring.Name
                        Type         = Get-FileType -File $node.msixbinary.url
                        Sha256       = if ($node.msixbinary.sha256hash) { $node.msixbinary.sha256hash } else { "N/A" }
                        URI          = $node.msixbinary.url
                    } | Write-Output
                }

                # Construct the output for EXE; Return the custom object to the pipeline
                if ([System.Boolean]($node.PSobject.Properties.name -match "binary")) {
                    $PSObject = [PSCustomObject] @{
                        Version      = $node.currentversion
                        Throttle     = $node.throttle
                        Architecture = Get-Architecture -String $node.binary.url
                        Ring         = $ring.Name
                        Sha256       = $node.binary.sha256hash
                        Type         = Get-FileType -File $node.binary.url
                        URI          = $node.binary.url
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}
