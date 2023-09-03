function Get-AmazonCorretto {
    <#
        .SYNOPSIS
            Get the current versions and download URLs for Amazon Corretto 8, 11, 15 and 16.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
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
    foreach ($JDKversion in $res.Get.Download.JDK.GetEnumerator()) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Looking for JDK version $($JDKversion.Name)."

        foreach ($JDKType in $res.Get.Download.JDK.($JDKversion.Name).GetEnumerator()) {
            $Response = Resolve-SystemNetWebRequest -Uri $JDKType.Value

            # Construct the output; Return the custom object to the pipeline
            if ($null -ne $Response) {
                $PSObject = [PSCustomObject] @{
                    Version      = [RegEx]::Match($Response.ResponseUri.LocalPath, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
                    JDK          = $JDKversion.Name
                    Architecture = Get-Architecture -String $JDKType.Value
                    Type         = [System.IO.Path]::GetExtension($JDKType.Value).Split(".")[-1]
                    URI          = $Response.ResponseUri.AbsoluteUri
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
