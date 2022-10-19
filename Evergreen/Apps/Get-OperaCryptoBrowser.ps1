function Get-OperaCryptoBrowser {
    <#
        .SYNOPSIS
            Returns the available OperaCryptoBrowser versions and download URIs.

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

    foreach ($Channel in $res.Get.Update.Channels) {
        $Update = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri[$Channel]

        if ($Null -ne $Update.($res.Get.Update.Property)) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): checking property: $($res.Get.Update.Property)."
            Write-Verbose -Message "$($MyInvocation.MyCommand): found version: $($Update.($res.Get.Update.Property))"

            # Step through each installer type
            foreach ($Architecture in $res.Get.Download.Architectures) {

                # Build the output object; Output object to the pipeline
                $Url = $res.Get.Download.Uri[$Channel] -replace $res.Get.Download.ReplaceText, $Update.($res.Get.Update.Property) `
                    -replace "#architecture", $res.Get.Download.Architecture[$Architecture]
                $PSObject = [PSCustomObject] @{
                    Version      = $Update.($res.Get.Update.Property)
                    Channel      = $Channel
                    Architecture = $Architecture
                    Type         = Get-FileType -File $Url
                    URI          = $Url
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
