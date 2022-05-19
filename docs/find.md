# Find supported applications

`Find-EvergreenApp` is used to return a list of applications supported by Evergreen. For example, let's find out whether the Microsoft FSLogix Apps agent is supported by Evergreen:

```powershell
Find-EvergreenApp -Name "FSLogix"
```

The Microsoft FSLogix Apps agent is supported by Evergreen, so this returns output like this:

```powershell
Name        : MicrosoftFSLogixApps
Application : Microsoft FSLogix Apps
Link        : https://docs.microsoft.com/fslogix/
```

The value of the `Name` property can be used with `Get-EvergreenApp` to return the latest the Microsoft FSLogix Apps agent:

```powershell
Get-EvergreenApp -Name "MicrosoftFSLogixApps"
```

Alternatively, we can pass the output from `Find-EvergreenApp` directly to `Get-EvergreenApp`:

```powershell
Find-EvergreenApp -Name "FSLogix" | Get-EvergreenApp
```

Output from `Find-EvergreenApp` can be paged to review the entire supported application list with the following command:

```powershell
Find-EvergreenApp | Out-Host -Paging
```

## Output

`Find-EvergreenApp` outputs three properties:

* `Name` - the identifier of the supported application. This name matches that used in the application manifest
* `Application` - the application manifest includes the full application name
* `Link` - each application manifest includes a URL to the application's primary home page

The output from `Find-EvergreenApp` will look similar to the following example:

```powershell
Name                 Application             Link
----                 -----------             ----
1Password            1Password               https://1password.com/
7zip                 7zip                    https://www.7-zip.org/
AdobeAcrobat         Adobe Acrobat           https://helpx.adobe.com/au/enterprise/using/deploying-acrobat.html
AdobeAcrobatReaderDC Adobe Acrobat Reader DC https://acrobat.adobe.com/us/en/acrobat/pdf-reader.html
AdobeBrackets        Adobe Brackets          http://brackets.io/
```

## Parameters

### Name

The `-Name` parameter is used to specify the application name to return details for. This is a required parameter. The list of supported applications can be found with `Find-EvergreenApp`.

## Alias

`Find-EvergreenApp` has an alias of `fea` to simplify retrieving supported applications, for example:

```powershell
PS /Users/aaron> fea

Name      Application   Link
----      -----------   ----
1Password 1Password     https://1password.com/
7zip      7zip          https://www.7-zip.org/
```
