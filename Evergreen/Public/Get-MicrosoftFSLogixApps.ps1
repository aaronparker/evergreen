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

    If (Test-PSCore) {
        Write-Warning "This function is currently unsupported on PowerShell Core. Please use Windows PowerShell."
    }
    Else {
        #region Get Microsoft FSLogix Apps agent details from the aka.ms link
        $iwrParams = @{
            Uri                = $res.Get.Uri
            UseBasicParsing    = $True
            MaximumRedirection = 0
            ErrorAction        = $script:resourceStrings.Preferences.ErrorAction
        }
        $response = Invoke-WebRequest @iwrParams
        
        # Check returned URL. It should be a go.microsoft.com/fwlink/?linkid style link
        If ($response.Headers.Location -match $res.Get.MatchFwlink) {

            # Follow the link
            $iwrParams = @{
                Uri                = $response.Headers.Location
                UseBasicParsing    = $True
                MaximumRedirection = 0
                ErrorAction        = $script:resourceStrings.Preferences.ErrorAction
            }
            $response = Invoke-WebRequest @iwrParams

            # Construct the output; Return the custom object to the pipeline
            If ($response.Headers.Location -match $res.Get.MatchFile) {

                # Grab the version number from the link
                $response.Headers.Location -match $res.Get.MatchVersion | Out-Null

                $PSObject = [PSCustomObject] @{
                    Version = $matches[0]
                    Date    = (ConvertTo-DateTime -DateTime $response.Headers.Date)
                    URI     = $response.Headers.Location
                }
                Write-Output -InputObject $PSObject
            }
            #endregion
        }
    }
}
