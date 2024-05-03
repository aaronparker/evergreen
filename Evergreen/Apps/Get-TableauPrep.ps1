function Get-TableauPrep {
    <#
        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
            based on Get-TelerikFiddlerEverywhere.ps1
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get the latest download
    $params = @{
        Uri     = $res.Get.Download.Uri
        Headers = $res.Get.Download.Headers
    }
    $Response = Resolve-InvokeWebRequest @params
    if ($null -ne $Response) {

        # Extract the version information from the uri
        try {
            $Version = [RegEx]::Match($Response, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
        }
        catch {
            throw "$($MyInvocation.MyCommand): Failed to extract the version information from the uri."
        }

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version      = $Version.Replace('-', '.')
            Architecture = Get-Architecture -String $Response
            Type         = Get-FileType -File $Response
            URI          = $Response
        }
        Write-Output -InputObject $PSObject
    }
}
