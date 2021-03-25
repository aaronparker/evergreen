Function Get-Fork {
    <#
        .SYNOPSIS
            Get the current version and download URL for Fork.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-Fork

            Description:
            Returns the current version and download URLs for Fork.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Get latest version from the update API
    $params = @{
        Uri = $res.Get.Update.Uri
    }
    $Content = Invoke-RestMethodWrapper @params

    If ($Content) {
        # Parse the returned content and match the version number
        try {
            $Line = ($Content -split "\n")[-1]
            Write-Verbose -Message "$($MyInvocation.MyCommand): Checking string for version match: [$Line]."
            $Version = [RegEx]::Match(($Content -split "\n")[-1], $res.Get.Update.MatchVersion).Captures.Groups[1].Value
        }
        catch {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Failed to match version number."
            $Version = "Unknown"
        }

        # Convert the returned release data into a useable object with Version, URI etc.
        $PSObject = [PSCustomObject] @{
            Version = $Version
            URI     = $res.Get.Download.Uri
        }
        Write-Output -InputObject $PSObject
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to return content from the update API."
    }
}
