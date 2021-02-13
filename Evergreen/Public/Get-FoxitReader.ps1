Function Get-FoxitReader {
    <#
        .SYNOPSIS
            Get the current version and download URL for Foxit Reader.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-FoxitReader

            Description:
            Returns the current version and download URL for Foxit Reader.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Query the Foxit Reader package download form to get the JSON
    $updateFeed = Invoke-RestMethodWrapper -Uri $res.Get.Uri
    If ($Null -ne $updateFeed) {

        # Grab latest version
        $Version = ($updateFeed.package_info.version | Sort-Object { [Version]$_ } -Descending) | Select-Object -First 1

        ForEach ($language in $updateFeed.package_info.language) {
            
            # Build the download URL
            $Uri = (($res.Get.DownloadUri -replace "#Version", $Version) -replace "#Language", $language) -replace "#Package", $updateFeed.package_info.type[0]
            
            # Follow the download link which will return a 301/302
            $redirectUrl = Resolve-InvokeWebRequest -Uri $Uri
            
            # Construct the output; Return the custom object to the pipeline
            If ($Null -ne $redirectUrl) {
                $PSObject = [PSCustomObject] @{
                    Version  = $Version
                    Date     = ConvertTo-DateTime -DateTime $updateFeed.package_info.release -Pattern $res.Get.DateTimePattern
                    Language = $language
                    URI      = $redirectUrl
                }
                Write-Output -InputObject $PSObject
            }
            Else {
                Write-Warning -Message "Failed to return a useable URL from $Uri."
            }
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): unable to retrieve content from $($res.Get.Uri)."
    }
}
