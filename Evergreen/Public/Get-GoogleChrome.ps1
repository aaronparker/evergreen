Function Get-GoogleChrome {
    <#
        .SYNOPSIS
            Returns the available Google Chrome versions.

        .DESCRIPTION
            Returns the available Google Chrome versions across all platforms and channels by querying the offical Google version JSON.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .PARAMETER Platform
            Specify the platform/s to return versions for. Supports all available platforms - Windows, macOS.

        .EXAMPLE
            Get-GoogleChromeVersion

            Description:
            Returns the available Google Chrome versions across all platforms and channels.

        .EXAMPLE
            Get-GoogleChromeVersion -Platform win64 -Channel stable

            Description:
            Returns the Google Chrome version for the current stable release on 64-bit Windows.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param (
        [Parameter()]
        [ValidateSet('win', 'win64', 'mac')]
        [System.String[]] $Platform = @('win', 'win64', 'mac')
    )

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Read the JSON and convert to a PowerShell object. Return the current release version of Chrome
    $Content = Invoke-WebContent -Uri $res.Get.Uri

    # Read the JSON and build an array of platform, channel, version
    If ($Null -ne $Content) {
        $Json = $Content | ConvertFrom-Json
        $releases = New-Object -TypeName System.Collections.ArrayList
        ForEach ($os in $Json) {
            $stable = $os.versions | Where-Object { $res.Get.Channels -contains $_.channel }
            ForEach ($version in $stable) {
                $PSObject = [PSCustomObject] @{
                    Version  = $version.current_version
                    Platform = $version.os
                    Date     = ([DateTime]::ParseExact($version.current_reldate.Trim(), 'MM/dd/yy', [CultureInfo]::InvariantCulture))
                    URI      = "$($res.Get.DownloadUri)$($res.Get.Downloads.$($version.os))"
                }
                $releases.Add($PSObject) | Out-Null
            }
        }

        # Filter the output; Return output to the pipeline
        $filteredReleases = $releases | Where-Object { $Platform -contains $_.Platform }
        Write-Output -InputObject $filteredReleases
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to return content from $($res.Get.Uri)."
    }
}
