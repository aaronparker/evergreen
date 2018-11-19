Function Get-GoogleChromeUri {
    <#
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>

    # https://cloud.google.com/js/chrome_download.min.js

    $rootUri = "https://dl.google.com"
    $output = [PSCustomObject]@{
        WIN64_MSI      = "$($rootUri)/dl/chrome/install/googlechromestandaloneenterprise64.msi"
        WIN64_MSI_BETA = "$($rootUri)/dl/chrome/install/beta/googlechromebetastandaloneenterprise64.msi"
        WIN_MSI        = "$($rootUri)/dl/chrome/install/googlechromestandaloneenterprise.msi"
        WIN_MSI_BETA   = "$($rootUri)/dl/chrome/install/beta/googlechromebetastandaloneenterprise.msi"
        WIN64_BUNDLE   = "$($rootUri)/dl/chrome/install/GoogleChromeEnterpriseBundle64.zip"
        WIN_BUNDLE     = "$($rootUri)/dl/chrome/install/GoogleChromeEnterpriseBundle.zip"
        MAC            = "$($rootUri)/chrome/mac/stable/GGRO/googlechrome.dmg"
        ADMADMX        = "$($rootUri)/dl/edgedl/chrome/policy/policy_templates.zip"
        ADM            = "$($rootUri)/update2/enterprise/GoogleUpdate.adm"
        ADMX           = "$($rootUri)/dl/update2/enterprise/googleupdateadmx.zip"
        POLICY_DEV     = "$($rootUri)https://dl.google.com/chrome/policy/dev_policy_templates.zip"
        POLICY_BETA    = "$($rootUri)https://dl.google.com/chrome/policy/beta_policy_templates.zip"
    }
    Write-Output $output
}
