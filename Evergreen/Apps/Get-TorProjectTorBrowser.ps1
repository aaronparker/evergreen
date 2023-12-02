Function Get-TorProjectTorBrowser {
    <#
        .SYNOPSIS
            Returns the latest Tor Browser version number and download.

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

    # Pass the repo releases API URL and return a formatted object
    $Update = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri

    # Get properties from the manifest to make reading the coder easier to read
    $Downloads = $res.Get.Update.Property.Download
    $Version = $res.Get.Update.Property.Version
    $Installer = $res.Get.Update.Property.Installer

    # If the update content includes the required property
    If ($Downloads -in ($Update | Get-Member -MemberType "NoteProperty" | Select-Object -ExpandProperty "Name")) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Found required property: $Downloads."
        Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $($Update.$Version)."

        # Step through each Windows x86 and x64 architecture
        ForEach ($Platform in $res.Get.Update.Platform) {
            Write-Verbose -Message "$($MyInvocation.MyCommand):  Platform: $Platform."

            $Languages = $Update.$Downloads.$Platform | Get-Member -MemberType "NoteProperty" | Select-Object -ExpandProperty "Name"
            ForEach ($Language in $Languages) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Language: $Language."

                $PSObject = [PSCustomObject] @{
                    Version      = $Update.$Version
                    Architecture = Get-Architecture -String $Platform
                    Type         = [System.IO.Path]::GetExtension($Update.$Downloads.$Platform.$Language.$Installer).Split(".")[-1]
                    Language     = $Language
                    URI          = $Update.$Downloads.$Platform.$Language.$Installer
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to find '$Downloads' property."
    }
}
