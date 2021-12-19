Function Get-Microsoft.NET {
    <#
        .SYNOPSIS
            Returns the available Microsoft .NET Desktop Runtime versions and download URIs.

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

    # Read the version number from the version URI
    ForEach ($Channel in $res.Get.Update.Channels) {

        # Determine the version for each channel
        $Content = Invoke-RestMethodWrapper -Uri $($res.Get.Update.Uri -replace $res.Get.Update.ReplaceText, $Channel)
        If ($Null -ne $Content) {

            # Read last line of the returned content to retrieve the version number
            Write-Verbose -Message "$($MyInvocation.MyCommand): Returned: $Content."
            $Version = [System.Version] $Content
            $MajorMinor = "$($Version.Major).$($Version.Minor)"
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $MajorMinor."

            # Read the releases JSON for that version
            $Releases = Invoke-RestMethodWrapper -Uri $($res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $MajorMinor)
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($Releases.releases.Count) release/s."

            # Step through each release type
            ForEach ($Installer in $res.Get.Download.Installers) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Build for type: $Installer."
                Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($Releases.releases[0].$Installer.files.count) files."

                # Each installer includes multiple file types and platforms
                ForEach ($File in $Releases.releases[0].$Installer.files) {

                    # Filter for .exe only so that we get Windows installers
                    $File | Where-Object { $_.name -match "\.exe$" } | ForEach-Object {

                        # Build the output object; Output object to the pipeline
                        $PSObject = [PSCustomObject] @{
                            Version      = $Releases.releases[0].$Installer.version
                            Architecture = Get-Architecture -String $_.rid
                            Installer    = $Installer
                            Channel      = $Channel
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
