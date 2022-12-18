Function Get-GitHubDesktop {
    <#
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    $params = @{
        "Uri" = $res.Get.Update.Uri
    }
    $Update = Invoke-RestMethodWrapper @params
    if ($null -ne $Update) {
        $Version = $Update.Version | Sort-Object -Descending | Select-Object -First 1
        Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version."

        foreach ($Platform in $res.Get.Download.Uri.GetEnumerator()) {
            foreach ($Type in $res.Get.Download.Type.GetEnumerator()) {

                $Resolve = Resolve-SystemNetWebRequest -Uri "$($res.Get.Download.Uri[$Platform.Key])$($res.Get.Download.Type[$Type.Key])"
                $Uri = $Resolve.ResponseUri.AbsoluteUri

                if ($null -ne $Resolve) {
                    $PSObject = [PSCustomObject] @{
                        Version      = $Version
                        Architecture = Get-Architecture -String $Uri
                        Type         = Get-FileType -File $Uri
                        URI          = $Uri
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}
