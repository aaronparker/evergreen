function Get-Gimp {
    <#
        .SYNOPSIS
            Get the current version and download URL for GIMP.

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

    # Query the GIMP update URI to get the JSON
    $updateFeed = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri
    if ($null -ne $updateFeed) {

        foreach ($Channel in $res.Get.Update.Channels) {

            # Grab latest version, sort by descending version number
            try {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Get latest version for: $Channel."
                $Latest = $updateFeed.$Channel | `
                    Sort-Object -Property @{ Expression = { [System.Version]$_.version }; Descending = $true } -ErrorAction "Stop" | `
                    Select-Object -First 1 -ErrorAction "Stop"
                $MinorVersion = [System.Version] $Latest.version
                Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $($Latest.version)."
            }
            catch {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Fall back to first record for: $Channel."
                $Latest = $updateFeed.$Channel | Select-Object -First 1
                $MinorVersion = [System.Version] "$($Latest.version[0]).0"
            }

            if ($null -ne $Latest) {
                # Grab the latest Windows Channel, sort by descending date
                $LatestWin = $Latest.windows | `
                    Sort-Object -Property @{ Expression = { [System.DateTime]::ParseExact($_.date, "yyyy-MM-dd", $null) }; Descending = $true } | `
                    Select-Object -First 1

                if ($null -ne $LatestWin) {

                    # Build the download URL
                    $Uri = ($res.Get.Download.Uri -replace $res.Get.Download.ReplaceFileName, $LatestWin.filename) -replace $res.Get.Download.ReplaceVersion, "$($MinorVersion.Major).$($MinorVersion.Minor)"

                    # Follow the download link which will return a 301/302
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Resolving: $Uri."
                    $redirectUrl = Resolve-InvokeWebRequest -Uri $Uri

                    # Construct the output; Return the custom object to the pipeline
                    if ($null -ne $redirectUrl) {
                        $PSObject = [PSCustomObject] @{
                            Version  = $Latest.version
                            Revision = $(if ([System.String]::IsNullOrEmpty($Latest.windows.revision)) { "0" } else { $Latest.windows.revision[0] })
                            Date     = ConvertTo-DateTime -DateTime $LatestWin.date -Pattern $res.Get.Update.DatePattern
                            Channel  = (Get-Culture).TextInfo.ToTitleCase($Channel.ToLower())
                            Sha256   = $LatestWin.sha256
                            URI      = $redirectUrl
                        }
                        Write-Output -InputObject $PSObject
                    }
                }
            }
        }
    }
}
