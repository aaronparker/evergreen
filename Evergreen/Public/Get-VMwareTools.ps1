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
    $Content = Invoke-WebContent -Uri $res.Get.Uri -Raw

    If ($Null -ne $Content) {
        # Format the results returns and convert into an array that we can sort and use
        $Lines = $Content | Where-Object { $_ –notmatch "^#" }
        $Lines = $Lines | ForEach-Object { $_ -replace '\s+', ',' }
        $VersionTable = $Lines | ConvertFrom-Csv -Delimiter "," -Header 'Client', 'Server', 'Version', 'Build' | Sort-Object -Property Server -Descending

        ForEach ($platform in $res.Get.Platforms) {
            ForEach ($architecture in $res.Get.Architecture) {

                # Query the download page for the download file name
                $Uri = ("$($res.Get.DownloadUri)$platform/$architecture/index.html").ToLower()
                $Content = Invoke-WebContent -Uri $Uri
                $Line = ($Content.split("`n") | `
                            Select-String -Pattern $res.Get.MatchFileName).ToString().Trim()
                $filename = (($Line.Replace(" ", "").Split("=") | `
                                Select-String -Pattern $res.Get.MatchFileName).ToString().Trim().Split("`""))[1]                        
            
                # Build the output object
                $PSObject = [PSCustomObject] @{
                    Version      = ($VersionTable | Select-Object -First 1).Version
                    Platform     = $platform
                    Architecture = $architecture
                    URI          = "https://packages.vmware.com/tools/esx/latest/$($platform.ToLower())/$architecture/$filename"
                    ESXi         = (($VersionTable | Select-Object -First 1).Server -replace "esx/", "")
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
