Function Resolve-Uri {
    <#
        .SYNOPSIS
        Resolved a URL that returns a 301/302 response and returns the redirected URL.
    #>
    [OutputType([System.String])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Uri
    )

    try {
        $httpWebRequest = [System.Net.WebRequest]::Create($Uri)
        $httpWebRequest.MaximumAutomaticRedirections = 3
        $httpWebRequest.AllowAutoRedirect = $true
        $httpWebRequest.UseDefaultCredentials = $true
        $webResponse = $httpWebRequest.GetResponse()
    }
    catch {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Response: $($webResponse.StatusCode) - $($webResponse.StatusDescription)"
        Throw $_
    }
    finally {
        If ($webResponse) {

            Write-Verbose -Message "$($MyInvocation.MyCommand): Response: [$($webResponse.StatusCode)]."
            Write-Verbose -Message "$($MyInvocation.MyCommand): Resolved to: [$($webResponse.ResponseUri.AbsoluteUri)]."
            
            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                LastModified  = $webResponse.LastModified
                ContentLength = $webResponse.ContentLength
                Headers       = $webResponse.Headers
                ResponseUri   = $webResponse.ResponseUri
                StatusCode    = $webResponse.StatusCode
            }
            Write-Output -InputObject $PSObject
            $webResponse.Dispose()
        }
    }
}
