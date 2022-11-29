Function Get-DockerDesktop {
    <#
        .SYNOPSIS
            Returns the available Docker Desktop versions.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    $Updates = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri

    foreach ($Update in $Updates) {
        if ($Null -ne $Update) {
            $PSObject = [PSCustomObject] @{
                Version = $Update.enclosure.shortVersionString
                Build   = $Update.enclosure.version
                Size    = $Update.enclosure.length
                Type    = Get-FileType -File $($Update.enclosure.url | Where-Object { $_ -match "\.exe$" } | Select-Object -First 1)
                URI     = $Update.enclosure.url | Where-Object { $_ -match "\.exe$" } | Select-Object -First 1
            }
            Write-Output -InputObject $PSObject
        }
    }

}
