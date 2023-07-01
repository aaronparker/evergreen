function Get-Microsoft.NET {
    <#
        .SYNOPSIS
            Returns the available Microsoft .NET Desktop Runtime versions and download URIs.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Read the version number from the version URI
    foreach ($Channel in $res.Get.Update.Channels) {

        # Determine the version for each channel
        $Content = Invoke-RestMethodWrapper -Uri $($res.Get.Update.Uri -replace $res.Get.Update.ReplaceText, $Channel)
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
            $Releases = Invoke-RestMethodWrapper -Uri $($res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $MajorMinor)
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
                            Architecture = if ($_.rid.length -gt 0) { Get-Architecture -String $_.rid } else { Get-Architecture -String $_.url }
                            Installer    = $Installer
                            Channel      = $Channel
                            Hash         = $_.hash
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
