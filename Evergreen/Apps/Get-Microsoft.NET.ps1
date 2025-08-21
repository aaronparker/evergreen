function Get-Microsoft.NET {
    <#
        .SYNOPSIS
            Returns the available Microsoft .NET Desktop Runtime versions and download URIs.

        .NOTES
            Author: Aaron Parker
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Read the version number from the version URI
    foreach ($Channel in $res.Get.Update.Channels) {

        # Determine the version for each channel
        Write-Verbose -Message "$($MyInvocation.MyCommand): Find latest version for channel: $Channel"
        $Content = Invoke-EvergreenRestMethod -Uri $($res.Get.Update.Uri -replace $res.Get.Update.ReplaceText, $Channel)
        if ($null -ne $Content) {

            # Read last line of the returned content to retrieve the version number
            Write-Verbose -Message "$($MyInvocation.MyCommand): Returned: $Content."
            if ($Content -match "-") {
                $Version = [System.Version] (($Content -split "-")[0])
            }
            else {
                $Version = [System.Version] $Content
            }
            $MajorMinor = "$($Version.Major).$($Version.Minor)"
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $MajorMinor."

            # Read the releases JSON for that version
            Write-Verbose -Message "$($MyInvocation.MyCommand): Get releases list for $Channel, version: $MajorMinor."
            $Releases = Invoke-EvergreenRestMethod -Uri $($res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $MajorMinor)

            if ($null -ne $Releases) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($Releases.releases.Count) release/s."

                # Step through each release type
                foreach ($Installer in $res.Get.Download.Installers) {
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Build for type: $Installer."
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($Releases.releases[0].$Installer.files.count) files."

                    # Each installer includes multiple file types and platforms
                    foreach ($File in $Releases.releases[0].$Installer.files) {

                        # Filter for .exe only so that we get Windows installers
                        $File | Where-Object { $_.name -match "\.exe$" } | ForEach-Object {

                            # Build the output object; Output object to the pipeline
                            $PSObject = [PSCustomObject] @{
                                Version      = $Releases.releases[0].$Installer.version
                                Channel      = $Channel
                                Support      = $Releases.'support-phase'
                                Installer    = $Installer
                                Architecture = if ($_.rid.length -gt 0) { Get-Architecture -String $_.rid } else { Get-Architecture -String $_.url }
                                Sha512       = $_.hash
                                Type         = [System.IO.Path]::GetExtension($_.url).Split(".")[-1]
                                URI          = $_.url
                            }
                            Write-Output -InputObject $PSObject
                        }
                    }
                }
            }
        }
    }
}
