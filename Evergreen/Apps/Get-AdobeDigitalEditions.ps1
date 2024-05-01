Function Get-AdobeDigitalEditions {
    <#
        .SYNOPSIS
            Gets the version and download URLs for Adobe Digital Editions.

        .NOTES
            Author: Jasper Metselaar
            E-mail: jms@du.se
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "Product name is a plural")]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get the update feed
    $params = @{
        Uri          = $res.Get.Update.Uri
        Raw          = $true
        ReturnObject = "Content"
    }
    $UpdateFeed = Invoke-EvergreenWebRequest @params | ConvertFrom-Json -ErrorAction "Stop"
    if ($null -ne $UpdateFeed) {

        # Output the object to the pipeline
        foreach ($item in $UpdateFeed) {
            $PSObject = [PSCustomObject] @{
                Version = $item.version
                Type    = Get-FileType -File $item.SecuredDownloadPath
                URI     = $item.SecuredDownloadPath
            }
            Write-Output -InputObject $PSObject
        }
    }
}
