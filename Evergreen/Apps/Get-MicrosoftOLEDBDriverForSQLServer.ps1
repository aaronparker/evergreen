function Get-MicrosoftOLEDBDriverForSQLServer {
    <#
        .SYNOPSIS

    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    foreach ($language in $res.Get.Download.Language.GetEnumerator()) {
        foreach ($Url in $res.Get.Download.Uri) {

            # Construct the URL to include the language
            $Query = "&clcid="
            $Uri = "$($Url)$($Query)$($res.Get.Download.Language[$language.key])"
            $params = @{
                Uri                = $Uri
                MaximumRedirection = $res.Get.Download.MaximumRedirection
            }
            Resolve-MicrosoftFwLink @params | ForEach-Object { $_.Language = $language.key; $_ } | Write-Output
        }
    }
}
