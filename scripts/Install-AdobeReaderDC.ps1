<#
    .SYNOPSIS
    Uses the Evergreen module to download and install the latest version of Adobe Reader DC
#>
[CmdletBinding(SupportsShouldProcess = $False)]
param ()

# Install the Evergreen module
Install-Module -Name Evergreen

# Target folder
$Folder = "C:\Temp\Reader"
New-Item -Path $Folder -ItemType Directory -Force -ErrorAction "SilentlyContinue"

# Download Reader installer and updater
$Reader = Get-AdobeAcrobatReaderDC | Where-Object { $_.Language -eq "English" -or $_.Language -eq "Neutral" }
ForEach ($File in $Reader) {
    Invoke-WebRequest -Uri $File.Uri -OutFile (Join-Path -Path $Folder -ChildPath (Split-Path -Path $File.Uri -Leaf))
}

# Get resource strings
$res = Export-EvergreenFunctionStrings -AppName "AdobeAcrobatReaderDC"

# Install Adobe Reader
# $exe = Get-ChildItem -Path $Folder -Filter $res.Install.Setup -Recurse
$exe = Get-ChildItem -Path $Folder -Filter "*.exe"
Start-Process -FilePath $exe.FullName -ArgumentList $res.Install.Virtual.Arguments -Wait

# Run post install actions
ForEach ($command in $res.Install.Virtual.PostInstall) {
    Invoke-Command -ScriptBlock ($ExecutionContext.InvokeCommand.NewScriptBlock($command))
}

# Update Adobe Reader
$msp = Get-ChildItem -Path $Folder -Filter "*.msp"
Start-Process -FilePath "$env:SystemRoot\System32\msiexec.exe" -ArgumentList "/update $($msp.FullName) /quiet" -Wait
