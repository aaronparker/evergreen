Function Get-VMwareTools {
    <#
        .SYNOPSIS
            Get the current version and download URL for the VMware Tools.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Read the VMware version-mapping file
    $params = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
        Raw         = $True
    }
    $Content = Invoke-WebRequestWrapper @params
    If ($Null -eq $Content) {
        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to return usable content from $($res.Get.Update.Uri)."
    }
    Else {
        # Format the results returns and convert into an array that we can sort and use
        $Lines = $Content | Where-Object { $_ –notmatch "^#" }
        $Lines = $Lines | ForEach-Object { $_ -replace '\s+', ',' }
        $VersionTable = $Lines | ConvertFrom-Csv -Delimiter "," -Header $res.Get.Update.CsvHeaders | `
            Sort-Object -Property { [Int] $_.Client } -Descending
        $LatestVersion = $VersionTable | Select-Object -First 1

        # Build the output object for each platform and architecture
        ForEach ($platform in $res.Get.Download.Platforms) {
            ForEach ($architecture in $res.Get.Download.Architecture) {

                # Query the download page for the download file name
                $Uri = ("$($res.Get.Download.Uri)$platform/$architecture/index.html").ToLower()
                $Content = Invoke-WebRequestWrapper -Uri $Uri
                $filename = [RegEx]::Match($Content, $res.Get.Download.MatchFileName).Captures.Value

                # Build the output object
                $PSObject = [PSCustomObject] @{
                    Version      = $LatestVersion.Version
                    Platform     = $platform
                    Architecture = $architecture
                    URI          = "$($res.Get.Download.Uri)$($platform.ToLower())/$architecture/$filename"
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
