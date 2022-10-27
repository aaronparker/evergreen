function Remove-ProxyEnv {
    <#
        .SYNOPSIS
            Remove proxy server and credentials information from environment variables
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
    )

    begin {}
    process {
        try {
            Remove-Variable -Name "EvergreenProxy" -Scope "Script" -Force -ErrorAction "SilentlyContinue"
            Remove-Variable -Name "EvergreenProxyCreds" -Scope "Script" -Force -ErrorAction "SilentlyContinue"
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to remove proxy variables."
        }
    }
}
