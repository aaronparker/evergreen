Function Get-Minitab {
    <#
        .SYNOPSIS
            Get the current version and download URI for the supported releases of Minitab.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    ForEach ($Release in $res.Get.Download.Releases) {

        # Build the update uri based on the release number
        $uri = $res.Get.Update.Uri -replace $res.Get.Update.ReplaceRelease, $Release

        # Query the update feed
        $Updatefeed = Invoke-WebRequestWrapper $uri

        # Convert from unicode
        $Updates = [System.Text.Encoding]::Unicode.GetString($Updatefeed)

        # Get the URI(s) from the Ini file
        try {
            $URIs = [RegEx]::Matches($Updates, $res.Get.Update.MatchFile) | Select-Object -ExpandProperty Value
        }
        catch {
            Throw "$($MyInvocation.MyCommand): Failed to determine the download URI(s) from the Ini file."
        }

        # Get the Version(s) from the URI(s) found from the Ini file
        try {
            $Versions = [RegEx]::Matches($URIs, $res.Get.Update.MatchVersion) | Select-Object -ExpandProperty Value
        }
        catch {
            Throw "$($MyInvocation.MyCommand): Failed to determine Version(s) from the URI(s)."
        }

        # Grab latest version, sort by descending version number
        $LatestVersion = $Versions | `
            Sort-Object -Property @{ Expression = { [System.Version]$_ }; Descending = $true } | `
            Select-Object -First 1

        [System.String]$LatestURI = $URIs | Select-String -Pattern $LatestVersion

        # Build the output object
        $PSObject = [PSCustomObject] @{
            Version      = $LatestVersion
            Architecture = Get-Architecture -String $LatestURI
            Release      = $Release
            URI          = $LatestURI
        }
        Write-Output -InputObject $PSObject

    }
}
