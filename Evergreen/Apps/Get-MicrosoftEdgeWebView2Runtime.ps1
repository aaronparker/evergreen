Function Get-MicrosoftEdgeWebView2Runtime {
    <#
        .SYNOPSIS
            Returns the available Microsoft Edge WebView2 Runtime versions and downloads.

        .NOTES
            Author: Aaron Parker
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Read the JSON and convert to a PowerShell object. Return the current release version of Edge
    $Feed = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri

    # Read the JSON and build an array of platform, channel, architecture, version
    if ($null -ne $Feed) {
        foreach ($Channel in $res.Get.Update.Channels) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Processing channel '$Channel'."
            $Filtered = $Feed | Where-Object { $_.Product -eq $Channel }
            foreach ($Platform in $res.Get.Update.Platforms) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Processing platform '$Platform'."
                $PlatformReleases = $Filtered.Releases | Where-Object { $_.Platform -eq "Windows" }

                # Sort for the latest release
                $LatestVersion = $PlatformReleases | Select-Object -ExpandProperty "ProductVersion" | `
                    Sort-Object -Property @{ Expression = { [System.Version]$_ }; Descending = $true } | `
                    Select-Object -First 1
                Write-Verbose -Message "$($MyInvocation.MyCommand): Latest version for $Channel on $Platform is $LatestVersion."

                # Create the output object/s
                foreach ($Release in ($PlatformReleases | Where-Object { $_.ProductVersion -eq $LatestVersion })) {

                    # Output object to the pipeline
                    $Url = $(Resolve-SystemNetWebRequest -Uri $res.Get.Download.Uri[$Release.Architecture]).ResponseUri.AbsoluteUri
                    $PSObject = [PSCustomObject] @{
                        Version      = $Release.ProductVersion
                        Channel      = $Channel
                        Architecture = $Release.Architecture
                        URI          = $Url
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}
