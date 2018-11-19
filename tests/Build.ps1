[CmdletBinding()]
Param()
$ModuleName = "Get.Software"

If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    $ProjectRoot = $env:APPVEYOR_BUILD_FOLDER
}
Else {
    # Local Testing 
    $ProjectRoot = ((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName
}

# Line break for readability in AppVeyor console
Write-Host -Object ''
Write-Verbose $ProjectRoot

# Make sure we're using the Master branch and that it's not a pull request
# Environmental Variables Guide: https://www.appveyor.com/docs/environment-variables/
If ($Null -ne $env:APPVEYOR_REPO_BRANCH) {
    If ($env:APPVEYOR_REPO_BRANCH -ne 'master') {
        Write-Warning -Message "Skipping version increment and publish for branch $env:APPVEYOR_REPO_BRANCH"
    }
    ElseIf ($env:APPVEYOR_PULL_REQUEST_NUMBER -gt 0) {
        Write-Warning -Message "Skipping version increment and publish for pull request #$env:APPVEYOR_PULL_REQUEST_NUMBER"
    }
}
Else {
    # We're going to add 1 to the revision value since a new commit has been merged to Master
    # This means that the major / minor / build values will be consistent across GitHub and the Gallery
    Try {
        # This is where the module manifest lives
        $manifestPath = Join-Path (Join-Path $projectRoot $ModuleName) "$ModuleName.psd1"

        # Start by importing the manifest to determine the version, then add 1 to the revision
        $manifest = Test-ModuleManifest -Path $manifestPath
        [System.Version]$version = $manifest.Version
        Write-Output "Old Version: $version"
        [String]$newVersion = New-Object -TypeName System.Version -ArgumentList ($version.Major, $version.Minor, $version.Build, $env:APPVEYOR_BUILD_NUMBER)
        Write-Output "New Version: $newVersion"

        # Update the manifest with the new version value and fix the weird string replace bug
        $functionList = ((Get-ChildItem -Path (Join-Path (Join-Path $projectRoot $ModuleName) "Public")).BaseName)
        Update-ModuleManifest -Path $manifestPath -ModuleVersion $newVersion -FunctionsToExport $functionList
        (Get-Content -Path $manifestPath) -replace 'PSGet_$ModuleName', $ModuleName | Set-Content -Path $manifestPath
        (Get-Content -Path $manifestPath) -replace 'NewManifest', $ModuleName | Set-Content -Path $manifestPath
        (Get-Content -Path $manifestPath) -replace 'FunctionsToExport = ', 'FunctionsToExport = @(' | Set-Content -Path $manifestPath -Force
        (Get-Content -Path $manifestPath) -replace "$($functionList[-1])'", "$($functionList[-1])')" | Set-Content -Path $manifestPath -Force
    }
    Catch {
        Throw $_
    }

    <#
    # Publish the new version back to Master on GitHub
    Try {
        # Set up a path to the git.exe cmd, import posh-git to give us control over git, and then push changes to GitHub
        # Note that "update version" is included in the appveyor.yml file's "skip a build" regex to avoid a loop
        $env:Path += ";$env:ProgramFiles\Git\cmd"
        Import-Module posh-git -ErrorAction Stop
        git checkout master
        git add --all
        git status
        git commit -s -m "Update version to $newVersion"
        git push origin master
        Write-Host "$ModuleName PowerShell Module version $newVersion published to GitHub." -ForegroundColor Cyan
    }
    Catch {
        # Sad panda; it broke
        Write-Warning "Publishing update $newVersion to GitHub failed."
        Throw $_
    }

    # Publish the new version to the PowerShell Gallery
    Try {
        # Build a splat containing the required details and make sure to Stop for errors which will trigger the catch
        $PM = @{
            Path        = Join-Path $projectRoot "$ModuleName"
            NuGetApiKey = $env:NuGetApiKey
            ErrorAction = 'Stop'
        }
        Publish-Module @PM
        Write-Host "$ModuleName PowerShell Module version $newVersion published to the PowerShell Gallery." -ForegroundColor Cyan
    }
    Catch {
        # Sad panda; it broke
        Write-Warning "Publishing update $newVersion to the PowerShell Gallery failed."
        throw $_
    }
    #>
}
