---
external help file: Evergreen-help.xml
Module Name: Evergreen
online version: https://stealthpuppy.com/evergreen/test.html
schema: 2.0.0
---

# Invoke-EvergreenLibraryUpdate

## SYNOPSIS
Invokes the update and download of application installers in an Evergreen library.
\`Invoke-EvergreenLibraryUpdate\` reads the library manifest (\`EvergreenLibrary.json\`) which defines the applications in the library and uses \`Get-EvergreenApp\` and \`Save-EvergreenApp\` to download the latest installers to the library.

## SYNTAX

```
Invoke-EvergreenLibraryUpdate [-Path] <FileInfo> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
An Evergreen library can be used to maintain multiple versions of application installers, rather than always using the latest installer.
An Evergreen library allows you to install the version of an application required for a specific environment including rolling back to a previous version of an application.
An Evergreen library also enables you to build an image build without requiring internet access, by downloading the application installers to the library and then using those installers during the image build process.

\`Invoke-EvergreenLibraryUpdate\` invokes the update and download of application installers in an Evergreen library.
\`Invoke-EvergreenLibraryUpdate\` reads the library manifest (\`EvergreenLibrary.json\`) which defines the applications in the library and uses \`Get-EvergreenApp\` and \`Save-EvergreenApp\` to download the latest installers to the library.

## EXAMPLES

### EXAMPLE 1
```
Invoke-EvergreenLibraryUpdate -Path "E:\EvergreenLibrary"
```

Description: \`Invoke-EvergreenLibraryUpdate\` reads the library manifest \`EvergreenLibrary.json\` located in E:\EvergreenLibrary which defines the applications for that library.
It uses \`Get-EvergreenApp\` and \`Save-EvergreenApp\` to download the latest installers to the library.

## PARAMETERS

### -Path
Specifies the path to the Evergreen library.
The path must include EvergreenLibrary.json, in the expected structure, which defines the applications to be stored in the library.

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
Invoke-EvergreenLibraryUpdate accepts a string parameter.

## OUTPUTS

## NOTES
Site: https://stealthpuppy.com Author: Aaron Parker Twitter: @stealthpuppy

## RELATED LINKS

[Update an Evergreen library:](https://stealthpuppy.com/evergreen/updatelibrary.html)

