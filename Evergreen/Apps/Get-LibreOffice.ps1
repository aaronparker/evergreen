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

    # Query the LibreOffice update API
    $iwcParams = @{
        Uri                  = $res.Get.Update.Uri
        UserAgent            = $res.Get.Update.UserAgent
        SkipCertificateCheck = $True
    }
    $Content = Invoke-RestMethodWrapper @iwcParams

    If ($Null -ne $Content) {
        Write-Verbose "$($MyInvocation.MyCommand): $($res.Get.Update.Uri) returned version: $($Content.description.version)."

        # Get downloads for each platform for the latest version
        ForEach ($platform in $res.Get.Download.Platforms.GetEnumerator()) {
            $iwrParams = @{
                Uri             = "$($res.Get.Download.Uri)/$($Content.description.version)/$($platform.Name)/"
                UseBasicParsing = $True
                ErrorAction     = "Continue"
            }
            $response = Invoke-WebRequest @iwrParams
            $Architectures = ($response.Links | Where-Object { $_.href -match $res.Get.Download.MatchArchitectures }).href -replace "/", ""
    
            ForEach ($arch in $Architectures) {

                # Get downloads for each architecture for the latest version/platform
                $iwrParams = @{
                    Uri             = "$($res.Get.Download.Uri)/$($Content.description.version)/$($platform.Name)/$arch/"
                    UseBasicParsing = $True
                    ErrorAction     = "Continue"
                }
                $response = Invoke-WebRequest @iwrParams
                $Files = ($response.Links | Where-Object { $_.href -match $res.Get.Download.MatchExtensions }).href -replace "/", ""
    
                ForEach ($file in ($Files | Where-Object { $_ -notlike "*sdk*" })) {
    
                    # Match language string
                    Remove-Variable -Name "Language", "match" -ErrorAction "SilentlyContinue"
                    $match = $file | Select-String -Pattern $res.Get.Download.MatchLanguage
                    If ($Null -ne $match) {
                        $Language = $match.Matches.Groups[1].Value
                    }
                    Else {
                        $Language = $res.Get.Download.NoLanguage
                    }
    
                    # Construct the output; Return the custom object to the pipeline
                    $PSObject = [PSCustomObject] @{
                        Version      = $($Content.description.version)
                        Architecture = $arch
                        Language     = $Language
                        URI          = $("$($res.Get.Download.Uri)/$($Content.description.version)/$($platform.Name)/$arch/$file")
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}
