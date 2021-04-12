Function Get-OracleJava8 {
    <#
        .SYNOPSIS
            Gets the current available Oracle Java release versions.

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

    # Read the update RSS feed
    $Content = Invoke-WebRequestWrapper -Uri $res.Get.Uri

    # Convert to XML document
    If ($Null -ne $Content) {
        Try {
            [System.XML.XMLDocument] $xmlDocument = $Content
        }
        Catch [System.Exception] {
            Throw "$($MyInvocation.MyCommand): failed to convert content to an XML object."
        }

        # Build an output object by selecting entries from the feed
        If ($xmlDocument -is [System.XML.XMLDocument]) {
            $nodes = Select-Xml -Xml $xmlDocument -XPath "//mapping" | Select-Object –ExpandProperty "node"
            $updateNodes = $nodes | Where-Object { $_.url -notlike "*-cb.xml" }
            $latestUpdate = $updateNodes | Select-Object -Last 1

            # Read the XML listed in the most recent update
            $Content = Invoke-WebRequestWrapper -Uri $latestUpdate.url
            If ($Null -ne $Content) {
                Try {
                    [System.XML.XMLDocument] $xmlDocument = $Content
                }
                Catch [System.Exception] {
                    Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert content to an XML object."
                }

                # Select the update info
                $nodes = Select-Xml -Xml $xmlDocument -XPath "//information" | Select-Object –ExpandProperty "node"
                $Update = $nodes | Where-Object { $_.lang -eq "en" }

                # Construct the output; Return the custom object to the pipeline
                ForEach ($arch in "x64", "x86") {
                    $PSObject = [PSCustomObject] @{
                        Version      = (($Update.version | Sort-Object -Descending) | Select-Object -First 1)
                        Architecture = $arch
                        URI          = $Update.url -replace "-au.exe", $res.Get.FileStrings[$arch]
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
    Else {
        Throw "$($MyInvocation.MyCommand): failed to read update feed [$Uri]."
    }
}
