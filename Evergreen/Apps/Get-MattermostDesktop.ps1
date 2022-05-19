Function Get-MattermostDesktop {
    <#
        .SYNOPSIS
            Returns the latest available Mattermost desktop version.

        .NOTES
            Author: BornToBeRoot
            Twitter: @_BornToBeRoot
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    $Content = Invoke-RestMethodWrapper $res.Get.Update.Uri
    if ($Null -ne $Content) {

        foreach ($Line in ($Content -split "\n")) {
            if ($Line -match $res.Get.Update.Match.Version) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): string to match: $Line"
                Write-Verbose -Message "$($MyInvocation.MyCommand):  regex to match: $($res.Get.Update.Match.Version)"
                $Version = ([RegEx]::Matches($Line, $res.Get.Update.Match.Version)).Groups[1].Value
            }
            if ($Line -match $res.Get.Update.Match.Url) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): string to match: $Line"
                Write-Verbose -Message "$($MyInvocation.MyCommand):  regex to match: $($res.Get.Update.Match.Url)"
                $Url = ([RegEx]::Matches($Line, $res.Get.Update.Match.Url)).Groups[1].Value
            }
        }

        foreach ($Url in $res.Get.Download.Uri) {
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Type         = Get-FileType -File $Url
                Architecture = Get-Architecture -String $Url
                URI          = $Url -replace "#version", $Version
            }
            Write-Output -InputObject $PSObject
        }
    }
}
