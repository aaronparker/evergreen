function Get-Minitab {
    <#
        .SYNOPSIS
            Get the current version and download URI for the supported releases of Minitab.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
    #>
    [CmdletBinding(SupportsShouldProcess = $false)]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    foreach ($Release in $res.Get.Download.Releases) {

        # Build the update uri based on the release number; Query the update feed; Convert from unicode
        $Uri = $res.Get.Update.Uri -replace $res.Get.Update.ReplaceRelease, $Release
        $UpdateFeed = Invoke-EvergreenWebRequest -Uri $Uri
        $Updates = [System.Text.Encoding]::Unicode.GetString($UpdateFeed)

        try {
            # Get the URI(s) from the Ini file; Get the Version(s) from the URI(s) found from the Ini file
            $URIs = [RegEx]::Matches($Updates, $res.Get.Update.MatchFile) | Select-Object -ExpandProperty "Value"
            $Versions = [RegEx]::Matches($URIs, $res.Get.Update.MatchVersion) | Select-Object -ExpandProperty "Value"
        }
        catch {
            #throw "$($MyInvocation.MyCommand): Failed to determine versions from updates returned from $Uri."
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to determine versions and URLs from: $Uri."
        }

        if ($null -ne $Versions) {
            # Grab latest version, sort by descending version number
            $LatestVersion = $Versions | `
                Sort-Object -Property @{ Expression = { [System.Version]$_ }; Descending = $true } | `
                Select-Object -First 1
            [System.String] $LatestURI = $URIs | Select-String -Pattern $LatestVersion
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $LatestVersion."
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found URL: $LatestURI."

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
}
