Function Get-MicrosoftFSLogixApps {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Microsoft FSLogix Apps agent.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-MicrosoftFSLogixApps

            Description:
            Returns the current version and download URL for the Microsoft FSLogix Apps agent.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    #region Follow the download link which will return a 301
    If (Test-PSCore) {
        Try {
            #Get Microsoft FSLogix Apps agent details from the aka.ms link
            $iwrParams = @{
                Uri                = $res.Get.Uri
                UseBasicParsing    = $True
                MaximumRedirection = 0
                ErrorAction        = $script:resourceStrings.Preferences.ErrorAction
            }
            $response = Invoke-WebRequest @iwrParams
        }
        Catch {
            $redirectUrl = $_.Exception.Response.Headers.Location.AbsoluteUri
        }
    }
    Else {
        #Get Microsoft FSLogix Apps agent details from the aka.ms link
        $iwrParams = @{
            Uri                = $res.Get.Uri
            UseBasicParsing    = $True
            MaximumRedirection = 0
            ErrorAction        = $script:resourceStrings.Preferences.ErrorAction
        }
        $response = Invoke-WebRequest @iwrParams
        $redirectUrl = $response.Headers.Location
    }
    #endregion
        
    #region Check returned URL. It should be a go.microsoft.com/fwlink/?linkid style link
    If ($redirectUrl -match $res.Get.MatchFwlink) {

        If (Test-PSCore) {
            Try {
                #Get Microsoft FSLogix Apps agent details from the aka.ms link
                $iwrParams = @{
                    Uri                = $redirectUrl
                    UseBasicParsing    = $True
                    MaximumRedirection = 0
                    ErrorAction        = $script:resourceStrings.Preferences.ErrorAction
                }
                $response = Invoke-WebRequest @iwrParams
            }
            Catch {
                $nextRedirectUrl = $_.Exception.Response.Headers.Location.AbsoluteUri
                $dateTime = $_.Exception.Response.Headers.Date.DateTime
            }
        }
        Else {
            #Get Microsoft FSLogix Apps agent details from the aka.ms link
            $iwrParams = @{
                Uri                = $redirectUrl
                UseBasicParsing    = $True
                MaximumRedirection = 0
                ErrorAction        = $script:resourceStrings.Preferences.ErrorAction
            }
            $response = Invoke-WebRequest @iwrParams
            $nextRedirectUrl = $response.Headers.Location
            $dateTime = $response.Headers.Date
        }

        # Construct the output; Return the custom object to the pipeline
        If ($nextRedirectUrl -match $res.Get.MatchFile) {

            # Grab the version number from the link
            $nextRedirectUrl -match $res.Get.MatchVersion | Out-Null

            $PSObject = [PSCustomObject] @{
                Version = $matches[0]
                Date    = (ConvertTo-DateTime -DateTime $dateTime)
                URI     = $nextRedirectUrl
            }
            Write-Output -InputObject $PSObject
        }
        Else {
            Write-Warning -Message "Failed to return a useable URL from $redirectUrl." 
        }
    }
    Else {
        Write-Warning -Message "Failed to return a useable URL from $($res.Get.Uri)."
    }
    #endregion
}
