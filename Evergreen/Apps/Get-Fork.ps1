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
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Filter
    )

    # Get latest version from the update API
    $params = @{
        Uri = $res.Get.Update.Uri
    }
    $Content = Invoke-RestMethodWrapper @params

    If ($Content) {
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
            URI     = $res.Get.Download.Uri
        }
        Write-Output -InputObject $PSObject
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to return content from the update API."
    }
}
