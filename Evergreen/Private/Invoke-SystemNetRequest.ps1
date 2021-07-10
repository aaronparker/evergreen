Function Invoke-SystemNetRequest {
    <#
        .SYNOPSIS
            Uses System.Net.WebRequest to make a HTTP request and returns the response.
    #>
    [OutputType([System.String])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
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
        $responseStream = $webResponse.GetResponseStream()
        $streamReader = New-Object -TypeName "System.IO.StreamReader" $responseStream
        $result = $streamReader.ReadToEnd()
        Write-Output -InputObject $result
    }
    catch [System.Exception] {
        Write-Warning -Message "$($MyInvocation.MyCommand): Error at URI: $Uri."
        Write-Warning -Message "$($MyInvocation.MyCommand): Response: $($_)."
        Write-Warning -Message "$($MyInvocation.MyCommand): For troubleshooting steps see: $($script:resourceStrings.Uri.Info)."
        #Throw "$($MyInvocation.MyCommand): $($_.Exception.Message)."
    }
    finally {
        $webResponse.Dispose()
    }
}
