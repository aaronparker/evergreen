Function Get-MicrosoftSsms {
    <#
        .SYNOPSIS
            Returns the latest SQL Server Management Studio release version number and download.

        .DESCRIPTION
            Returns the latest SQL Server Management Studio release version number and download.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-MicrosoftSsms

            Description:
            Returns the latest SQL Server Management Studio for Windows version number and download URL
    #>
    [Alias("Get-MicrosoftSQLServerManagementStudio")]
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # SQL Management Studio downloads/versions documentation
    $Content = Invoke-WebContent -Uri $res.Get.Uri -Raw

    # Convert content to XML document
    If ($Null -ne $Content) {
        Try {
            [System.XML.XMLDocument] $xmlDocument = $Content
        }
        Catch [System.IO.IOException] {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert feed into an XML object."
            Throw $_.Exception.Message
        }
        Catch [System.Exception] {
            Throw $_
        }

        # Build an output object by selecting installer entries from the feed
        If ($xmlDocument -is [System.XML.XMLDocument]) {
            ForEach ($entry in $xmlDocument.feed.entry) {

                ForEach ($components in ($entry.component | Where-Object { $_.name -eq $res.Get.MatchName })) {

                    # Follow the URL returned to get the actual download URI
                    If (Test-PSCore) {
                        $URI = $res.Get.DownloadUri
                        Write-Warning -Message "PowerShell Core: skipping follow URL: $URI."
                    }
                    Else {
                        # Follow the DownloadUri (aka.ms URL)
                        $iwrParams = @{
                            Uri                = $res.Get.DownloadUri
                            UserAgent          = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
                            MaximumRedirection = 0
                            UseBasicParsing    = $True
                            ErrorAction        = "SilentlyContinue"
                        }
                        $Response = Invoke-WebRequest @iwrParams

                        # Follow the response (fwlink URL)
                        $iwrParams = @{
                            Uri                = $Response.Headers.Location
                            UserAgent          = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
                            MaximumRedirection = 0
                            UseBasicParsing    = $True
                            ErrorAction        = "SilentlyContinue"
                        }
                        $Response = Invoke-WebRequest @iwrParams
                        $URI = $Response.Headers.Location
                    }

                    # Construct the output; Return the custom object to the pipeline
                    $PSObject = [PSCustomObject] @{
                        Version = $entry.Component.version
                        Date    = ([DateTime]::Parse($entry.updated))
                        Title   = $entry.Title
                        URI     = $URI
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to read Microsoft SQL Server Management Studio update feed."
    }
}
