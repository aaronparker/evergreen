# Retrieve details from an Evergreen library

Once the library has been populated it will contain information that describes the library - the library configuration file, application version information for each application, and the application installers. Over time, the library will contain information on multiple applications and versions. `Get-EvergreenLibrary` can be used to retrieve application information from the library:

```powershell
Get-EvergreenLibrary -Path "\\server\EvergreenLibrary"

Library   : @{Name=EvergreenLibrary; Applications=System.Object[]}
Inventory : {@{ApplicationName=Microsoft.NET; Versions=}, @{ApplicationName=MicrosoftOneDrive; Versions=System.Object[]}, @{ApplicationName=MicrosoftEdge; Versions=System.Object[]},
            @{ApplicationName=MicrosoftTeams; Versions=}}
```

The object returned contains two properties - `Library` which is the library defined in `EvergreenLibrary.json`:

```powershell
Name         : EvergreenLibrary
Applications : {@{Name=Microsoft.NET; EvergreenApp=Microsoft.NET; Filter=$_.Architecture -eq "x64" -and $_.Installer -eq "windowsdesktop" -and $_.Channel -eq "LTS"},
               @{Name=MicrosoftOneDrive; EvergreenApp=MicrosoftOneDrive; Filter=$_.Architecture -eq "AMD64" -and $_.Ring -eq "Production"}, @{Name=MicrosoftEdge;
               EvergreenApp=MicrosoftEdge; Filter=$_.Platform -eq "Windows" -and $_.Channel -eq "Stable" -and $_.Release -eq "Enterprise" -and $_.Architecture -eq "x64"},
               @{Name=MicrosoftTeams; EvergreenApp=MicrosoftTeams; Filter=$_.Ring -eq "General" -and $_.Architecture -eq "x64" -and $_.Type -eq "msi"}}
```

And `Inventory` which is the application version information for each application in the library:

```powershell
ApplicationName : Microsoft.NET
Versions        : @{Version=6.0.7; URI=https://download.visualstudio.microsoft.com/download/pr/dc0e0e83-0115-4518-8b6a-590ed594f38a/65b63e41f6a80decb37fa3c5af79a53d/windowsdesktop-runtime-6
                  .0.7-win-x64.exe; Type=exe; Installer=windowsdesktop; Channel=LTS; Architecture=x64}

ApplicationName : MicrosoftOneDrive
Versions        : {@{Version=22.131.0619.0001; URI=https://oneclient.sfx.ms/Win/Prod/22.131.0619.0001/amd64/OneDriveSetup.exe; Type=exe;
                  Sha256=oRJK6vbSwqa8EUWBwjnXitZxz8r4RDrTcamdbEB20Mg=; Ring=Production; Architecture=AMD64}, @{Version=22.141.0703.0002;
                  URI=https://oneclient.sfx.ms/Win/Prod/22.141.0703.0002/amd64/OneDriveSetup.exe; Type=exe; Sha256=4jrVokZX9R7AGT9wyrwdVeQWxW1q1/4YTYW/A+EVUrk=; Ring=Production;
                  Architecture=AMD64}}

ApplicationName : MicrosoftEdge
Versions        : {@{Version=103.0.1264.62;
                  URI=https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/4a067ebd-1766-4463-a54b-1e5a525cb90f/MicrosoftEdgeEnterpriseX64.msi; Release=Enterprise;
                  Platform=Windows; Hash=5DA115179E6D4C84B5204BC135ABCB81AA8512C2AD0909440663E8332EE20FD0; Channel=Stable; Architecture=x64}, @{Version=103.0.1264.71;
                  URI=https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/52956063-8ecb-4407-9ac1-52db779bb126/MicrosoftEdgeEnterpriseX64.msi; Release=Enterprise;
                  Platform=Windows; Hash=9AB4B17469440056F2E59D7AA04622C6584DC8B47C087300DC97D979AC7D9F99; Channel=Stable; Architecture=x64}}

ApplicationName : MicrosoftTeams
Versions        : @{Version=1.5.00.17656; URI=https://statics.teams.cdn.office.net/production-windows-x64/1.5.00.17656/Teams_windows_x64.msi; Type=msi; Ring=General; Architecture=x64}
```
