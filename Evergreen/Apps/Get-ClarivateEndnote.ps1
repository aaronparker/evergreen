function Get-ClarivateEndNote {
    <#
        .SYNOPSIS
            Get the current version and download URIs for the supported releases of Endnote.

        .NOTES
            Author: Jasper Metselaar
            E-mail: jms@du.se
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    foreach ($Release in $res.Get.Update.Releases) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Release: $Release"
        Write-Verbose -Message "$($MyInvocation.MyCommand): Endnote Update URL: $($res.Get.Update.Uri.$Release)"
        Write-Verbose -Message "$($MyInvocation.MyCommand): Download URL: $($res.Get.Download.Uri.$Release)"

        # Query the EndNote update API
        $UpdateFeed = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri.($Release)
        if ($null -ne $UpdateFeed) {

            # Sort the updates to find the latest
             $Update = $UpdateFeed.updates.build | `
                Sort-Object -Property @{ Expression = { [System.Version]$_.version }; Descending = $true } -ErrorAction "SilentlyContinue" | `
                Select-Object -First 1

            # Construct the output for the .exe installer; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version = $Update.UpdateTo
                Release = $Release
                Type    = Get-FileType -File $res.Get.Download.Uri.Exe.($Release)
                URI     = $res.Get.Download.Uri.Exe.($Release)
            }
            Write-Output -InputObject $PSObject

            # Construct the output for the .msi installer; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version = $Update.UpdateTo
                Release = $Release
                Type    = Get-FileType -File $res.Get.Download.Uri.Msi.($Release)
                URI     = $res.Get.Download.Uri.Msi.($Release)
            }
            Write-Output -InputObject $PSObject

            # Construct the output for the MSP patch; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version = $Update.updateTo
                Release = $Release
                Type    = Get-FileType -File $Update.url
                URI     = $Update.url
            }
            Write-Output -InputObject $PSObject
        }
    }
}