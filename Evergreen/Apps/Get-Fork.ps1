Function Get-Fork {
    <#
        .SYNOPSIS
            Get the current version and download URL for Fork.

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

    # Get latest version from the update API
    $params = @{
        Uri = $res.Get.Update.Uri
    }
    $Content = Invoke-EvergreenRestMethod @params
    if ($null -ne $Content) {
        try {
            # Parse the returned content and match the version number
            # Content returned as a single string - split into lines and return the last line (with the latest version number)
            $Line = ($Content -split "\n")[-1]
            Write-Verbose -Message "$($MyInvocation.MyCommand): Checking string for version match: [$Line]."
            $Version = [RegEx]::Match($Line, $res.Get.Update.MatchVersion).Captures.Groups[1].Value
        }
        catch {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Failed to match version number."
            $Version = "Unknown"
        }

        # Convert the returned release data into a useable object with Version, URI etc.
        $PSObject = [PSCustomObject] @{
            Version = $Version
            URI     = (Resolve-SystemNetWebRequest -Uri $res.Get.Download.Uri).ResponseUri.AbsoluteUri
        }
        Write-Output -InputObject $PSObject
    }
}
