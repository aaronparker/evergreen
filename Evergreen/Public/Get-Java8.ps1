Function Get-Java8 {
    <#
        .SYNOPSIS
            Gets the current available Oracle Java release versions.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .EXAMPLE
            Get-Java8

            Description:
            Returns the available Java8 versions for Windows.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Read the update RSS feed
    $Content = Invoke-WebContent -Uri $script:resourceStrings.Applications.Java8.Uri

    # Convert to XML document
    If ($Null -ne $Content) {
        Try {
            [System.XML.XMLDocument] $xmlDocument = $Content
        }
        Catch [System.IO.IOException] {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert content to an XML object."
            Throw $_.Exception.Message
        }
        Catch [System.Exception] {
            Throw $_
        }

        # Build an output object by selecting entries from the feed
        If ($xmlDocument -is [System.XML.XMLDocument]) {
            $nodes = Select-Xml -Xml $xmlDocument -XPath "//mapping" | Select-Object –ExpandProperty "node"
            $updateNodes = $nodes | Where-Object { $_.url -notlike "*-cb.xml" }
            $latestUpdate = $updateNodes | Select-Object -Last 1

            # Read the XML listed in the most revent update
            $Content = Invoke-WebContent -Uri $latestUpdate.url
            If ($Null -ne $Content) {
                Try {
                    [System.XML.XMLDocument] $xmlDocument = $Content
                }
                Catch [System.IO.IOException] {
                    Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert content to an XML object."
                    Throw $_.Exception.Message
                }
                Catch [System.Exception] {
                    Throw $_
                }

                # Select the update info
                $nodes = Select-Xml -Xml $xmlDocument -XPath "//information" | Select-Object –ExpandProperty "node"
                $Update = $nodes | Where-Object { $_.lang -eq "en" }

                ForEach ($arch in "x64", "x86") {
                    $PSObject = [PSCustomObject] @{
                        Version      = (($Update.version | Sort-Object -Descending) | Select-Object -First 1)
                        Architecture = $arch
                        URI          = $Update.url -replace "-au.exe", $script:resourceStrings.Applications.Java8.FileStrings[$arch]
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to read update feed [$Uri]."
    }
}
