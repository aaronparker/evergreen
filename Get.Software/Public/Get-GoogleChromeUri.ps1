Function Get-GoogleChromeUri {
    <#
        .SYNOPSIS
            Returns the Google Chrome Enterprise download URIs.

        .DESCRIPTION
            Returns the Google Chrome Enterprise download URIs, based on details found in https://cloud.google.com/js/chrome_download.min.js.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Get.Software

        .EXAMPLE
            Get-GoogleChromeUri

            Description:
            Returns the Google Chrome Enterprise platforms and download URIs.
#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False)]
        [string] $Uri = "https://dl.google.com"
    )
    
    # Construct the output array with platform and URIs
    $output = [PSCustomObject]@{
        WIN64_MSI      = "$($Uri)/dl/chrome/install/googlechromestandaloneenterprise64.msi"
        WIN64_MSI_BETA = "$($Uri)/dl/chrome/install/beta/googlechromebetastandaloneenterprise64.msi"
        WIN_MSI        = "$($Uri)/dl/chrome/install/googlechromestandaloneenterprise.msi"
        WIN_MSI_BETA   = "$($Uri)/dl/chrome/install/beta/googlechromebetastandaloneenterprise.msi"
        WIN64_BUNDLE   = "$($Uri)/dl/chrome/install/GoogleChromeEnterpriseBundle64.zip"
        WIN_BUNDLE     = "$($Uri)/dl/chrome/install/GoogleChromeEnterpriseBundle.zip"
        MAC            = "$($Uri)/chrome/mac/stable/GGRO/googlechrome.dmg"
        ADMADMX        = "$($Uri)/dl/edgedl/chrome/policy/policy_templates.zip"
        ADM            = "$($Uri)/update2/enterprise/GoogleUpdate.adm"
        ADMX           = "$($Uri)/dl/update2/enterprise/googleupdateadmx.zip"
        POLICY_DEV     = "$($Uri)/chrome/policy/dev_policy_templates.zip"
        POLICY_BETA    = "$($Uri)/chrome/policy/beta_policy_templates.zip"
    }
    Write-Output $output
}
