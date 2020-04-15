Function Get-SystemNetRequest {
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
    
    Try {
        $httpWebRequest = [System.Net.WebRequest]::Create($Uri)
        $httpWebRequest.MaximumAutomaticRedirections = 3
        $httpWebRequest.AllowAutoRedirect = $true
        $webResponse = $httpWebRequest.GetResponse()
        $responseStream = $webResponse.GetResponseStream()
        $streamReader = New-Object -TypeName "System.IO.StreamReader" $responseStream
        $result = $streamReader.ReadToEnd()
    }
    Catch [System.Exception] {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Response: $($_.Exception.Response.StatusCode) - $($_.Exception.Response.ReasonPhrase)"
        Throw $_
    }
    Finally {
        Write-Output -InputObject $result
        $webResponse.Dispose()
    }
}
