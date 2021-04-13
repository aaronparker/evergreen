---
external help file: Evergreen-help.xml
Module Name: Evergreen
online version: https://stealthpuppy.com/Evergreen/use.html
schema: 2.0.0
---

# Get-EvergreenApp

## SYNOPSIS

Returns the latest version and download URL/s for an application supported by the Evergreen module.

## SYNTAX

```powershell
Get-EvergreenApp [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION

Queries the internal application functions and manifests included in the module to find the latest version and download link/s for the specified application.

The output from this function can be passed to Where-Object to filter for a specific download based on properties including processor architecture, file type or other properties.

`Get-EvergreenApp` uses official vendor sites including update APIs, web queries, and code repository locations to return details of a target application at run time.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-EvergreenApp -Name "MicrosoftEdge"

Version      : 89.0.774.76
Platform     : Windows
Channel      : Stable
Release      : Enterprise
Architecture : x64
Date         : 12/4/2021
Hash         : 9E7A29B4BE6E1CD707F80B4B79008F19D2D5DD5C774D317A493EC6DE5BE0B7D7
URI          : https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/4d12f620-174c-4259-85e6-8a80ea45ff10/MicrosoftEdgeEnterpriseX64.msi
```

Description:
Returns the current version and download URLs for Microsoft Edge using the official Microsoft Edge update API at [https://edgeupdates.microsoft.com/api/products](https://edgeupdates.microsoft.com/api/products).

### EXAMPLE 2

```powershell
Get-EvergreenApp -Name "MicrosoftEdge" | Where-Object { $_.Architecture -eq "x64" -and $_.Channel -eq "Stable" -and $_.Release -eq "Enterprise" }
```

Description:
Returns the current version and download URL for the Stable channel of the 64-bit Enterprise ring of Microsoft Edge.

### EXAMPLE 3

```powershell
(Get-EvergreenApp -Name "MicrosoftOneDrive" | Where-Object { $_.Type -eq "Exe" -and $_.Ring -eq "Production" }) | `
    Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } | Select-Object -First 1
```

Description:
Returns the current version and download URL for the Production ring of Microsoft OneDrive and selects the latest version in the event that more that one release is returned.

### EXAMPLE 4

```powershell
Get-EvergreenApp -Name "AdobeAcrobatReaderDC" | Where-Object { $_.Language -eq "English" -and $_.Architecture -eq "x86" }
```

Description:
Returns the current version and download URL that matches the English language, 32-bit release of Adobe Acrobat Reader DC.

### EXAMPLE 5

```powershell
Find-EvergreenApp -Name "Teams" | Get-EvergreenApp
```

Description:
Lists the available applications matching the string "Teams" (for example, Microsoft Teams), and passes the output to Get-EvergreenApp, which will query the matching application name. Note that Get-EvergreenApp will only process the first application returned on the pipeline and not all multiple matching applications.

### EXAMPLE 6

```powershell
Get-EvergreenApp -Name "MicrosoftTeams" | Save-EvergreenApp -Path "C:\Apps\Teams"
```

Description:
Get-EvergreenApp returns the details for the latest version of Microsoft Teams which is passed via the pipeline to Save-EvergreenApp. The output is used to save the target URLs to C:\Apps\Teams using a folder structure based on the returned object. In this case, the Ring and Architecture properties of the returned object will be used in the folder structure.

## PARAMETERS

### -Name

The application name to return details for.
The list of supported applications can be found with Find-EvergreenApp.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

Site: https://stealthpuppy.com
Author: Aaron Parker
Twitter: @stealthpuppy

## RELATED LINKS

[https://stealthpuppy.com/Evergreen/use.html](https://stealthpuppy.com/Evergreen/use.html)
