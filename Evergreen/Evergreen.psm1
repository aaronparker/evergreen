<#
    .SYNOPSIS
        Evergreen script to initiate the module
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "", Justification = "Required for argument completion.")]
[CmdletBinding(SupportsShouldProcess = $false)]
param ()

# Get public and private function definition files
$PublicRoot = Join-Path -Path $PSScriptRoot -ChildPath "Public"
$PrivateRoot = Join-Path -Path $PSScriptRoot -ChildPath "Private"
$SharedRoot = Join-Path -Path $PSScriptRoot -ChildPath "Shared"
$Public = @( Get-ChildItem -Path (Join-Path -Path $PublicRoot -ChildPath "*.ps1") -ErrorAction "Stop" )
$Private = @( Get-ChildItem -Path (Join-Path -Path $PrivateRoot -ChildPath "*.ps1") -ErrorAction "Stop" )
$Shared = @( Get-ChildItem -Path (Join-Path -Path $SharedRoot -ChildPath "*.ps1") -ErrorAction "Stop" )

# Dot source the files
foreach ($Import in @($Public + $Private + $Shared)) {
    try {
        . $Import.FullName
    }
    catch {
        throw $_
    }
}

# Get module strings
$script:resourceStrings = Get-ModuleResource

# Register the argument completer for the Get-EvergreenApp and Find-EvergreenApp cmdlets
$Commands = "Get-EvergreenApp", "Find-EvergreenApp", "Get-EvergreenAppFromApi", "Export-EvergreenManifest", "Get-EvergreenLibraryApp", "Get-EvergreenEndpointFromApi"
Register-ArgumentCompleter -CommandName $Commands -ParameterName "Name" -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    (Get-ChildItem -Path "$PSScriptRoot\Manifests\$wordToComplete*.json" -ErrorAction "Ignore").BaseName
}

# Export the public modules and aliases
Export-ModuleMember -Function $public.Basename -Alias *

# Sets up paths for the Evergreen apps repository, checks if the required 'Apps' and 'Manifests' directories exist locally,
# and verifies if the local commit hash matches the latest commit hash from the remote GitHub repository.
# If the directories are missing or the commit hashes do not match, it warns the user to update the Evergreen app functions.
$script:Repository = "EUCPilots/evergreen-apps"
$script:Branch = "main"
$script:AppsPath = if ($IsWindows) { Join-Path -Path ${Env:LOCALAPPDATA} -ChildPath 'Evergreen' } else { Join-Path -Path $HOME -ChildPath '.evergreen' }
$script:CommitFile = Join-Path -Path $script:AppsPath -ChildPath ".evergreenapps_commit"
if (-not (Test-Path (Join-Path -Path $script:AppsPath -ChildPath 'Apps')) -or -not (Test-Path (Join-Path -Path $script:AppsPath -ChildPath  'Manifests'))) {
    # Warn if Apps/Manifests have not been downloaded from GitHub
    Write-Warning -Message "Evergreen app functions have not been downloaded. Please run 'Update-Evergreen'."
}
elseif (Test-Path -Path $script:CommitFile -PathType "Leaf") {
    # Check if the locally stored commit hash matches the remote
    try {
        $RemoteCommit = $null
        $CommitApi = "https://api.github.com/repos/$script:Repository/commits/$script:Branch"
        $params = @{
            Uri                = $CommitApi
            ErrorAction        = "Stop"
            MaximumRedirection = 0
            DisableKeepAlive   = $true
            UseBasicParsing    = $true
            UserAgent          = "github-aaronparker-evergreen"
        }
        if (Test-Path -Path "env:GITHUB_TOKEN") {
            $params.Headers = @{ Authorization = "token $env:GITHUB_TOKEN" }
        }
        elseif (Test-Path -Path "env:GH_TOKEN") {
            $params.Headers = @{ Authorization = "token $env:GH_TOKEN" }
        }
        $RemoteCommit = Invoke-RestMethod @params
        $RemoteHash = $RemoteCommit.sha
    }
    catch {
        Write-Warning -Message "Failed to retrieve remote commit hash: $_"
        $RemoteHash = $null
    }
    $LocalCommit = Get-Content -Path $script:CommitFile -ErrorAction "SilentlyContinue"
    if ($null -eq $RemoteHash -or $LocalCommit -ne $RemoteHash) {
        Write-Warning -Message "Evergreen app functions are out of date. Please run 'Update-Evergreen'."
    }
}
