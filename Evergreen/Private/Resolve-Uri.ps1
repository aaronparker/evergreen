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
        $webResponse = $httpWebRequest.GetResponse()
        Write-Output -InputObject $webResponse.ResponseUri.AbsoluteUri
    }
    catch {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Response: $($webResponse.StatusCode) - $($webResponse.StatusDescription)"
        Throw $_
    }
    finally {
        $webResponse.Dispose()
    }
}
