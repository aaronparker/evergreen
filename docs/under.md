# Under the hood

Evergreen is a self-contained PowerShell module, that once installed does not require access to any additional content other than official vendor sources used to retrieve details for a specified application.

Due to Evergreen's approach to finding the latest version and download URL for an application, custom code is required for most applications. While some applications have a common source location such as GitHub (that provides an API for releases), most applications require querying an application specific API or site to return details for that application.

## Module structure

Evergreen includes the following directory structure:

* `<ModuleBase>/Public` - public functions including `Get-EvergreenApp`, `Find-EvergreenApp` and `Save-EvergreenApp`
* `<ModuleBase>/Apps` - internal per-application functions that contain the logic for retrieving application details. These are often unique for each application
* `<ModuleBase>/Shared` - internal functions used by specific apps to reduce repeated code
* `<ModuleBase>/Manifests` - each application includes a manifest in JSON format that includes application specific details used by the per-application functions. These describe details of the application including URLs used to determine the latest version of the application
* `<ModuleBase>/Private` - internal functions containing reusable code

### Public

The `Public` folder includes all functions exported from Evergreen:

* `ConvertTo-DotNetVersionClass.ps1`
* `Export-EvergreenApp.ps1`
* `Export-EvergreenManifest.ps1`
* `Find-EvergreenApp.ps1`
* `Get-EvergreenApp.ps1`
* `Get-EvergreenAppFromApi.ps1`
* `Get-EvergreenAppFromLibrary.ps1`
* `Get-EvergreenEndpointFromApi.ps1`
* `Get-EvergreenLibrary.ps1`
* `New-EvergreenLibrary.ps1`
* `Save-EvergreenApp.ps1`
* `Start-EvergreenLibraryUpdate.ps1`
* `Test-EvergreenApp.ps1`

### Apps

The `Apps` folder includes application specific functions that do the hard work of determining details for the target application.

For example, `Get-MicrosoftEdge` queries the official Edge versions list hosted at `https://edgeupdates.microsoft.com/api/products`. This allows the function to use the same process that Edge itself uses to determine the latest version of Edge and the URL to download the installer. When using `Get-EvergreenApp -Name MicrosoftEdge`, `Get-EvergreenApp` calls `Get-MicrosoftEdge` and passes the result back to the pipeline.

While most functions includes code unique to that application, several applications use GitHub or SourceForge as a source to determine application versions and updates thus these functions can use more shared code than other functions.

### Manifests

Each application includes a manifest file in JSON format that includes details that are used by the internal application function when retrieving the application version and download URI. The manifest structure includes three primary properties - `Name` (the vendor and application name), `Source` (a link to an official site), and `Get`, which defines items such as the URL used to find the application updates. The base manifest structure will look similar to the following:

```json
{
    "Name": "Vendor Application name",
    "Source": "https://www.vendorwebsite.com/product",
    "Get": {
        "Update": {
            "Uri": "https://update.vendorwebsite.com/api/product"
        }
    },
    "Download": {
            "Uri": "https://download.vendorwebsite.com/files"
    },
}
```

Additionally, each manifest defines the property `Install` that includes details about installing the application; however, note that while this is included for many applications, this isn't intended to provide a definitive construct for installing applications.

### Private

The `Private` folder includes re-usable code, used by many of the application functions. Several key functions include:

* `Get-GitHubRepoRelease` - returns releases from a target GitHub repository
* `Get-SourceForgeRepoRelease` - returns releases from a target SourceForge repository
* `Invoke-EvergreenRestMethod` - provides logic around `Invoke-RestMethod` to return content from an update API
* `Invoke-EvergreenWebRequest` - provides logic around `Invoke-WebRequest` to return the content from a target URI
