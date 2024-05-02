function Get-JetBrainsYouTrack {
    <#
        .SYNOPSIS
            Get the current version and download URLs for each edition of PhpStorm.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    $Output = Get-JetBrainsApp -res $res
    Write-Output -InputObject $Output
}
