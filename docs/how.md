# How Evergreen works

!!! attention "Attention"
    Application version and download information is only pulled from official vendor sources (vendor web site, vendor maintained application update API, vendor's official repositories on GitHub or SourceForge etc.) and never a third party.

Evergreen uses an approach that returns at least the version number and download URI for applications programmatically - thus for each run an Evergreen function it should return the latest version and download link.

Evergreen uses several strategies to return the latest version of software:

1. Application update APIs - by using the same approach as the application itself, Evergreen can consistently return the latest version number and download URI - e.g., [Microsoft Edge](/Evergreen/Public/Get-MicrosoftEdge.ps1), [Mozilla Firefox](/Evergreen/Apps/Get-MozillaFirefox.ps1) or [Microsoft OneDrive](/Evergreen/Apps/Get-MicrosoftOneDrive.ps1). [Fiddler](https://www.telerik.com/fiddler) can often be used to find where an application queries for updates
2. Repository APIs - repo hosts including GitHub and SourceForge have APIs that can be queried to return application version and download links - e.g., [Audacity](/Evergreen/Apps/Get-Audacity.ps1), [Notepad++](/Evergreen/Apps/Get-NotepadPlusPlus.ps1) or [WinMerge](/Evergreen/Apps/Get-WinMerge.ps1)
3. Web page queries - often a vendor download pages will include a query that returns JSON when listing versions and download links - this avoids page scraping. Evergreen can mimic this approach to return application download URLs; however, this approach is likely to fail if the vendor changes how their pages work - e.g., [Adobe Acrobat Reader DC](/Evergreen/Apps/Get-AdobeAcrobatReaderDC.ps1)
4. Static URLs - some vendors provide static or evergreen URLs to their application installers. These URLs often provide additional information in the URL that can be used to determine the application version and can be resolved to the actual target URL - e.g., [Microsoft FSLogix Apps](/Evergreen/Apps/Get-MicrosoftFSLogixApps.ps1) or [Zoom](/Evergreen/Apps/Get-Zoom.ps1)

## What Evergreen Does Not Do

**Evergreen does not scape HTML** - scraping web pages to parse text and determine version strings and download URLs can be problematic when text in the page changes or the page is out of date. While the use of RegEx to determine application properties (particularly version numbers) is used for some applications, this approach is not preferred, if possible.

Pull requests to the Evergreen project that use web page scraping will be closed. For additional applications where the only recourse it to use web page scraping, see the [Nevergreen](https://github.com/DanGough/Nevergreen) project.

**Evergreen does not query non-vendor sources** - the intention is to use the same update mechanisms that an application uses to find an update. Where this is not possible, Evergreen may use data sources (i.e. JSON or XML) used by a vendor's download web page (e.g., `AdobeAcrobatReaderDC`) or another vendor maintained source (e.g., an official GitHub repository).
