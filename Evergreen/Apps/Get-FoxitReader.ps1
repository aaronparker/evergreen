function Get-FoxitReader {
    <#
        .SYNOPSIS
            Get the current version and download URL for Foxit Reader.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Query the Foxit Reader package download form to get the JSON
    # TODO: Fix issue with Invoke-EvergreenRestMethod that produces "Operation is not valid due to the current state of the object."
    # $params = @{
    #     Uri             = $res.Get.Update.Uri
    #     UseBasicParsing = $true
    # }
    # if (Test-ProxyEnv) {
    #     $params.Proxy = $script:EvergreenProxy
    # }
    # if (Test-ProxyEnv -Creds) {
    #     $params.ProxyCredential = $script:EvergreenProxyCreds
    # }
    # Write-Verbose -Message "$($MyInvocation.MyCommand): Query: $($res.Get.Update.Uri)"
    # $updateFeed = Invoke-RestMethod @params
    $UpdateFeed = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri

    if ($null -ne $UpdateFeed) {

        # Grab latest version. Removed Sort-Object because Foxit moved to a 5 part version number
        # $Version = ($updateFeed.package_info.version | Sort-Object { [System.Version]$_ } -Descending) | Select-Object -First 1
        $Version = $UpdateFeed.package_info.version | Select-Object -First 1

        if ($null -ne $Version) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version."

            # Build the output object for each language. Excludes languages with out-of-date versions
            foreach ($language in ($UpdateFeed.package_info.language | Get-Member -MemberType "NoteProperty")) {

                # Build the download URL; Follow the download link which will return a 301/302
                Write-Verbose -Message "$($MyInvocation.MyCommand): Return details for language: $($updateFeed.package_info.language.($language.Name))."
                $Uri = (($res.Get.Download.Uri -replace "#Version", $Version) -replace "#Language", $($updateFeed.package_info.language.($language.Name))) `
                    -replace "#Package", $updateFeed.package_info.type[0]
                $Url = $(Resolve-SystemNetWebRequest -Uri $Uri).ResponseUri.AbsoluteUri

                # Construct the output; Return the custom object to the pipeline
                if ($null -ne $Url) {
                    $PSObject = [PSCustomObject] @{
                        Version  = $Version
                        Date     = ConvertTo-DateTime -DateTime $updateFeed.package_info.release -Pattern $res.Get.Update.DateTimePattern
                        Language = $($updateFeed.package_info.language.($language.Name))
                        URI      = $Url
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}
