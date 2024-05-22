function Get-MicrosoftSsms {
    <#
        .SYNOPSIS
            Returns the latest SQL Server Management Studio

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "Product name is a plural")]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Follow the https://go.microsoft.com/fwlink/?linkid= link to get to the update XML
    $UpdateFeed = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri
    if ($UpdateFeed -is [System.Xml.XmlElement]) {

        foreach ($Entry in $UpdateFeed) {
            foreach ($language in $res.Get.Download.Language.GetEnumerator()) {

                # Follow the download link which will return a 301
                $Query = "?clcid="
                $Uri = "$($Entry.link.href)$($Query)$($res.Get.Download.Language[$language.key])"
                $ResponseUri = Resolve-SystemNetWebRequest -Uri $Uri
                if ($ResponseUri.ResponseUri -is [System.Uri]) {

                    # Construct the output; Return the custom object to the pipeline
                    $PSObject = [PSCustomObject] @{
                        Version  = $Entry.component.version
                        Date     = ConvertTo-DateTime -DateTime ($UpdateFeed.updated.Split(".")[0]) -Pattern $res.Get.Update.DatePattern
                        Language = $language.key
                        URI      = $ResponseUri.ResponseUri.AbsoluteUri
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}
