Function Get-AdobeAcrobatReaderDC {
    <#
        .SYNOPSIS
            Gets the download URLs for Adobe Acrobat Reader DC Continuous track installers.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
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

    #region Installer downloads
    ForEach ($language in $res.Get.Download.Languages) {

        try {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Searching download language: [$language]."
            $Uri = $res.Get.Download.Uri -replace "#Language", $language
            $params = @{
                Uri             = $Uri
                Headers         = $res.Get.Download.Headers
                #UseBasicParsing = $True
                #ErrorAction     = "Continue"
            }
            $Content = Invoke-RestMethodWrapper @params
        }
        catch {
            Throw "$($MyInvocation.MyCommand): $($_.Exception.Message)."
        }

        If ($Content) {
            ForEach ($item in $Content) {
                $PSObject = [PSCustomObject] @{
                    Version      = $item.Version
                    Language     = $language
                    Architecture = Get-Architecture -String $item.download_url
                    Name         = $item.Name
                    URI          = $item.download_url
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
    #endregion
}
