function Get-JetBrainsApp {
    <#
        .SYNOPSIS
            Get the current version and download URLs for a JetBrains app
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $res
    )

    foreach ($Edition in $res.Get.Update.Editions.GetEnumerator()) {

        # Build the update uri based on the edition
        $uri = $res.Get.Update.Uri -replace $res.Get.Update.ReplaceEdition, $Edition.Value

        # Query the Jetbrains URI to get the JSON
        $UpdateFeed = Invoke-RestMethodWrapper -Uri $uri
        if ($null -ne $UpdateFeed) {

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version = $UpdateFeed.$($Edition.Value).version
                Build   = $UpdateFeed.$($Edition.Value).build
                Edition = $Edition.Key
                Date    = ConvertTo-DateTime -DateTime $UpdateFeed.$($Edition.Value).date -Pattern $res.Get.Update.DatePattern
                Size    = $UpdateFeed.$($Edition.Value).downloads.windows.size
                Sha256  = $UpdateFeed.$($Edition.Value).downloads.windows.checksumLink
                URI     = $UpdateFeed.$($Edition.Value).downloads.windows.link
            }
            Write-Output -InputObject $PSObject
        }
    }
}
