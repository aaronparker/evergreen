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
        if (-not (Test-Path $script:AppsPath)) {
            New-Item -Path $script:AppsPath -ItemType "Directory" -Force | Out-Null
        }

        $SyncFolders = @('Apps', 'Manifests')
        $Sha256CsvUrl = "https://raw.githubusercontent.com/$script:Repository/refs/heads/$script:Branch/sha256_hashes.csv"
        try {
            # Get remote SHA256 hashes from CSV
            $RemoteFileShas = Invoke-EvergreenRestMethod -Uri $Sha256CsvUrl | ConvertFrom-Csv
        }
        catch {
            Write-Warning -Message "Failed to retrieve or parse remote sha256_hashes.csv: $_"
        }

        # Check if the local files match the expected SHA256 hashes
        foreach ($File in $RemoteFileShas) {
            $FilePath = Join-Path -Path $script:AppsPath -ChildPath $File.file_path
            if (Test-Path -Path $FilePath) {
                $LocalHash = (Get-FileHash -Path $FilePath -Algorithm "SHA256").Hash.ToLower()
                if ($LocalHash -ne $File.sha256.ToLower()) {
                    Write-Warning -Message "❌ SHA256 hash mismatch for file '$($FilePath)'. Expected: $($File.sha256.ToLower()), Actual: $LocalHash"
                }
            }
            else {
                Write-Warning -Message "❌ Expected file '$($FilePath)' not found in cached Evergreen apps directory."
            }
        }
    }

    process {
        try {
            # Get the latest version from the remote repository
            $Url = "https://api.github.com/repos/$script:Repository/releases/latest"
            $EvergreenAppsRelease = Get-GitHubRepoRelease -Uri $Url
            Write-Verbose -Message "Remote Evergreen apps version: $($EvergreenAppsRelease.Version)"
        }
        catch {
            $EvergreenAppsRelease = $null
        }

        try {
            # Read the local version file
            $LocalVersion = (Get-Content -Path $script:VersionFile -Raw -ErrorAction "Stop").Trim()
            Write-Verbose -Message "Local Evergreen apps version: $LocalVersion"
        }
        catch {
            $LocalVersion = $null
        }

        $DoUpdate = $false
        if ($null -eq $EvergreenAppsRelease) {
            throw "Could not retrieve remote version information. Please check your internet connection or the repository URL."
        }
        elseif ($null -eq $LocalVersion) {
            Write-Verbose -Message "Unable to find local Evergreen apps cached version. Downloading latest release."
            $DoUpdate = $true
        }
        elseif ([System.Version]$EvergreenAppsRelease.Version -gt [System.Version]$LocalVersion) {
            Write-Verbose -Message "Evergreen apps are out of date. Downloading latest release."
            $DoUpdate = $true
        }
        elseif ([System.Version]$EvergreenAppsRelease.Version -le [System.Version]$LocalVersion) {
            Write-Verbose -Message "Evergreen apps are up to date. Local version matches remote version."
            $DoUpdate = $false
        }
        else {
            Write-Verbose -Message "Unable to validate local Evergreen apps cached version. Downloading latest release."
            $DoUpdate = $true
        }

        # Check local expected directories exist
        foreach ($folder in $SyncFolders) {
            if (-not (Test-Path -Path (Join-Path -Path $script:AppsPath -ChildPath $folder))) {
                Write-Verbose -Message "Local folder '$folder' does not exist in $script:AppsPath. Will perform full sync."
                $DoUpdate = $true
            }
        }

        # If -Force or no local copy or commit mismatch, do a full download
        if ($Force -or $DoUpdate) {
            Write-Verbose -Message "Performing full sync from remote repository."

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

                Write-Verbose -Message "Validating extracted files against remote SHA256 hashes."
                $DoReplace = $true
                foreach ($File in $RemoteFileShas) {
                    $FilePath = Join-Path -Path $ExtractPath -ChildPath $File.file_path
                    if (Test-Path -Path $FilePath) {
                        $LocalHash = (Get-FileHash -Path $FilePath -Algorithm "SHA256").Hash.ToLower()
                        if ($LocalHash -ne $File.sha256.ToLower()) {
                            Write-Warning -Message "❌ SHA256 hash mismatch for file '$($File.file_path)'. Expected: $($File.sha256.ToLower()), Actual: $LocalHash"
                            $DoReplace = $false
                        }
                        else {
                            Write-Verbose -Message "✅ File '$($File.file_path)' hash matches expected value."
                        }
                    }
                    else {
                        Write-Warning -Message "❌ Expected file '$($File.file_path)' not found in extracted release."
                        $DoReplace = $false
                    }
                }

                if ($DoReplace) {
                    Write-Verbose -Message "Synchronizing Evergreen apps and manifests to $script:AppsPath."
                    # Remove existing Apps and Manifests directories
                    $LocalAppsPath = Join-Path -Path $script:AppsPath -ChildPath "Apps"
                    $LocalManifestsPath = Join-Path -Path $script:AppsPath -ChildPath "Manifests"
                    if (Test-Path -Path $LocalAppsPath) { Remove-Item -Path $LocalAppsPath -Recurse -Force -ErrorAction "SilentlyContinue" }
                    if (Test-Path -Path $LocalManifestsPath) { Remove-Item -Path $LocalManifestsPath -Recurse -Force -ErrorAction "SilentlyContinue" }

                    # Move extracted contents to the correct locations
                    Move-Item -Path (Join-Path -Path $ExtractPath -ChildPath "Apps") -Destination $script:AppsPath
                    Move-Item -Path (Join-Path -Path $ExtractPath -ChildPath "Manifests") -Destination $script:AppsPath

                    if ($EvergreenAppsRelease) { Set-Content -Path $script:VersionFile -Value $EvergreenAppsRelease.Version -Encoding "UTF8" -Force }
                    Write-Verbose -Message "Apps and Manifests have been synchronized to $script:AppsPath."
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
