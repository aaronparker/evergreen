Function Get-VMwareHorizonClient {
    <#
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param ()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Query the Horizon Client update feed
    $params = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $Updates = Invoke-RestMethodWrapper @params  #-Uri "https://softwareupdate.vmware.com/horizon-clients/viewcrt-mac/viewcrt-windows.xml"

    # Select the latest version
    # TODO: Update this to find the latest version based on the Url property as well
    # $LatestVersion = $Updates.($res.Get.Update.Property) | `
    $LatestVersion = $Updates.metaList.metadata | `
        Sort-Object -Property @{ Expression = { [System.Version]$_.version }; Descending = $true } | `
        Select-Object -First 1

    # Download the version specific update XML in Gzip format
    If ($Null -ne $LatestVersion) {
        try {
            $Url = "$($res.Get.Download.Uri)$($LatestVersion.Url.TrimStart("../"))"
            $GZipFile = Join-Path -Path $([System.IO.Path]::GetTempPath()) -ChildPath (Split-Path -Path $Url -Leaf)
            $params = @{
                Uri             = $Url
                OutFile         = $GZipFile
                UseBasicParsing = $True
                UserAgent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
            }
            Invoke-WebRequest @params
        }
        catch {
            Throw "$($MyInvocation.MyCommand): Failed to download from: $Url, to $GZipFile."
        }
    }
    Else {
        Throw "$($MyInvocation.MyCommand): Failed to determine metadata property for the Horizon Client latest version."
    }
    
    # Expand the downloaded Gzip file to get the XMl file
    $ExpandFile = Expand-GzipArchive -Path $GZipFile

    # Get the version specific details from the XML file
    try {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Read XML content from: $ExpandFile."
        $Content = Get-Content -Path $ExpandFile
        [System.XML.XMLDocument] $xmlDocument = $Content
        $Version = (Select-Xml -Xml $xmlDocument -XPath $res.Get.Download.VersionXPath | Select-Object –ExpandProperty "node").($res.Get.Download.VersionProperty)
        $FileName = (Select-Xml -Xml $xmlDocument -XPath $res.Get.Download.FileXPath | Select-Object –ExpandProperty "node").($res.Get.Download.FileProperty)
    }
    catch {
        Throw "$($MyInvocation.MyCommand): Failed to convert metadata XML."
    }
    finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Delete: $GZipFile."
        Remove-Item -Path $GZipFile -ErrorAction "SilentlyContinue"
        Write-Verbose -Message "$($MyInvocation.MyCommand): Delete: $ExpandFile."
        Remove-Item -Path $ExpandFile -ErrorAction "SilentlyContinue"
    }

    # Build the object and write to the pipeline
    If (($Null -ne $Version) -and ($Null -ne $FileName)) {
        $PSObject = [PSCustomObject] @{
            Version = "$($Version.version).$($Version.buildNumber)"
            URI     = "$($res.Get.Download.Uri)$($Version.productId)/$($Version.version)/$($Version.buildNumber)/$($FileName)"
        }
        Write-Output -InputObject $PSObject
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to return usable properties from the XML file."
    }
}
