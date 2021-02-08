<#
    .SYNOPSIS
    Exports a HTML report of output from each function in the Evergreen module
#>

# Install modules
Install-PackageProvider -Name "NuGet" -MinimumVersion 2.8.5.208 -ErrorAction "SilentlyContinue"
Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"  -ErrorAction "SilentlyContinue"
Install-Module -Name "Evergreen" -Force
Install-Module -Name "PSWriteHtml" -Force


# Variables
$ReportPath = Join-Path -Path $PWD -ChildPath "Evergreen.html"
Write-Host "Output to: $ReportPath."
$Module = "Evergreen"
$commands = Get-Command -Module $Module -Verb Get | Where-Object { $_.CommandType -eq "Function" }

# Write the HTML report
New-HTML -TitleText $Module -Online -FilePath $ReportPath -ShowHTML:$False {

    ForEach ($command in $commands) {
        # Run each command and capture output in a variable
        New-Variable -Name "tempOutput" -Value (. $command.Name ) -ErrorAction "SilentlyContinue"
        If ($tempOutput) {
            $Output = (Get-Variable -Name "tempOutput").Value
            Remove-Variable -Name tempOutput

            # Get function string resources
            $res = Export-EvergreenFunctionStrings -AppName ("$($command.Name)".Split("-"))[1]

            # Write the HTML section
            If ($Null -ne $res) {
                New-HTMLContent -HeaderText $res.Name -BackgroundColor SkyBlue -CanCollapse {
                    New-HTMLTable -ArrayOfObjects $Output -HideFooter
                }
            }
            Remove-Variable -Name "tempOutput" -ErrorAction "SilentlyContinue"
        }
    }
}
Write-Host "Complete."
