---
external help file: Evergreen-help.xml
Module Name: Evergreen
online version: https://stealthpuppy.com/evergreen/getlibrary.html
schema: 2.0.0
---

# Get-EvergreenLibrary

## SYNOPSIS

Returns details about an Evergreen library including details about the applications configured in the library and the downloaded application binaries and versions.

## SYNTAX

```
Get-EvergreenLibrary [-Path] <FileInfo> [<CommonParameters>]
```

## DESCRIPTION

Returns details about an Evergreen library at a specified path. This will include details of the library stored in `EvergreenLibrary.json` and application version information stored for each application in the library. Application downloads and application version information must first be downloaded via `Invoke-EvergreenLibraryUpdate`.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-EvergreenLibrary -Path "E:\EvergreenLibrary"
```

Returns details about the Evergreen library at E:\EvergreenLibrary, including application version information stored for each application.

## PARAMETERS

### -Path

Specify the path to the library.

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.IO.FileInfo

## OUTPUTS

### System.Object

## NOTES

Site: https://stealthpuppy.com
Author: Aaron Parker
Twitter: @stealthpuppy

## RELATED LINKS

[Create an Evergreen library:](https://stealthpuppy.com/evergreen/getlibrary.html)
