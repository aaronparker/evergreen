Function Get-Gimp {
    <#
        .SYNOPSIS
            Get the current version and download URL for GIMP.

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

    #region Get GIMP details        
    # Query the GIMP update URI to get the JSON
    try {
        $updateFeed = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri
    }
    catch {
        Throw "Failed to resolve update feed: $($res.Get.Update.Uri)."
        Break
    }
    If ($Null -ne $updateFeed) {

        # Grab latest version, sort by descending version number 
        $Latest = $updateFeed.STABLE | `
            Sort-Object -Property @{ Expression = { [System.Version]$_.version }; Descending = $true } | `
            Select-Object -First 1
        $MinorVersion = [System.Version] $Latest.version

        If ($Null -ne $Latest) {
            # Grab the latest Windows release, sort by descending date
            $LatestWin = $Latest.windows | `
                Sort-Object -Property @{ Expression = { [System.DateTime]::ParseExact($_.date, "yyyy-MM-dd", $Null) }; Descending = $true } | `
                Select-Object -First 1

            If ($Null -ne $LatestWin) {
                
                # Build the download URL
                $Uri = ($res.Get.Download.Uri -replace $res.Get.Download.ReplaceFileName, $LatestWin.filename) -replace $res.Get.Download.ReplaceVersion, "$($MinorVersion.Major).$($MinorVersion.Minor)"
            
                # Follow the download link which will return a 301/302
                try {
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Resolving: $Uri."
                    $redirectUrl = Resolve-InvokeWebRequest -Uri $Uri
                }
                catch {
                    Throw "$($MyInvocation.MyCommand): Failed to resolve mirror from: $Uri."
                }
            
                # Construct the output; Return the custom object to the pipeline
                If ($Null -ne $redirectUrl) {
                    $PSObject = [PSCustomObject] @{
                        Version = $Latest.version
                        Date    = ConvertTo-DateTime -DateTime $LatestWin.date -Pattern $res.Get.Update.DatePattern
                        Sha256  = $LatestWin.sha256
                        URI     = $redirectUrl
                    }
                    Write-Output -InputObject $PSObject
                }
                Else {
                    Throw "$($MyInvocation.MyCommand): Failed to return a useable URL from $Uri."
                }
            }
            Else {
                Throw "$($MyInvocation.MyCommand): Failed to determine the latest Windows release."      
            }
        }
        Else {
            Throw "$($MyInvocation.MyCommand): Failed to determine the latest Gimp release."      
        }
    }
    Else {
        Throw "$($MyInvocation.MyCommand): unable to retrieve content from $($res.Get.Update.Uri)."
    }
    #endregion
}
