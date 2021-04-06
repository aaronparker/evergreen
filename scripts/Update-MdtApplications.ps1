<#
    .SYNOPSIS
    Updates appplications in an MDT deployment share using Evergreen and VcRedist
#>
[CmdletBinding(SupportsShouldProcess = $False)]
param (
    $AppParentPath = "E:\Deployment\Insentra\Automata\Applications",
    $DeploymentShare = "E:\Deployment\Insentra\Automata"
)

# Set $VerbosePreference so full details are sent to the log; Make Invoke-WebRequest faster
$VerbosePreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# OneDrive
$AppChildPath = Join-Path -Path $AppParentPath -ChildPath "MicrosoftOneDrive"
$AppUpdate = Get-MicrosoftOneDrive | Where-Object { $_.Ring -eq "Production" }
$OutFile = Join-Path -Path $AppChildPath -ChildPath $(Split-Path -Path $AppUpdate.URI -Leaf)
Invoke-WebRequest -Uri $AppUpdate.URI -OutFile $OutFile -UseBasicParsing
Unblock-File -Path $OutFile

# FSLogix
$AppChildPath = Join-Path -Path $AppParentPath -ChildPath "MicrosoftFSLogixApps"
$AppUpdate = Get-MicrosoftFSLogixApps
$OutFile = Join-Path -Path $AppChildPath -ChildPath $(Split-Path -Path $AppUpdate.URI -Leaf)
Invoke-WebRequest -Uri $AppUpdate.URI -OutFile $OutFile -UseBasicParsing
Expand-Archive -Path $OutFile -DestinationPath $(Join-Path -Path $AppChildPath -ChildPath "FSLogixApps")
Remove-Item -Path $OutFile -Force
Copy-Item -Path $(Join-Path -Path $(Join-Path -Path $AppChildPath -ChildPath "FSLogixApps") -ChildPath "x64\Release\*.exe") -Destination $AppChildPath -Force
Remove-Item -Path $(Join-Path -Path $AppChildPath -ChildPath "FSLogixApps") -Recurse -Force
Get-ChildItem -Path $AppChildPath | Unblock-File

# VMware Tools
$AppChildPath = Join-Path -Path $AppParentPath -ChildPath "VMwareTools"
$AppUpdate = Get-VMwareTools | Where-Object { $_.Architecture -eq "x64" }
$OutFile = Join-Path -Path $AppChildPath -ChildPath $(Split-Path -Path $AppUpdate.URI -Leaf)
Invoke-WebRequest -Uri $AppUpdate.URI -OutFile $OutFile -UseBasicParsing
Unblock-File -Path $OutFile
Get-ChildItem -Path $AppChildPath -Exclude (Get-Item -Path $OutFile).Name | Remove-Item -Force

# XenTools
$AppChildPath = Join-Path -Path $AppParentPath -ChildPath "XenTools"
$AppUpdate = Get-CitrixXenServerTools | Where-Object { $_.Architecture -eq "x64" }
$OutFile = Join-Path -Path $AppChildPath -ChildPath $(Split-Path -Path $AppUpdate.URI -Leaf)
Invoke-WebRequest -Uri $AppUpdate.URI -OutFile $OutFile -UseBasicParsing
Unblock-File -Path $OutFile

# Image customisations
$URL = "https://github.com/aaronparker/image-customise/archive/main.zip"
$AppChildPath = Join-Path -Path $AppParentPath -ChildPath "ImageCustomisations"
$OutFile = Join-Path -Path $AppChildPath -ChildPath $(Split-Path -Path $URL -Leaf)
Invoke-WebRequest -Uri $URL -OutFile $OutFile -UseBasicParsing
Expand-Archive -Path $OutFile -DestinationPath $AppChildPath
Remove-Item -Path $OutFile -Force
Copy-Item -Path $(Join-Path -Path $(Join-Path -Path $AppChildPath -ChildPath "image-customise-main") -ChildPath "*.ps1") -Destination $AppChildPath -Force
Copy-Item -Path $(Join-Path -Path $(Join-Path -Path $AppChildPath -ChildPath "image-customise-main") -ChildPath "*.xml") -Destination $AppChildPath -Force
Remove-Item -Path $(Join-Path -Path $AppChildPath -ChildPath "image-customise-main") -Recurse -Force

# VcRedists
$Path = "C:\Temp\VcRedists"

# Download the VcRedists
If (!(Test-Path -Path $Path)) { New-Item -Path $Path -ItemType Directory }
Save-VcRedist -VcList (Get-VcList) -Path $Path

# Add to the deployment share
Update-VcMdtApplication -VcList (Get-VcList) -Path $Path -MdtPath $DeploymentShare -Silent
Update-VcMdtBundle -MdtPath $DeploymentShare
