Function Get-VMwareTools {
    <#
        .SYNOPSIS
            Get the current version and download URL for the VMware Tools.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
        
        .LINK
            https://github.com/aaronparker/Get.Software

        .EXAMPLE
            Get-VMwareTools

            Description:
            Returns the current version and download URLs for VMware Tools.
    #>
    [CmdletBinding()]
    Param()    

    # Read the VMware version-mapping file
    $Content = Invoke-WebContent -Uri $script:resourceStrings.Applications.VMwareTools.Uri -Raw

    # Format the results returns and convert into an array that we can sort and use
    $Lines = $Content | Where-Object { $_ –notmatch "^#" }
    $Lines = $Lines | ForEach-Object { $_ -replace '\s+', ',' }
    $VersionTable = $Lines | ConvertFrom-Csv -Delimiter "," -Header 'Client', 'Server', 'Version', 'Build' | Sort-Object -Property Server -Descending

    ForEach ($platform in $script:resourceStrings.Applications.VMwareTools.Platforms) {
        ForEach ($architecture in $script:resourceStrings.Applications.VMwareTools.Architecture) {

            # Query the download page for the download file name
            $Uri = ("https://packages.vmware.com/tools/esx/latest/$platform/$architecture/index.html").ToLower()
            $Content = Invoke-WebContent -Uri $Uri
            $Line = ($Content.split("`n") | `
                        Select-String -Pattern $script:resourceStrings.Applications.VMwareTools.MatchFileName).ToString().Trim()
            $filename = (($Line.Replace(" ", "").Split("=") | `
                            Select-String -Pattern $script:resourceStrings.Applications.VMwareTools.MatchFileName).ToString().Trim().Split("`""))[1]                        
            
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
