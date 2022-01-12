# How Evergreen works

!!! attention "Attention"
    Application version and download links are only pulled from official sources (vendor web site, application update API, vendor's official repositories on GitHub or SourceForge etc.) and never a third party.

Evergreen uses an approach that returns at least the version number and download URI for applications programmatically - thus for each run an Evergreen function it should return the latest version and download link.

Evergreen uses several strategies to return the latest version of software:

1. Application update APIs - by using the same approach as the application itself, Evergreen can consistently return the latest version number and download URI - e.g. [Microsoft Edge](https://github.com/aaronparker/Evergreen/blob/main/Evergreen/Public/Get-MicrosoftEdge.ps1), [Mozilla Firefox](https://github.com/aaronparker/Evergreen/blob/main/Evergreen/Public/Get-MozillaFirefox.ps1) or [Microsoft OneDrive](https://github.com/aaronparker/Evergreen/blob/main/Evergreen/Public/Get-MicrosoftOneDrive.ps1). [Fiddler](https://www.telerik.com/fiddler) can often be used to find where an application queries for updates
2. Repository APIs - repo hosts including GitHub and SourceForge have APIs that can be queried to return application version and download links - e.g. [Atom](/Evergreen/Public/Get-Atom.ps1), [Notepad++](https://github.com/aaronparker/Evergreen/blob/main/Evergreen/Public/Get-NotepadPlusPlus.ps1) or [WinMerge](https://github.com/aaronparker/Evergreen/blob/main/Evergreen/Public/Get-WinMerge.ps1)
3. Web page queries - often a vendor download pages will include a query that returns JSON when listing versions and download links - this avoids page scraping. Evergreen can mimic this approach to return application download URLs; however, this approach is likely to fail if the vendor changes how their pages work - e.g., [Adobe Acrobat Reader DC](https://github.com/aaronparker/Evergreen/blob/main/Evergreen/Apps/Get-AdobeAcrobatReaderDC.ps1)
4. Static URLs - some vendors provide static or evergreen URLs to their application installers. These URLs often provide additional information in the URL that can be used to determine the application version and can be resolved to the actual target URL - e.g., [Microsoft FSLogix Apps](https://github.com/aaronparker/Evergreen/blob/main/Evergreen/Apps/Get-MicrosoftFSLogixApps.ps1) or [Zoom](https://github.com/aaronparker/Evergreen/blob/main/Evergreen/Apps/Get-Zoom.ps1)

## What Evergreen Does Not Do

Evergreen does not scape HTML - scraping web pages to parse text and determine version strings and download URLs can be problematic when text in the page changes or the page is out of date. Pull requests that use web page scraping will be closed.

While the use of RegEx to determine application properties (particularly version numbers) is used for some applications, this approach is not preferred, if possible.

For additional applications where the only recourse it to use web page scraping, see the [Nevergreen](https://github.com/DanGough/Nevergreen) project.
