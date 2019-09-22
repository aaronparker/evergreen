Function Invoke-WebContent {
    <#
        .SYNOPSIS
            Return content from Invoke-WebRequest.
    #>
    [OutputType([Microsoft.PowerShell.Commands.WebResponseObject])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Uri,

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ContentType = "text/plain; charset=utf-8",

        [Parameter()]
        [System.Management.Automation.SwitchParameter] $Raw
    )

    If ($Null -ne $script:resourceStrings) {
        try {
            If ($Raw.IsPresent) {
                $tempFile = New-TemporaryFile
                $params = @{
                    Uri             = $Uri
                    OutFile         = $tempFile
                    ContentType     = $ContentType
                    UserAgent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
                    UseBasicParsing = $True
                    ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
                }
                $Response = Invoke-WebRequest @params
                $Content = Get-Content -Path $TempFile
            }
            Else {
                $params = @{
                    Uri             = $Uri
                    ContentType     = $ContentType
                    UserAgent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
                    UseBasicParsing = $True
                    ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
                }
                $Response = Invoke-WebRequest @params
                $Content = $Response.Content
            }
        }
        catch [System.Net.WebException] {
            Write-Warning -Message ($($MyInvocation.MyCommand))
            Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to invoke request to: $Uri."
            Throw $_.Exception.Message
        }
        finally {
            Write-Output -InputObject $Content
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): unable to retrieve: $Uri."
    }
}
