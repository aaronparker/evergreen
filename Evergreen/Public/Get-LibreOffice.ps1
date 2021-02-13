Function Get-LibreOffice {
    <#
        .SYNOPSIS
            Gets the latest LibreOffice version and download URIs, including help packs / language packs for Windows.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson

            This functions scrapes the vendor web page to find versions and downloads.
            TODO: find a better method to find version and URLs
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-LibreOffice

            Description:
            Returns the latest LibreOffice version and download URIs for the installers and language packs for Windows.

        .EXAMPLE
            Get-LibreOffice | Where-Object { $_.Language -eq "Neutral" -and $_.Architecture -eq "x64" }

            Description:
            Returns the latest LibreOffice for Windows version and installer download URI.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Query the LibreOffice update API
    $iwcParams = @{
        Uri                  = $res.Get.Uri
        UserAgent            = $res.Get.UserAgent
        Raw                  = $True
        SkipCertificateCheck = $True
    }
    $Content = Invoke-WebRequestWrapper @iwcParams

    If ($Null -ne $Content) {

        # Convert the content to XML to grab the version number
        Try {
            [System.XML.XMLDocument] $xmlDocument = $Content
        }
        Catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert feed into an XML object."
        }
        $Version = $xmlDocument.description.version
    
        # Get downloads for each platform for the latest version
        ForEach ($platform in $res.Get.Platforms.GetEnumerator()) {
            $iwrParams = @{
                Uri             = "$($res.Get.DownloadUri)/$Version/$($platform.Name)/"
                UseBasicParsing = $True
                ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
            }
            $response = Invoke-WebRequest @iwrParams
            $Architectures = ($response.Links | Where-Object { $_.href -match $res.Get.MatchArchitectures }).href -replace "/", ""
    
            ForEach ($arch in $Architectures) {

                # Get downloads for each architecture for the latest version/platform
                $iwrParams = @{
                    Uri             = "$($res.Get.DownloadUri)/$Version/$($platform.Name)/$arch/"
                    UseBasicParsing = $True
                    ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
                }
                $response = Invoke-WebRequest @iwrParams
                $Files = ($response.Links | Where-Object { $_.href -match $res.Get.MatchExtensions }).href -replace "/", ""
    
                ForEach ($file in ($Files | Where-Object { $_ -notlike "*sdk*" })) {
    
                    # Match language string
                    Remove-Variable Language -ErrorAction SilentlyContinue
                    Remove-Variable match -ErrorAction SilentlyContinue
                    $match = $file | Select-String -Pattern $res.Get.MatchLanguage
                    If ($Null -ne $match) {
                        $Language = $match.Matches.Groups[1].Value
                    }
                    Else {
                        $Language = $res.Get.NoLanguage
                    }
    
                    # Construct the output; Return the custom object to the pipeline
                    $PSObject = [PSCustomObject] @{
                        Version      = $Version
                        Platform     = $res.Get.Platforms[$platform.Key]
                        Architecture = $arch
                        Language     = $Language
                        URI          = $("$($res.Get.DownloadUri)/$Version/$($platform.Name)/$arch/$file")
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}
