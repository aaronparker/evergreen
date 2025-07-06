function Update-Evergreen {
    <#
        .SYNOPSIS
            Download and synchronize Evergreen Apps and Manifests from a separate GitHub repository.

        .DESCRIPTION
            Enables separation of the core Evergreen module from app-specific code and manifests.
            Downloads the latest versions of /Apps and /Manifests from a specified GitHub repository to a user-writable location (no admin required).

        .PARAMETER $script:AppsPath
            The local path to store the downloaded Apps and Manifests. Defaults to $env:LOCALAPPDATA/Evergreen (Windows) or ~/.evergreen (macOS/Linux).
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

        $commitApi = "https://api.github.com/repos/$script:Repository/commits/$script:Branch"
        $treeApi = "https://api.github.com/repos/$script:Repository/git/trees/$($script:Branch)?recursive=1"
        $sha256CsvUrl = "https://raw.githubusercontent.com/$script:Repository/refs/heads/$script:Branch/sha256_hashes.csv"
        $headers = @{ 'Accept' = 'application/vnd.github.v3+json' }
        $syncFolders = @('Apps', 'Manifests')
    }
    process {
        # Get latest commit hash from remote
        $remoteCommit = $null
        try {
            $remoteCommit = Invoke-RestMethod -Uri $commitApi -Headers $headers -ErrorAction "Stop"
            $remoteHash = $remoteCommit.sha
        }
        catch {
            Write-Warning "Failed to retrieve remote commit hash: $_"
            $remoteHash = $null
        }

        # Get remote SHA256 hashes from CSV
        $remoteFileShas = @{}
        try {
            $csvContent = Invoke-WebRequest -Uri $sha256CsvUrl -UseBasicParsing -ErrorAction Stop | Select-Object -ExpandProperty Content
            $csvRows = $csvContent -split "`n" | Where-Object { $_ -and $_ -notmatch '^#' }
            foreach ($row in $csvRows) {
                $parts = $row -split ','
                if ($parts.Length -eq 2) {
                    $remoteFileShas[$parts[0].Trim()] = $parts[1].Trim().ToLower()
                }
            }
        }
        catch {
            Write-Warning "Failed to retrieve or parse remote sha256_hashes.csv: $_"
        }

        # Check if local copy exists
        $localExists = $true
        foreach ($folder in $syncFolders) {
            if (-not (Test-Path (Join-Path -Path $script:AppsPath -ChildPath $folder))) {
                $localExists = $false
            }
        }
        $localCommit = $null
        if (Test-Path -Path $script:CommitFile -PathType "Leaf") {
            $localCommit = Get-Content -Path $script:CommitFile -ErrorAction "SilentlyContinue"
        }

        # If -Force or no local copy or commit mismatch, do a full download
        if ($Force -or -not $localExists -or ($remoteHash -and ($localCommit -ne $remoteHash))) {
            Write-Verbose "Performing full sync from remote repository."
            $zipUrl = "https://github.com/$script:Repository/archive/refs/heads/$script:Branch.zip"
            $zipFile = Join-Path $$script:AppsPath "evergreen-apps-temp.zip"
            if ($PSCmdlet.ShouldProcess($zipFile, "Download Apps and Manifests as zip from $zipUrl")) {
                Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile -UseBasicParsing -ErrorAction Stop
            }
            $extractPath = Join-Path -Path $script:AppsPath -ChildPath "_extracted"
            if (Test-Path -Path $extractPath) { Remove-Item -Path $extractPath -Recurse -Force }
            Expand-Archive -Path $zipFile -DestinationPath $extractPath -Force
            Remove-Item -Path $zipFile -Force
            $repoFolder = Get-ChildItem -Path $extractPath | Where-Object { $_.PSIsContainer } | Select-Object -First 1 -ExpandProperty "FullName"
            foreach ($folderName in $syncFolders) {
                $src = Join-Path -Path $repoFolder -ChildPath $folderName
                $dst = Join-Path -Path $script:AppsPath -ChildPath $folderName
                if (-not (Test-Path -Path $dst)) { New-Item -Path $dst -ItemType "Directory" -Force | Out-Null }
                # Copy new/updated files and build list of remote files
                $remoteFiles = @()
                if (Test-Path $src) {
                    Get-ChildItem -Path $src -File | ForEach-Object {
                        $destFile = Join-Path -Path $dst -ChildPath $_.Name
                        Copy-Item -Path $_.FullName -Destination $destFile -Force
                        $remoteFiles += $_.Name
                    }
                }
                # Remove only local files not present in remote
                $localFiles = Get-ChildItem -Path $dst -File | Select-Object -ExpandProperty "Name"
                $filesToRemove = $localFiles | Where-Object { $_ -notin $remoteFiles }
                foreach ($file in $filesToRemove) {
                    $removePath = Join-Path -Path $dst -ChildPath $file
                    if ($PSCmdlet.ShouldProcess($removePath, "Remove local file not present in remote repository")) {
                        Remove-Item -Path $removePath -Force -ErrorAction "SilentlyContinue"
                    }
                }
            }
            Remove-Item -Path $extractPath -Recurse -Force
            if ($remoteHash) { Set-Content -Path $commitFile -Value $remoteHash -Encoding UTF8 -Force }
            Write-Verbose "Full sync complete."
            return
        }

        # Otherwise, do a smart sync: compare file hashes and update only changed/new files, remove deleted
        foreach ($folderName in $syncFolders) {
            $dst = Join-Path -Path $script:AppsPath -ChildPath $folderName
            if (-not (Test-Path $dst)) { New-Item -Path $dst -ItemType Directory -Force | Out-Null }
            # Get all remote files for this folder
            $remoteFiles = $remoteFileShas.GetEnumerator() | Where-Object { $_.Key -like "$folderName/*" }
            $remoteFileNames = $remoteFiles | ForEach-Object { Split-Path $_.Key -Leaf }
            # Download new/changed files
            foreach ($remoteFile in $remoteFiles) {
                $file = Split-Path $remoteFile.Key -Leaf
                $localFile = Join-Path -Path $dst -ChildPath $file
                $needsUpdate = $true
                if (Test-Path $localFile) {
                    $localHash = (Get-FileHash -Path $localFile -Algorithm "SHA256").Hash.ToLower()
                    if ($localHash -eq $remoteFile.Value) { $needsUpdate = $false }
                }
                if ($needsUpdate) {
                    $downloadUrl = "https://raw.githubusercontent.com/$script:Repository/$script:Branch/$($remoteFile.Key)"
                    if ($PSCmdlet.ShouldProcess($localFile, "Download updated file $file")) {
                        Invoke-WebRequest -Uri $downloadUrl -OutFile $localFile -UseBasicParsing -ErrorAction "Stop"
                    }
                }
            }
            # Remove local files not present in remote
            $localFiles = Get-ChildItem -Path $dst -File | Select-Object -ExpandProperty "Name"
            $filesToRemove = $localFiles | Where-Object { $_ -notin $remoteFileNames }
            foreach ($file in $filesToRemove) {
                $removePath = Join-Path -Path $dst --ChildPath $file
                if ($PSCmdlet.ShouldProcess($removePath, "Remove local file not present in remote repository")) {
                    Remove-Item -Path $removePath -Force -ErrorAction "SilentlyContinue"
                }
            }
        }
        if ($remoteHash) { Set-Content -Path $commitFile -Value $remoteHash -Encoding "UTF8" -Force }
        Write-Verbose "Apps and Manifests have been synchronized to $$script:AppsPath."
    }
}
