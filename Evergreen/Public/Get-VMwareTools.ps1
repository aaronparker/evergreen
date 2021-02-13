Function Get-VMwareTools {
    <#
        .SYNOPSIS
            Get the current version and download URL for the VMware Tools.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-VMwareTools

            Description:
            Returns the current version and download URLs for VMware Tools.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Read the VMware version-mapping file
    $Content = Invoke-WebRequestWrapper -Uri $res.Get.Update.Uri -Raw

    If ($Null -ne $Content) {
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
