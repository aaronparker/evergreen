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

        .EXAMPLE
            Get-GoogleChrome

            Description:
            Returns the available Google Chrome versions and download URLs.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param ()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Read the JSON and convert to a PowerShell object. Return the current release version of Chrome
    $Content = Invoke-WebContent -Uri $res.Get.Uri

    If ($Null -ne $Content) {
        
        # Convert the returned JSON content to an object
        $Json = $Content | ConvertFrom-Json

        # Read the JSON and build an array of platform, channel, version
        ForEach ($platform in $res.Get.Platforms.GetEnumerator()) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): $($platform.Name)."
            $stable = $Json.versions | Where-Object { ($_.channel -eq $res.Get.Channel) -and ($_.os -eq $platform.Name) }  
            ForEach ($version in $stable) {
                $PSObject = [PSCustomObject] @{
                    Version      = $version.current_version
                    Architecture = Get-Architecture -String $version.os
                    Date         = ConvertTo-DateTime -DateTime $version.current_reldate.Trim() -Pattern $res.Get.DatePattern
                    URI          = "$($res.Get.DownloadUri)$($res.Get.Platforms[$platform.Key])"
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to return content from $($res.Get.Uri)."
    }
}
