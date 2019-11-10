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
    $Content = Invoke-WebContent -Uri $Uri

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
            ForEach ($item in (Select-Xml -Xml $xmlDocument -XPath "//item")) {
                If ((($item.Node.Title -replace $res.Get.TitleReplace, "") `
                            -match $Include) -and $item.Node.Title -notmatch $Exclude) {
                    $PSObject = [PSCustomObject] @{
                        Version     = $item.Node.title -replace $res.Get.RegExNumbers
                        Title       = $(($item.Node.title -replace $res.Get.TitleReplace, "") `
                                -replace $res.Get.RegExVersion)
                        Description = $item.Node.description
                        Date        = [DateTime]::Parse($item.Node.pubDate)
                        URI         = $item.Node.link
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
