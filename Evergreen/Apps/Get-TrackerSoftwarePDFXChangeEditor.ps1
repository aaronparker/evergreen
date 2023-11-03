function Get-TrackerSoftwarePDFXChangeEditor {
    <#
        .SYNOPSIS
            Returns the current version and download URL for the Tracker Software PDF-XChange Editor.

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

    try {
        [System.XML.XMLDocument] $xmlDocument = Invoke-EvergreenWebRequest -Uri $res.Get.Update.Uri -Raw
    }
    catch [System.Exception] {
        throw "$($MyInvocation.MyCommand): failed to convert feed into an XML object with: $($_.Exception.Message)"
    }

    # Build an output object by selecting installer entries from the feed
    if ($xmlDocument -is [System.XML.XMLDocument]) {
        foreach ($bundle in $res.Get.Update.Bundles) {

            # Select the latest version
            $Item = $xmlDocument.TrackerUpdate.bundle | Where-Object { $_.id -eq $bundle }
            $Update = $Item.Update | `
                Sort-Object -Property @{ Expression = { [System.Version]$_.version }; Descending = $true } | `
                Select-Object -First 1

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = $Update.version
                Hash         = $Update.hash
                Architecture = Get-Architecture -String $Update.Url
                Type         = $Update.type
                URI          = $res.Get.Download.Uri -replace "#filename", $Update.url
            }
            Write-Output -InputObject $PSObject
        }
    }
}
