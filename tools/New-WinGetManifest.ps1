#Requires -Module Evergreen
<#
    .SYNOPSIS
        Creates a Windows Package Manager manifest from an Evergreen function output.

        The intent of this script is to help you generate a YAML file for publishing to the Windows Package Manager repository.

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        https://github.com/aaronparker/Evergreen

    .EXAMPLE
        New-WinGetManifest -Package MicrosoftFSLogixApps -Path C:\Manifests

        Description:
        Creates a Windows Package Manager manifest for Microsoft FSLogix Apps and outputs the manifest in C:\Manifests
#>
[CmdletBinding(SupportsShouldProcess = $False)]
param (
    [Parameter(Mandatory, Position = 0)]
    [System.String] $Name,

    [Parameter(Mandatory, Position = 1)]
    [System.String] $Path
)

# define variables
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Get details from the target Evergreen package
If (Find-EvergreenApp -Name $Name) {
    $Packages = Get-EvergreenApp -Name $Name

    try {
        $Manifest = Export-EvergreenManifest -AppName $Name
    }
    catch {
        Write-Warning -Message "Failed to return package details from Get-$Name."
    }

    # Get the package properties
    $id = "$($Manifest.Name.Split(" ")[0]).$($Manifest.Name.Split(" ")[1,2,3] -join '')"
    $publisher = $Manifest.Name.Split(" ")[0]
    $AppName = $Manifest.Name.Split(" ")[1, 2, 3] -join ""
    $WinGetManifestFile = Join-Path -Path $Path -ChildPath "$($Packages[0].Version).yaml"

    # Read metadata
    While ($License.Length -eq 0) {
        $License = Read-Host -Prompt 'Enter the License, For example: MIT, or Copyright (c) Microsoft Corporation'
    }

    While ($InstallerType.Length -eq 0) {
        $InstallerType = Read-Host -Prompt 'Enter the InstallerType. For example: exe, msi, msix, inno, nullsoft'
    }
    $LicenseUrl = Read-Host -Prompt '[OPTIONAL] Enter the license URL'
    $AppMoniker = Read-Host -Prompt '[OPTIONAL] Enter the AppMoniker (friendly name). For example: vscode'
    $Tags = Read-Host -Prompt '[OPTIONAL] Enter any tags that would be useful to discover this tool. For example: zip, c++'
    $Description = Read-Host -Prompt '[OPTIONAL] Enter a description of the application'

    #region Write metadata
    $string = "Id: $id"
    Write-Output $string | Out-File -Path $WinGetManifestFile

    $string = "Version: $($Packages[0].Version)"
    Write-Output $string | Out-File -Path $WinGetManifestFile -Append

    $string = "Name: $AppName"
    Write-Output $string | Out-File -Path $WinGetManifestFile -Append

    $string = "Publisher: $Publisher"
    Write-Output $string | Out-File -Path $WinGetManifestFile -Append

    $string = "Homepage: $($Manifest.Source)"
    Write-Output $string | Out-File -Path $WinGetManifestFile -Append

    $string = "License: $License"
    Write-Output $string | Out-File -Path $WinGetManifestFile -Append

    if (!($LicenseUrl.length -eq 0)) {
        $string = "LicenseUrl: $LicenseUrl"
        Write-Output $string | Out-File -Path $WinGetManifestFile -Append
    }
    if (!($AppMoniker.length -eq 0)) {
        $string = "AppMoniker: $AppMoniker"
        Write-Output $string | Out-File -Path $WinGetManifestFile -Append
    }
    if (!($Commands.length -eq 0)) {
        $string = "Commands: $Commands"
        Write-Output $string | Out-File -Path $WinGetManifestFile -Append
    }
    if (!($Tags.length -eq 0)) {
        $string = "Tags: $Tags"
        Write-Output $string | Out-File -Path $WinGetManifestFile -Append
    }
    if (!($Description.length -eq 0)) {
        $string = "Description: $Description"
        Write-Output $string | Out-File -Path $WinGetManifestFile -Append
    }
    #endregion

    # Write output for each architecture
    Write-Output "Installers:" | Out-File -Path $WinGetManifestFile -Append

    # Walk through each package in output from the Evergreen function
    ForEach ($Package in $Packages) {

        # Download the target file
        try {
            # Create a temporary file to generate a sha256 value.
            #If (Test-Path -Path env:TEMP) { $tempFolder = $env:TEMP } Else { $tempFolder = $env:TMPDIR }
            $Hashfile = New-TemporaryFile

            Write-Host "Downloading URL: $($Package.URI)." -ForegroundColor Blue
            $WebClient = New-Object -TypeName "System.Net.WebClient"
            $WebClient.DownloadFile($Package.URI, $Hashfile)
        }
        catch {
            Throw $_
            Break
        }

        # Get the file hash
        $Hash = Get-FileHash -Path $Hashfile
        Remove-Item -Path $Hashfile

        #region Write metadata
        $string = "  - Arch: " + $Package.Architecture
        Write-Output $string | Out-File -Path $WinGetManifestFile -Append

        $string = "    Url: " + $Package.URI
        Write-Output $string | Out-File -Path $WinGetManifestFile -Append

        $string = "    Sha256: " + $Hash.Hash
        Write-Output $string | Out-File -Path $WinGetManifestFile -Append

        $string = "    InstallerType: " + $InstallerType
        Write-Output $string | Out-File -Path $WinGetManifestFile -Append
        #endregion
    }

    Write-Host "Manifest saved to: $WinGetManifestFile."
    Write-Host "Now place this file in the following location: \manifests\$publisher\$AppName"
}
Else {
    Write-Warning -Message "Evergeen application $Name does not exist."
}
