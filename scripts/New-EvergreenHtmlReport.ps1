<#
    .SYNOPSIS
    Exports a HTML report of output from each function in the Evergreen module
#>

# Install modules
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.208
If (Get-PSRepository -Name PSGallery | Where-Object { $_.InstallationPolicy -ne "Trusted" }) {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}
If ([Version]((Find-Module -Name Evergreen).Version) -gt (Get-Module -Name Evergreen).Version) {
    Install-Module -Name Evergreen -Force
}
If ([Version]((Find-Module -Name PSWriteHtml).Version) -gt (Get-Module -Name PSWriteHtml).Version) {
    Install-Module -Name PSWriteHtml -Force
}

# Variables
$ReportPath = Join-Path -Path $PWD -ChildPath "Evergreen.html"
$Module = "Evergreen"
$commands = Get-Command -Module $Module -Verb Get | Where-Object { $_.CommandType -eq "Function" }

# Write the HTML report
New-HTML -TitleText $Module -UseCssLinks:$true -UseJavaScriptLinks:$true -FilePath $ReportPath -ShowHTML {

    ForEach ($command in $commands) {
        # Run each command and capture output in a variable
        New-Variable -Name "tempOutput" -Value (. $command.Name )
        $Output = (Get-Variable -Name "tempOutput").Value
        Remove-Variable -Name tempOutput

        # Get function string resources
        $res = Export-EvergreenFunctionStrings -AppName ("$($command.Name)".Split("-"))[1]

        # Write the HTML section
        If ($Null -ne $res) {
            New-HTMLContent -HeaderText $res.Name -BackgroundColor SkyBlue -CanCollapse {
                New-HTMLPanel {
                    New-HTMLTable -ArrayOfObjects $Output -HideFooter
                }
            }
        }
    }
}
