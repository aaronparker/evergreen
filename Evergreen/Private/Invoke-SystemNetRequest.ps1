Function Invoke-SystemNetRequest {
    <#
        .SYNOPSIS
            Uses System.Net.WebRequest to make a HTTP request and returns the response.
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
        Write-Output -InputObject $result
    }
    Catch [System.Exception] {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Response: $($webResponse.StatusCode) - $($webResponse.StatusDescription)"
        Throw $_
    }
    Finally {
        $webResponse.Dispose()
    }
}
