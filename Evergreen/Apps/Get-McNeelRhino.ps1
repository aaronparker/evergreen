Function Get-McNeelRhino {
    <#
        .SYNOPSIS
            Get the current version and download URIs for the supported releases of Rhino.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Filter
    )

    foreach ($Release in $res.Get.Releases.GetEnumerator()) {

        # Query the Rhino update API
        $UpdateFeed = Invoke-WebRequestWrapper $Release.Value

        If ($Null -ne $UpdateFeed) {

            # Convert response from UTF8
            Try { 
                $Update = [System.Text.Encoding]::UTF8.GetString($Updatefeed)
            }
            Catch {
                Throw "$($MyInvocation.MyCommand): failed to convert feed into to UTF8."
            
            }

            # Convert the content to XML to grab the version number
            Try {
                [System.XML.XMLDocument] $xmlDocument = $Update 
            }
            Catch {
                Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert feed into an XML object."
            }
                
            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version = $xmlDocument.ProductVersionDescription.Version
                Release = $Release.Name
                URI     = $xmlDocument.ProductVersionDescription.DownloadUrl
            }
            Write-Output -InputObject $PSObject
            
        }
    }
}
