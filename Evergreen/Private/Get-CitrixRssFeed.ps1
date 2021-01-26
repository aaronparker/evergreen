Function Get-CitrixRssFeed {
    <#
        .SYNOPSIS
            Get content from a citrix.com XML feed of notifications of new downloads.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy        
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNull()]
        [System.String] $Uri,

        [Parameter(Mandatory = $False, Position = 1)]
        [System.String] $Include,

        [Parameter(Mandatory = $False, Position = 2)]
        [System.String] $Exclude
    )

    # Read the Citrix RSS feed
    $Content = Invoke-WebRequestWrapper -Uri $Uri

    # Convert to XML document
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

            # Walk through each node to output details
            ForEach ($node in $nodes) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): matching [$($node.title)]"
                If (($node.title -match $Include) -and ($node.title -notmatch $Exclude)) {

                    # Match version number from the title, account for title strings without version numbers
                    try {
                        $Version = [RegEx]::Match($node.title, $res.Get.MatchVersion).Captures.Groups[1].Value 4>$Null
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version."
                    }
                    catch {
                        $Version = "Unknown"
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Unknown version."
                    }

                    # Output the version object
                    $PSObject = [PSCustomObject] @{
                        Version     = $Version
                        Title       = $node.title -replace $res.Get.TitleReplace, ""
                        Description = $node.description
                        Date        = $node.pubDate
                        #Date        = ConvertTo-DateTime -DateTime $node.pubDate -Pattern $res.Get.DatePattern
                        URI         = $node.link
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to read Citrix RSS feed [$Uri]."
    }
}
