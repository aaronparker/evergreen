Function Get-OperaGXBrowser {
    <#
        .SYNOPSIS
            Returns the available Opera GX Browser versions and download URIs.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    $Update = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri
    Write-Verbose -Message "$($MyInvocation.MyCommand): checking property: $($res.Get.Update.Property)."
    Write-Verbose -Message "$($MyInvocation.MyCommand): found version: $($Update.current_version)"
    If ($Null -ne $Update.($res.Get.Update.Property)) {

        # Step through each installer type
        ForEach ($item in $res.Get.Download.Uri.GetEnumerator()) {

            # Build the output object; Output object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = $Update.($res.Get.Update.Property)
                Architecture = $item.Name
                Type         = Get-FileType -File $res.Get.Download.Uri[$item.Key]
                URI          = $res.Get.Download.Uri[$item.Key] -replace $res.Get.Download.ReplaceText, $Update.($res.Get.Update.Property)
            }
            Write-Output -InputObject $PSObject
        }
    }
}
