Function Get-VMwareTools {
    <#
        .SYNOPSIS
            Get the current version and download URL for the VMware Tools.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson

            This functions scrapes the vendor web page to find versions and downloads.
            TODO: find a better method to find URLs
        
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
    $Content = Invoke-WebContent -Uri $res.Get.Uri -Raw

    If ($Null -ne $Content) {
        # Format the results returns and convert into an array that we can sort and use
        $Lines = $Content | Where-Object { $_ –notmatch "^#" }
        $Lines = $Lines | ForEach-Object { $_ -replace '\s+', ',' }
        $VersionTable = $Lines | ConvertFrom-Csv -Delimiter "," -Header $res.Get.CsvHeaders | Sort-Object -Property {[Version] $_.Version} -Descending

        # Match the latest version number
        If ($VersionTable[0].Server -match $reg.Get.MatchNoServer) {
            $Version = ($VersionTable | Select-Object -First 2 | Select-Object -Last 1).Version
        }
        Else {
            $Version = ($VersionTable | Select-Object -First 1).Version
        }

        # Build the output object for each platform and architecture
        ForEach ($platform in $res.Get.Platforms) {
            ForEach ($architecture in $res.Get.Architecture) {

                # Query the download page for the download file name
                $Uri = ("$($res.Get.DownloadUri)$platform/$architecture/index.html").ToLower()
                $Content = Invoke-WebContent -Uri $Uri
                $filename = [RegEx]::Match($Content, $res.Get.MatchFileName).Captures.Value
            
                # Build the output object
                $PSObject = [PSCustomObject] @{
                    Version      = $Version
                    Platform     = $platform
                    Architecture = $architecture
                    URI          = "https://packages.vmware.com/tools/esx/latest/$($platform.ToLower())/$architecture/$filename"
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
