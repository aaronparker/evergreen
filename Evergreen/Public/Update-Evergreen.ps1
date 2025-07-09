function Update-Evergreen {
    <#
        .SYNOPSIS
            Download and synchronize Evergreen Apps and Manifests from a separate GitHub repository.

        .DESCRIPTION
            Enables separation of the core Evergreen module from app-specific code and manifests.
            Downloads the latest versions of /Apps and /Manifests from a specified GitHub repository to a user-writable location (no admin required).
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $Force
    )

    begin {
        # Create emoji characters for visual feedback for Windows PowerShell compatibility
        $CharBytes = 20, 39, 0, 0, 15, 254, 0, 0
        $Tick = [System.Text.Encoding]::UTF32.GetString($CharBytes)
        $CharBytes = 76, 39, 0, 0
        $Cross = [System.Text.Encoding]::UTF32.GetString($CharBytes)

        # Sync folders to check for expected structure
        $SyncFolders = @((Join-Path -Path $Script:AppsPath -ChildPath 'Apps'), (Join-Path -Path $Script:AppsPath -ChildPath 'Manifests'))

        # Check whether the AppsPath exists and create it if not
        if (Test-Path -Path $script:AppsPath -PathType "Container") {

            $DoHashCheck = $false
            foreach ($folder in $SyncFolders) {
                if (Test-Path -Path $folder -PathType "Container") {
                    $DoHashCheck = $true
                }
            }

            if ($DoHashCheck) {
                try {
                    # Get remote SHA256 hashes from CSV
                    Write-Message -Message "Retrieving remote SHA256 hash file."
                    $Sha256CsvUrl = "https://raw.githubusercontent.com/$($script:resourceStrings.Repositories.Apps.Repo)/refs/heads/$($script:resourceStrings.Repositories.Apps.Branch)/$($script:resourceStrings.Repositories.Apps.Sha256)"
                    $RemoteFileShas = Invoke-EvergreenRestMethod -Uri $Sha256CsvUrl | ConvertFrom-Csv
                }
                catch {
                    Write-Warning -Message "Failed to retrieve or parse remote SHA256 hash file: $_"
                }

                # Check if the local files match the expected SHA256 hashes
                Write-Message -Message "Validating local files against SHA256 hashes."
                $HashMismatch = $false
                foreach ($File in $RemoteFileShas) {
                    $FilePath = Join-Path -Path $script:AppsPath -ChildPath $File.file_path
                    if (Test-Path -Path $FilePath) {
                        $LocalHash = (Get-FileHash -Path $FilePath -Algorithm "SHA256").Hash.ToLower()
                        if ($LocalHash -ne $File.sha256.ToLower()) {
                            Write-Message -Message "$Cross SHA256 hash mismatch for file '$($FilePath)'."
                            $HashMismatch = $true
                        }
                    }
                }
                if ($HashMismatch) {
                    Write-Message -Message "SHA256 hash mismatch found. It is recommended to run 'Update-Evergreen -Force'."
                }
                else {
                    Write-Message -Message "$Tick Local files passed hash validation."
                }
            }
        }
        else {
            # Create the AppsPath directory
            New-Item -Path $script:AppsPath -ItemType "Directory" -Force | Out-Null
        }
    }

    process {
        try {
            # Get the latest version from the remote repository
            Write-Message -Message "Checking for latest Evergreen apps release."
            $Url = "https://api.github.com/repos/$($script:resourceStrings.Repositories.Apps.Repo)/releases/latest"
            $EvergreenAppsRelease = Get-GitHubRepoRelease -Uri $Url
            Write-Message -Message "Remote Evergreen apps version: $($EvergreenAppsRelease.Version)"
        }
        catch {
            $EvergreenAppsRelease = $null
        }

        try {
            # Read the local version file
            $LocalVersion = (Get-Content -Path $script:VersionFile -Raw -ErrorAction "Stop").Trim()
            Write-Message -Message "Local Evergreen apps version: $LocalVersion"
        }
        catch {
            $LocalVersion = $null
        }

        $DoUpdate = $false
        if ($null -eq $EvergreenAppsRelease) {
            throw "Could not retrieve remote version information. Please check your internet connection or the repository URL."
        }
        elseif ($null -eq $LocalVersion) {
            Write-Message -Message "Unable to find local Evergreen apps cached version. Downloading latest release."
            $DoUpdate = $true
        }
        elseif ([System.Version]$EvergreenAppsRelease.Version -gt [System.Version]$LocalVersion) {
            Write-Message -Message "Evergreen apps are out of date. Downloading latest release."
            $DoUpdate = $true
        }
        elseif ([System.Version]$EvergreenAppsRelease.Version -le [System.Version]$LocalVersion) {
            Write-Message -Message "Local version matches remote version. Evergreen apps are up to date."
            $DoUpdate = $false
            if ($Force) {
                Write-Message -Message "Forcing update due to -Force parameter."
            }
            else {
                Write-Message -Message "Use 'Update-Evergreen -Force' to force a full sync."
            }
        }
        else {
            Write-Message -Message "Unable to validate local Evergreen apps cached version. Downloading latest release."
            $DoUpdate = $true
        }

        # Check local expected directories exist
        foreach ($folder in $SyncFolders) {
            if (-not (Test-Path -Path $folder -PathType "Container")) {
                Write-Message -Message "'$folder' does not exist. Will perform full sync."
                $DoUpdate = $true
            }
        }

        # If -Force or no local copy or commit mismatch, do a full download
        if ($Force -or $DoUpdate) {
            Write-Message -Message "Performing full sync from remote repository."

            Write-Message -Message "Downloading Evergreen apps release: $($EvergreenAppsRelease.Uri)."
            $ZipFile = Save-EvergreenApp -InputObject $EvergreenAppsRelease -LiteralPath $script:AppsPath -Force
            if (Test-Path -Path $ZipFile -PathType "Leaf") {
                Write-Verbose -Message "Downloaded Evergreen apps release to $ZipFile."

                $ZipFileHash = (Get-FileHash -Path $ZipFile -Algorithm "SHA256").Hash.ToLower()
                if ($EvergreenAppsRelease.Sha256.ToLower() -ne $ZipFileHash) {
                    throw "SHA256 hash mismatch for downloaded release. Expected: $($EvergreenAppsRelease.Sha256.ToLower()), Actual: $ZipFileHash"
                }

                Write-Verbose -Message "Extracting Evergreen apps release from $ZipFile."
                $ExtractPath = Join-Path -Path $script:AppsPath -ChildPath "_extracted"
                if (Test-Path -Path $ExtractPath) { Remove-Item -Path $ExtractPath -Recurse -Force -ErrorAction "SilentlyContinue" }
                Expand-Archive -Path $ZipFile -DestinationPath $ExtractPath -Force
                Remove-Item -Path $ZipFile -Force -ErrorAction "SilentlyContinue"

                Write-Message -Message "Validating extracted files against remote SHA256 hashes."
                $DoReplace = $true
                foreach ($File in $RemoteFileShas) {
                    $FilePath = Join-Path -Path $ExtractPath -ChildPath $File.file_path
                    if (Test-Path -Path $FilePath) {
                        $LocalHash = (Get-FileHash -Path $FilePath -Algorithm "SHA256").Hash.ToLower()
                        if ($LocalHash -ne $File.sha256.ToLower()) {
                            Write-Warning -Message "$Cross SHA256 hash mismatch for file '$($File.file_path)'. Expected: $($File.sha256.ToLower()), Actual: $LocalHash"
                            $DoReplace = $false
                        }
                        else {
                            Write-Verbose -Message "$Tick File '$($File.file_path)' hash matches expected value."
                        }
                    }
                    else {
                        Write-Warning -Message "$Cross Expected file '$($File.file_path)' not found in extracted release."
                        $DoReplace = $false
                    }
                }

                if ($DoReplace) {
                    Write-Message -Message "$Tick Downloaded release passed hash validation."
                    Write-Message -Message "Synchronizing Evergreen apps and manifests to $script:AppsPath."
                    # Remove existing Apps and Manifests directories
                    $LocalAppsPath = Join-Path -Path $script:AppsPath -ChildPath "Apps"
                    $LocalManifestsPath = Join-Path -Path $script:AppsPath -ChildPath "Manifests"
                    if (Test-Path -Path $LocalAppsPath) { Remove-Item -Path $LocalAppsPath -Recurse -Force -ErrorAction "SilentlyContinue" }
                    if (Test-Path -Path $LocalManifestsPath) { Remove-Item -Path $LocalManifestsPath -Recurse -Force -ErrorAction "SilentlyContinue" }

                    # Move extracted contents to the correct locations
                    Move-Item -Path (Join-Path -Path $ExtractPath -ChildPath "Apps") -Destination $script:AppsPath
                    Move-Item -Path (Join-Path -Path $ExtractPath -ChildPath "Manifests") -Destination $script:AppsPath

                    if ($EvergreenAppsRelease) { Set-Content -Path $script:VersionFile -Value $EvergreenAppsRelease.Version -Encoding "UTF8" -Force }
                    Write-Message -Message "Apps and Manifests have been synchronized to $script:AppsPath."
                    Write-Message -Message "Update complete."
                }
                else {
                    Write-Warning -Message "Some files did not match expected SHA256 hashes. Evergreen apps and manifests were not updated."
                }

                # Clean up the extracted files
                Remove-Item -Path $ExtractPath -Recurse -Force -ErrorAction "SilentlyContinue"
            }
            else {
                throw "Failed to download Evergreen apps release. The file does not exist at $ZipFile."
            }
        }
    }
}
