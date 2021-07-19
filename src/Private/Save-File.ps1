Function Save-File {
    <#
        .SYNOPSIS
            Downloads a file with Invoke-WebRequest and returns the downloaded file path.
    #>
    [OutputType([System.Array])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNull()]
        [System.String] $Uri
    )
    
    # Create an OutFile to save the download to
    $OutFile = Join-Path -Path $([System.IO.Path]::GetTempPath()) -ChildPath (Split-Path -Path $Uri -Leaf)
    Write-Verbose -Message "$($MyInvocation.MyCommand): Using save path: $OutFile."

    try {
        $params = @{
            Uri             = $Uri
            OutFile         = $OutFile
            UseBasicParsing = $True
            UserAgent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
        }
        If (Test-PSCore) {
            $params.SslProtocol = "Tls12"
        }
        Else {
            $SslProtocol = "Tls12"
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::$SslProtocol
        }
        Invoke-WebRequest @params
    }
    catch {
        Throw "$($MyInvocation.MyCommand): $($_.Exception.Message)."
    }

    # Write the OutFile properties to the pipeline
    Write-Output -InputObject (Get-ChildItem -Path $OutFile)
}
