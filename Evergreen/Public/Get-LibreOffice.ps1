Function Get-LibreOffice {
    <#
        .SYNOPSIS
            Gets the latest LibreOffice version and download URIs.

        .DESCRIPTION
            Gets the latest LibreOffice version and download URIs, including help packs / language packs for Windows and macOS.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-LibreOffice

            Description:
            Returns the latest LibreOffice version and download URIs for the installers and language packs for Windows and macOS.

        .EXAMPLE
            Get-LibreOffice | Where-Object { ($_.Language -eq "Neutral") -and ($_.Platform -eq "Windows") }

            Description:
            Returns the latest LibreOffice for Windows version and installer download URI.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param ()

    $DownloadUri = $script:resourceStrings.Applications.LibreOffice.Uri
    $r = Invoke-WebRequest -Uri "$DownloadUri/"
    $versions = ($r.Links | `
                Where-Object { $_.href -match $script:resourceStrings.Applications.LibreOffice.MatchVersion }).href -replace "/", ""
    $Version = $versions | Sort-Object -Descending | Select-Object -First 1
    
    #$Platforms = @("win", "mac")
    ForEach ($platform in $script:resourceStrings.Applications.LibreOffice.Platforms.GetEnumerator()) {
        $r = Invoke-WebRequest -Uri "$DownloadUri/$Version/$($platform.Name)/"
        $Architectures = ($r.Links | `
                    Where-Object { $_.href -match $script:resourceStrings.Applications.LibreOffice.MatchArchitectures }).href -replace "/", ""
    
        ForEach ($architecture in $Architectures) {
            $r = Invoke-WebRequest -Uri "$DownloadUri/$Version/$($platform.Name)/$architecture/"
            $Files = ($r.Links | `
                        Where-Object { $_.href -match $script:resourceStrings.Applications.LibreOffice.MatchFiletypes }).href -replace "/", ""
    
            ForEach ($file in ($Files | Where-Object { $_ -notlike "*sdk*" })) {
    
                # Match language string
                Remove-Variable Language -ErrorAction SilentlyContinue
                Remove-Variable match -ErrorAction SilentlyContinue
                $match = $file | Select-String -Pattern $script:resourceStrings.Applications.LibreOffice.MatchLanguage
                If ($Null -ne $match) {
                    $Language = $match.Matches.Groups[1].Value
                }
                Else {
                    $Language = $script:resourceStrings.Applications.LibreOffice.NoLanguage
                }
    
                # Construct the output; Return the custom object to the pipeline
                $PSObject = [PSCustomObject] @{
                    Version      = $Version
                    Platform     = $script:resourceStrings.Applications.LibreOffice.Platforms[$platform.Key]
                    Architecture = $architecture
                    Language     = $Language
                    URI          = $("$DownloadUri/$Version/$($platform.Name)/$architecture/$file")
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
