Function Resolve-SystemNetWebRequest {
    <#
        .SYNOPSIS
            Resolve a URL that returns a 301/302 response and returns the redirected URL
            Uses System.Net.WebRequest to find 301/302 headers and return the ResponseUri
    #>
    [OutputType([System.String])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Uri,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Int32] $MaximumRedirection = 3
    )

    try {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Attempting to resolve: $Uri."
        $httpWebRequest = [System.Net.WebRequest]::Create($Uri)
        $httpWebRequest.MaximumAutomaticRedirections = $MaximumRedirection
        $httpWebRequest.AllowAutoRedirect = $true
        $httpWebRequest.UseDefaultCredentials = $true
        $webResponse = $httpWebRequest.GetResponse()
    }
    catch {
        Write-Warning -Message "$($MyInvocation.MyCommand): Error at URI: $Uri."
        Write-Warning -Message "$($MyInvocation.MyCommand): Response: $($webResponse.StatusCode) - $($webResponse.StatusDescription)"
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
