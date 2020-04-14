Function Get-Zoom {    
    <#
        .SYNOPSIS
            Get the current version and download URL for Zoom.

        .NOTES
            Author: Trond Eirik Haavarstein
            Twitter: @xenappblog
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-Zoom

            Description:
            Returns the current version and download URL for Zoom.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    #region Zoom for Windows clients and plug-ins
    ForEach ($installer in $res.Get.WindowsUris.GetEnumerator()) {

        # Follow the download link which will return a 301/302
        $redirectUrl = Resolve-Uri -Uri $res.Get.WindowsUris[$installer.Key]
        $regexMatch = [Regex]::Match($redirectUrl, $res.Get.MatchVersion)
        $Version = "Unknown"
        If ($regexMatch.Success -eq $true) {
            $Version = $regexMatch.Value
        }

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version  = $Version
            Platform = "Windows"
            Type     = $installer.Name
            URI      = [RegEx]::Match($redirectUrl, $res.Get.MatchUrl).Captures.Groups[1].Value
        }
        Write-Output -InputObject $PSObject
    }
    #endregion

    #region Zoom for Virtual Desktops (Citrix)
    ForEach ($installer in $res.Get.CitrixVDIUris.GetEnumerator()) {

        # Follow the download link which will return a 301/302
        $redirectUrl = Resolve-Uri -Uri $res.Get.CitrixVDIUris[$installer.Key]

        # Match version number from the download URL
        If ($redirectUrl -match $res.Get.MatchVersion) {
            $Version = $Matches[0]
        }
        Else {
            $Version = "Unknown"
        }

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version  = $Version
            Platform = "Citrix"
            Type     = $installer.Name
            URI      = [RegEx]::Match($redirectUrl, $res.Get.MatchUrl).Captures.Groups[1].Value
        }
        Write-Output -InputObject $PSObject
    }
    #endregion

    #region Zoom for Virtual Desktops (VMware)
    ForEach ($installer in $res.Get.VMwareVDIUris.GetEnumerator()) {

        # Follow the download link which will return a 301/302
        $redirectUrl = Resolve-Uri -Uri $res.Get.VMwareVDIUris[$installer.Key]

        # Match version number from the download URL
        If ($redirectUrl -match $res.Get.MatchVersion) {
            $Version = $Matches[0]
        }
        Else {
            $Version = "Unknown"
        }

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version  = $Version
            Platform = "VMware"
            Type     = $installer.Name
            URI      = [RegEx]::Match($redirectUrl, $res.Get.MatchUrl).Captures.Groups[1].Value
        }
        Write-Output -InputObject $PSObject
    }
    #endregion
}
