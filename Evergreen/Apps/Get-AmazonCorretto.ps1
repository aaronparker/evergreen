Function Get-AmazonCorretto {
    <#
        .SYNOPSIS
            Get the current versions and download URLs for Amazon Corretto 8, 11, 15 and 16.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get the latest download
    ForEach ($JDKversion in $res.Get.Download.JDK.GetEnumerator()) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Looking for JDK version $($JDKversion.Name)."

        ForEach ($JDKType in $res.Get.Download.JDK.($JDKversion.Name).GetEnumerator()) {

            $Url = $JDKType.Value
            $Response = Resolve-SystemNetWebRequest -Uri $Url

            # Construct the output; Return the custom object to the pipeline
            #NOTE: Version can now be returned with `Get-GitHubRepoRelease -ReturnVersionOnly`
            If ($Null -ne $Response) {
                $PSObject = [PSCustomObject] @{
                    Version      = [RegEx]::Match($Response.ResponseUri.LocalPath, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
                    Architecture = Get-Architecture -String $Url
                    JDK          = $JDKversion.Name
                    Type         = [System.IO.Path]::GetExtension($Url).Split(".")[-1]
                    URI          = $Response.ResponseUri.AbsoluteUri
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
