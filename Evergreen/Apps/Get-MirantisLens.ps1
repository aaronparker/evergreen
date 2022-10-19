Function Get-MirantisLens {
    <#
        .SYNOPSIS
            Returns the available Mirantis Lens versions.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification="Product name is a plural")]
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    ForEach ($Release in $res.Get.Update.Uri.GetEnumerator()) {
        $Update = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri[$Release.Key]
        If ($Null -ne $Update) {

            $PSObject = [PSCustomObject] @{
                Version      = $Update.Version
                Architecture = "x64"
                Release      = $Release.Name
                Date         = [System.DateTime]$Update.ReleaseDate
                Size         = $(($Update.Files | Select-Object -First 1).Size)
                Sha512       = $(($Update.Files | Select-Object -First 1).Sha512)
                URI          = $(Resolve-InvokeWebRequest -Uri $($res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $($Update.Files | Select-Object -First 1).Url))
            }
            Write-Output -InputObject $PSObject
        }
    }
}
