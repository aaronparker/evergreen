Function Get-JetBrainsIntelliJIDEA {
    <#
        .SYNOPSIS
            Get the current version and download URLs for each edition of IntelliJ IDEA.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    ForEach ($Edition in $res.Get.Update.Editions.GetEnumerator()) {

        # Build the update uri based on the edition
        $uri = $res.Get.Update.Uri -replace $res.Get.Update.ReplaceEdition, $Edition.Value

        # Query the Jetbrains URI to get the JSON
        $updateFeed = Invoke-RestMethodWrapper -Uri $uri

        If ($Null -ne $updateFeed) {

            # Construct the output; Return the custom object to the pipeline

            $PSObject = [PSCustomObject] @{
                Version = $updateFeed.$($Edition.Value).version
                Build   = $updateFeed.$($Edition.Value).build
                Edition = $Edition.Key
                Date    = ConvertTo-DateTime -DateTime $updateFeed.$($Edition.Value).date -Pattern $res.Get.Update.DatePattern
                Size    = $updateFeed.$($Edition.Value).downloads.windows.size
                Sha256  = $updateFeed.$($Edition.Value).downloads.windows.checksumLink
                URI     = $updateFeed.$($Edition.Value).downloads.windows.link
            }
            Write-Output -InputObject $PSObject
        }
        Else {
            Throw "$($MyInvocation.MyCommand): unable to retrieve content from $($uri)."
        }
    }
}
