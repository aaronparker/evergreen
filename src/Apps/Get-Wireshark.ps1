Function Get-Wireshark {
    <#
        .SYNOPSIS
            Returns the available Wireshark versions and download URIs.

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
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Filter
    )

    # Resolve the URL to the target location
    ForEach ($item in $res.Get.Update.Uri.GetEnumerator()) {
        $params = @{
            Uri       = $res.Get.Update.Uri[$item.Key]
            UserAgent = $res.Get.Update.UserAgent
        }
        $Update = Invoke-RestMethodWrapper @params

        If ($Null -ne $Update) {
            ForEach ($enclosure in $Update.enclosure) {

                # Build the output object; Output object to the pipeline
                $PSObject = [PSCustomObject] @{
                    Version      = $enclosure.version
                    Architecture = $item.Name
                    Type         = $([System.IO.Path]::GetExtension($enclosure.url).Split(".")[-1])
                    URI          = $enclosure.url
                }
                Write-Output -InputObject $PSObject

                # Build the output object; Output object to the pipeline
                $PSObject = [PSCustomObject] @{
                    Version      = $enclosure.version
                    Architecture = $item.Name
                    Type         = "msi"
                    URI          = $($enclosure.url -replace ([System.IO.Path]::GetExtension($enclosure.url).Split(".")[-1]), "msi")
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
