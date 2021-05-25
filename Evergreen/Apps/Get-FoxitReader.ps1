Function Get-FoxitReader {
    <#
        .SYNOPSIS
            Get the current version and download URL for Foxit Reader.

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
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Filter
    )

    # Query the Foxit Reader package download form to get the JSON
    # TODO: Fix issue with Invoke-RestMethodWrapper that produces "Operation is not valid due to the current state of the object."
    $updateFeed = Invoke-RestMethod -Uri $res.Get.Update.Uri -UseBasicParsing

    If ($Null -ne $updateFeed) {

        # Grab latest version
        $Version = ($updateFeed.package_info.version | Sort-Object { [Version]$_ } -Descending) | Select-Object -First 1
        Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version."

        # Build the output object for each language. Excludes languages with out-of-date versions
        ForEach ($language in ($updateFeed.package_info.language | Where-Object { $_ -notin $res.Get.Update.SkipLanguages })) {
            
            # Build the download URL; Follow the download link which will return a 301/302
            Write-Verbose -Message "$($MyInvocation.MyCommand): Return details for language: $language."
            $Uri = (($res.Get.Download.Uri -replace "#Version", $Version) -replace "#Language", $language) -replace "#Package", $updateFeed.package_info.type[0]
            Write-Verbose -Message "$($MyInvocation.MyCommand): Attempting to resolve URI: $Uri."
            $redirectUrl = Resolve-SystemNetWebRequest -Uri $Uri
            
            # Construct the output; Return the custom object to the pipeline
            If ($Null -ne $redirectUrl) {
                $PSObject = [PSCustomObject] @{
                    Version  = $Version
                    Date     = ConvertTo-DateTime -DateTime $updateFeed.package_info.release -Pattern $res.Get.Update.DateTimePattern
                    Language = $language
                    URI      = $redirectUrl.ResponseUri.AbsoluteUri
                }
                Write-Output -InputObject $PSObject
            }
            Else {
                Write-Warning -Message "$($MyInvocation.MyCommand): Failed to return a useable URL from $Uri."
            }
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): unable to retrieve content from $($res.Get.Uri)."
    }
}
