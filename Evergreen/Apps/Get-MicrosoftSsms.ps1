Function Get-MicrosoftSsms {
    <#
        .SYNOPSIS
            Returns the latest SQL Server Management Studio release version number and download.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
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

    # Resolve the SSMS update feed
    $UpdateFeed = Resolve-SystemNetWebRequest -Uri $res.Get.Update.Uri

    # SQL Management Studio downloads/versions documentation
    $Content = Invoke-WebRequestWrapper -Uri $UpdateFeed.ResponseUri.AbsoluteUri -Raw

    # Convert content to XML document
    If ($Null -ne $Content) {
        Try {
            [System.XML.XMLDocument] $xmlDocument = $Content
        }
        Catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert feed into an XML object."
        }

        # Build an output object by selecting installer entries from the feed
        If ($xmlDocument -is [System.XML.XMLDocument]) {
            ForEach ($entry in $xmlDocument.feed.entry) {
                Write-Warning -Message "$($MyInvocation.MyCommand): Version returned from the update feed: $($entry.Component.version)."

                ForEach ($components in ($entry.component | Where-Object { $_.name -eq $res.Get.Download.MatchName })) {
                    ForEach ($language in $res.Get.Download.Language.GetEnumerator()) {

                        # Follow the download link which will return a 301
                        $Uri = $res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $res.Get.Download.Language[$language.key]
                        $ResponseUri = (Resolve-SystemNetWebRequest -Uri $Uri).ResponseUri.AbsoluteUri
            
                        # Check returned URL. It should be a go.microsoft.com/fwlink/?linkid style link
                        If ($Null -ne $ResponseUri) {

                            # Construct the output; Return the custom object to the pipeline
                            $PSObject = [PSCustomObject] @{
                                Version  = $entry.Component.version
                                Date     = ConvertTo-DateTime -DateTime ($entry.updated.Split(".")[0]) -Pattern $res.Get.Update.DatePattern
                                Title    = $entry.Title
                                Language = $language.key
                                URI      = $ResponseUri
                            }
                            Write-Output -InputObject $PSObject
                        }
                    }
                }
            }
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to read Microsoft SQL Server Management Studio update feed."
    }
}
